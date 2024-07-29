# The purpose of this file is to run random forest model to predict the cluster labels and generate performance metrics on the TRAINING dataset 
# NOTE: This script uses sklearn library
# NOTE: This script uses SCALED data UNLIKE all vs one logistic regression model due to convergence issues
# first run the k means clustering to create the TRUE labels

filename = 'dec_an02_kmeans_5var_mi_knn.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()
# #################### Random Forest Model ####################
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.metrics import classification_report, confusion_matrix, roc_curve, auc, f1_score, roc_auc_score
from sklearn.preprocessing import label_binarize

# Select the variables for the model
var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
X = analytic_dataset_cluster[var_9]
y = analytic_dataset_cluster['cluster']

# Standardize the dataset
scaler = StandardScaler()
X_scaled = scaler.fit_transform(X)

# Initialize the Random Forest classifier
random_forest_model = RandomForestClassifier(n_estimators=100, random_state=57)

# Setup cross-validation
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=57)

# Prepare to collect results
all_y_true = []
all_y_pred = []
all_y_pred_proba = []

# Cross-validation
for train_idx, test_idx in cv.split(X_scaled, y):
    X_train, X_test = X_scaled[train_idx], X_scaled[test_idx]
    y_train, y_test = y[train_idx], y[test_idx]

    # Fit the model
    random_forest_model.fit(X_train, y_train)

    # Predict on the test set of the current fold
    y_test_pred = random_forest_model.predict(X_test)
    y_test_pred_proba = random_forest_model.predict_proba(X_test)

    # Collect the results
    all_y_true.extend(y_test)
    all_y_pred.extend(y_test_pred)
    all_y_pred_proba.extend(y_test_pred_proba)

# Convert collected results to numpy arrays
all_y_true = np.array(all_y_true)
all_y_pred = np.array(all_y_pred)
all_y_pred_proba = np.array(all_y_pred_proba)

# Generate and print the classification report for the aggregated results
print("\nClassification Report for Random Forest Classification (Cross-Validation):")
print(classification_report(all_y_true, all_y_pred))

# Calculate and print the confusion matrix for the aggregated results
conf_matrix_cv = confusion_matrix(all_y_true, all_y_pred, labels=['MARD', 'MOD', 'SIDD', 'SIRD'])
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

# Binarize the output
all_y_true_binarized = label_binarize(all_y_true, classes=labels)

# Calculate F1 score and AUC for each class
f1_scores_cv = []
auc_scores_cv = []

for i, label in enumerate(labels):
    f1 = f1_score(all_y_true_binarized[:, i], label_binarize(all_y_pred, classes=labels)[:, i])
    auc_score = roc_auc_score(all_y_true_binarized[:, i], all_y_pred_proba[:, i])
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

# Save the DataFrame to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
metrics_df_cv.to_csv(path_folder + '/working/processed/dec_an07c_random_forest_performance_metrics_training_5cv.csv', index=False)

# Plot ROC curve for Random Forest Classification
plt.figure(figsize=(10, 6))
for i in range(len(labels)):
    fpr, tpr, _ = roc_curve(all_y_true_binarized[:, i], all_y_pred_proba[:, i])
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{labels[i]} (AUC = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve (Random Forest Classification)')
plt.legend()
plt.show()