# The purpose of this file is to run multinomial logistic regression to predict the cluster labels using imputed data based on KNN imputation
# NOTE: This script uses sklearn library to run the multinomial logistic regression
# NOTE: This script uses SCALED data UNLIKE all vs one logistic regression model due to convergence issues
# first run the k means clustering to create the TRUE labels

filename = 'dec_an02_kmeans_5var_mi_knn.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()

# #################### Multinomial Logistic Regression with Cross-Validation ####################
# Select the variables for the model
var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
additional_vars = ['homa2b', 'homa2ir', 'study', 'study_id']
X = analytic_dataset_cluster[var_9]
X_additional = analytic_dataset_cluster[additional_vars]
y = analytic_dataset_cluster['cluster']

# Initial train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, stratify=y, random_state=57)

# Corresponding additional variables split
X_additional_train = X_additional.loc[X_train.index]

# Reset indices of the training data
X_train = X_train.reset_index(drop=True)
X_additional_train = X_additional_train.reset_index(drop=True)
y_train = y_train.reset_index(drop=True)

# Standardize the dataset
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Initialize the multinomial logistic regression model
logistic_model = LogisticRegression(multi_class='multinomial', solver='lbfgs', max_iter=1000, random_state=57)

# Fit the multinomial logistic regression model to the training data
logistic_model.fit(X_train_scaled, y_train)

# Predict probabilities for the training data
y_train_pred_proba = logistic_model.predict_proba(X_train_scaled)

# Predict the final model estimate/classification for the training data
y_train_pred = logistic_model.predict(X_train_scaled)

# Create a DataFrame with the predicted probabilities
probability_df = pd.DataFrame(y_train_pred_proba, columns=['prob_MARD', 'prob_MOD', 'prob_SIDD', 'prob_SIRD'])

# Combine the original training data, additional variables, and the predicted probabilities
combined_df = pd.concat([X_train, X_additional_train, probability_df], axis=1)

# Add the original cluster labels
combined_df['cluster'] = y_train
combined_df['predicted_cluster'] = y_train_pred

# Save the combined DataFrame to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
combined_df.to_csv(path_folder + '/working/processed/training_data_with_probabilities.csv', index=False)


# Setup cross-validation
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=57)

# Prepare to collect results
all_y_true_cv = []
all_y_pred_cv = []
all_y_pred_proba_cv = []


# Cross-validation on the training set
for train_idx, val_idx in cv.split(X_train_scaled, y_train):
    X_train_cv, X_val_cv = X_train_scaled[train_idx], X_train_scaled[val_idx]
    y_train_cv, y_val_cv = y_train[train_idx], y_train[val_idx]

    # Fit the model
    logistic_model.fit(X_train_cv, y_train_cv)

    # Predict on the validation set of the current fold
    y_val_pred = logistic_model.predict(X_val_cv)
    y_val_pred_proba = logistic_model.predict_proba(X_val_cv)

    # Collect the results
    all_y_true_cv.extend(y_val_cv)
    all_y_pred_cv.extend(y_val_pred)
    all_y_pred_proba_cv.extend(y_val_pred_proba)

# Convert collected results to numpy arrays
all_y_true_cv = np.array(all_y_true_cv)
all_y_pred_cv = np.array(all_y_pred_cv)
all_y_pred_proba_cv = np.array(all_y_pred_proba_cv)

# Generate and print the classification report for the aggregated results
print("\nClassification Report for Multinomial Logistic Regression (Cross-Validation):")
print(classification_report(all_y_true_cv, all_y_pred_cv))

# Calculate and print the confusion matrix for the aggregated results
conf_matrix_cv = confusion_matrix(all_y_true_cv, all_y_pred_cv, labels=['MARD', 'MOD', 'SIDD', 'SIRD'])
print("Confusion Matrix:")
print(conf_matrix_cv)

# Function to calculate sensitivity, specificity, PPV, and NPV for each class
def calculate_metrics(conf_matrix, labels):
    metrics = {}
    for i, label in enumerate(labels):
        TP = conf_matrix[i, i]
        FN = conf_matrix[i, :].sum() - TP
        FP = conf_matrix[:, i].sum() - TP
        TN = conf_matrix.sum() - (TP + FP + FN)
        
        sensitivity = TP / (TP + FN) if (TP + FN) != 0 else 0
        specificity = TN / (TN + FP) if (TN + FP) != 0 else 0
        PPV = TP / (TP + FP) if (TP + FP) != 0 else 0
        NPV = TN / (TN + FN) if (TN + FN) != 0 else 0
        
        metrics[label] = {
            'Sensitivity': sensitivity,
            'Specificity': specificity,
            'PPV': PPV,
            'NPV': NPV
        }
    return metrics

# Define the labels for the classes in the specified order
labels = ['MARD', 'MOD', 'SIDD', 'SIRD']

# Calculate and print metrics for each class
metrics_logistic_cv = calculate_metrics(conf_matrix_cv, labels)
print("\nMetrics for each class (Multinomial Logistic Regression):")
for cls, cls_metrics in metrics_logistic_cv.items():
    print(f'{cls}:')
    for metric, value in cls_metrics.items():
        print(f'  {metric}: {value:.4f}')

# Binarize the output
all_y_true_binarized_cv = label_binarize(all_y_true_cv, classes=labels)

# Calculate F1 score and AUC for each class
f1_scores_cv = []
auc_scores_cv = []

for i, label in enumerate(labels):
    f1 = f1_score(all_y_true_binarized_cv[:, i], label_binarize(all_y_pred_cv, classes=labels)[:, i])
    auc_score = roc_auc_score(all_y_true_binarized_cv[:, i], all_y_pred_proba_cv[:, i])
    f1_scores_cv.append(f1)
    auc_scores_cv.append(auc_score)
    print(f"\n{label} F1 Score: {f1:.4f}")
    print(f"{label} AUC Score: {auc_score:.4f}")


# Save the sensitivity, specificity, PPV, NPV, F1 score, and AUC for the cross-validated results to CSV
metrics_list_cv = []
for i, label in enumerate(labels):
    metrics = {
        'Class': label,
        'Sensitivity': metrics_logistic_cv[label]['Sensitivity'],
        'Specificity': metrics_logistic_cv[label]['Specificity'],
        'PPV': metrics_logistic_cv[label]['PPV'],
        'NPV': metrics_logistic_cv[label]['NPV'],
        'F1': f1_scores_cv[i],
        'AUC': auc_scores_cv[i],
    }
    metrics_list_cv.append(metrics)

# Convert the list of dictionaries to a DataFrame
metrics_df_cv = pd.DataFrame(metrics_list_cv)

# Save the DataFrame to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
metrics_df_cv.to_csv(path_folder + '/working/processed/dec_an06c_multinomial_performance_metrics_training_cv.csv', index=False)

# Plot ROC curve for Multinomial Logistic Regression
plt.figure(figsize=(10, 6))
for i in range(len(labels)):
    fpr, tpr, _ = roc_curve(all_y_true_binarized_cv[:, i], all_y_pred_proba_cv[:, i])
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{labels[i]} (AUC = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve (Multinomial Logistic Regression)')
plt.legend()
plt.show()