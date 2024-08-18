# The purpose of this file is to run random forest model to predict the cluster labels and generate performance metrics on the TRAINING dataset 
# NOTE: This script uses sklearn library
# NOTE: This script uses SCALED data UNLIKE all vs one logistic regression model due to convergence issues
# first run the k means clustering to create the TRUE labels


filename = 'dec_an02_kmeans_5var_mi_knn_clean.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()

# #################### Random Forest Model ####################
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler, label_binarize
from sklearn.model_selection import StratifiedKFold, train_test_split
from sklearn.metrics import classification_report, confusion_matrix, f1_score, roc_auc_score, roc_curve, auc

# Select the variables for the model
var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
X = analytic_dataset_cluster[var_9]
y = analytic_dataset_cluster['cluster']

# Initial train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, stratify=y, random_state=57)

# Reset indices of the training data
X_train = X_train.reset_index(drop=True)
y_train = y_train.reset_index(drop=True)

# Standardize the dataset
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Initialize the Random Forest classifier
random_forest_model = RandomForestClassifier(n_estimators=100, random_state=57)

# Setup cross-validation
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=57)

# Prepare to collect results from cross-validation
all_y_true_cv = []
all_y_pred_cv = []
all_y_pred_proba_cv = []

# Cross-validation on the training set
for train_idx, val_idx in cv.split(X_train_scaled, y_train):
    X_train_cv, X_val_cv = X_train_scaled[train_idx], X_train_scaled[val_idx]
    y_train_cv, y_val_cv = y_train.iloc[train_idx], y_train.iloc[val_idx]

    # Fit the model
    random_forest_model.fit(X_train_cv, y_train_cv)

    # Predict on the validation set of the current fold
    y_val_pred = random_forest_model.predict(X_val_cv)
    y_val_pred_proba = random_forest_model.predict_proba(X_val_cv)

    # Collect the results
    all_y_true_cv.extend(y_val_cv)
    all_y_pred_cv.extend(y_val_pred)
    all_y_pred_proba_cv.extend(y_val_pred_proba)

# Convert collected results to numpy arrays
all_y_true_cv = np.array(all_y_true_cv)
all_y_pred_cv = np.array(all_y_pred_cv)
all_y_pred_proba_cv = np.array(all_y_pred_proba_cv)

# Generate and print the classification report for the aggregated results from cross-validation
print("\nClassification Report for Random Forest Classification (Cross-Validation on Training Set):")
print(classification_report(all_y_true_cv, all_y_pred_cv))

# Calculate and print the confusion matrix for the aggregated results from cross-validation
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

# Define the labels for the classes based on your domain knowledge
labels = ['MARD', 'MOD', 'SIDD', 'SIRD']

# Calculate and print metrics for each class
metrics_random_forest_cv = calculate_metrics(conf_matrix_cv, labels)
print("\nMetrics for each class (Random Forest Classification):")
for cls, cls_metrics in metrics_random_forest_cv.items():
    print(f'{cls}:')
    for metric, value in cls_metrics.items():
        print(f'  {metric}: {value:.4f}')

# Binarize the output for cross-validation
all_y_true_binarized_cv = label_binarize(all_y_true_cv, classes=labels)

# Calculate F1 score and AUC for each class in cross-validation
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
        'Sensitivity': metrics_random_forest_cv[label]['Sensitivity'],
        'Specificity': metrics_random_forest_cv[label]['Specificity'],
        'PPV': metrics_random_forest_cv[label]['PPV'],
        'NPV': metrics_random_forest_cv[label]['NPV'],
        'F1': f1_scores_cv[i],
        'AUC': auc_scores_cv[i],
    }
    metrics_list_cv.append(metrics)

# Convert the list of dictionaries to a DataFrame
metrics_df_cv = pd.DataFrame(metrics_list_cv)

# Optional: Save to CSV
metrics_df_cv.to_csv('random_forest_crossval_metrics.csv', index=False)
# Save the DataFrame to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
metrics_df_cv.to_csv(path_folder + '/working/processed/dec_an07c_random_forest_performance_metrics_training_5cv_clean.csv', index=False)

# Plot ROC curve for Random Forest Classification
plt.figure(figsize=(10, 6))
for i in range(len(labels)):
    fpr, tpr, _ = roc_curve(all_y_true_binarized_cv[:, i], all_y_pred_proba_cv[:, i])
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{labels[i]} (AUC = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve (Random Forest Classification)')
plt.legend()
plt.show()