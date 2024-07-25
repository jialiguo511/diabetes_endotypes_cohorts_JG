# The purpose of this file is to run one vs all logistic regression on the same dataset
# NOTE: This script uses Statsmodels library to run the logistic regression
# NOTE: This script also uses standard units for the variables
# NOTE: This script uses the 0.5 threshold to predict the class labels
# NOTE: This script runs SIDD vs non_SIDD
# first run the k means clustering to create the TRUE labels

filename = 'dec_an01_kmeans_5var.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()

# #################### One vs all logistic regression: SIDD vs non_SIDD ####################
# use statsmodels to estimate the coefficients of the logistic regression

import pandas as pd
import numpy as np
import statsmodels.api as sm
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.metrics import roc_auc_score, roc_curve, classification_report, confusion_matrix

# Combine three groups (MARD, MOD, and SIRD) into a new group named "NON-SIDD"
method_sidd = analytic_dataset_cluster.copy()
method_sidd['cluster'] = method_sidd['cluster'].replace({'MARD': 'NON-SIDD', 'MOD': 'NON-SIDD', 'SIRD': 'NON-SIDD'})

# Select the variables
var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
X = method_sidd[var_9]
y = method_sidd['cluster'].map({'NON-SIDD': 0, 'SIDD': 1})

# Split the data into training and testing sets (30% test dataset)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=57, stratify=y)

# Add a constant term for the intercept
X_train_const = sm.add_constant(X_train)
X_test_const = sm.add_constant(X_test)

# Initialize and perform cross-validation manually using StatsModels
kf = StratifiedKFold(n_splits=5, shuffle=True, random_state=57)
roc_auc_scores = []

for train_index, val_index in kf.split(X_train_const, y_train):
    X_train_fold, X_val_fold = X_train_const.iloc[train_index], X_train_const.iloc[val_index]
    y_train_fold, y_val_fold = y_train.iloc[train_index], y_train.iloc[val_index]

    model = sm.Logit(y_train_fold, X_train_fold)
    result = model.fit(disp=0)  # disp=0 suppresses fit output

    # Predict on the validation fold
    y_val_pred_proba = result.predict(X_val_fold)
    roc_auc = roc_auc_score(y_val_fold, y_val_pred_proba)
    roc_auc_scores.append(roc_auc)

average_roc_auc = np.mean(roc_auc_scores)
print(f'5-Fold Cross-Validation ROC AUC: {average_roc_auc:.4f}')

# Fit the logistic regression model using statsmodels on the entire training data
logit_model_full = sm.Logit(y_train, X_train_const)
result_full = logit_model_full.fit()
print(result_full.summary())


# Predict the class labels on the test set using the 0.5 threshold
y_test_pred_proba = result_full.predict(X_test_const)
y_test_pred = (y_test_pred_proba >= 0.5).astype(int)


# Generate the classification report for the test set with class labels
print("\nClassification Report for Logistic Regression:")
print(classification_report(y_test, y_test_pred, target_names=['NON-SIDD', 'SIDD']))

# Calculate confusion matrix for the test set
conf_matrix = confusion_matrix(y_test, y_test_pred)
print("Confusion Matrix:")
print(conf_matrix)

# Define and calculate metrics for each class
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

# Define the labels based on your domain knowledge
labels = ['NON-SIDD', 'SIDD']

# Calculate and print metrics for Logistic Regression
metrics_lr = calculate_metrics(conf_matrix, labels)
print("\nMetrics for each class (Logistic Regression):")
for cls, cls_metrics in metrics_lr.items():
    print(f'{cls}:')
    for metric, value in cls_metrics.items():
        print(f'  {metric}: {value:.4f}')

# Summary of performance metrics for Logistic Regression
summary_report_lr = {
    'Model': 'Logistic Regression: SIDD vs non_SIDD',
    'Accuracy': classification_report(y_test, y_test_pred, output_dict=True)['accuracy'],
    'Sensitivity (Per Class)': {cls: metrics_lr[cls]['Sensitivity'] for cls in metrics_lr},
    'Specificity (Per Class)': {cls: metrics_lr[cls]['Specificity'] for cls in metrics_lr},
    'PPV (Per Class)': {cls: metrics_lr[cls]['PPV'] for cls in metrics_lr},
    'NPV (Per Class)': {cls: metrics_lr[cls]['NPV'] for cls in metrics_lr}
}

print("\nSummary Report (Logistic Regression)")
for key, value in summary_report_lr.items():
    if isinstance(value, dict):
        print(f'{key}:')
        for sub_key, sub_value in value.items():
            print(f'  {sub_key}: {sub_value:.4f}')
    else:
        print(f'{key}: {value}')

# Get the estimated coefficients with confidence intervals and p-values
summary = result_full.summary()
coef_table = summary.tables[1]
coef_df = pd.DataFrame(coef_table.data[1:], columns=coef_table.data[0])
coef_df.columns = ['Variable', 'Coefficient', 'Standard Error', 'z-value', 'p-value', 'Lower CI (95%)', 'Upper CI (95%)']
coef_df['Variable'] = ['Intercept'] + list(X.columns)
coef_df['Variable'] = coef_df['Variable'].str.capitalize()
coef_df['Coefficient'] = coef_df['Coefficient'].astype(float)
coef_df['Standard Error'] = coef_df['Standard Error'].astype(float)
coef_df['z-value'] = coef_df['z-value'].astype(float)
coef_df['p-value'] = coef_df['p-value'].astype(float)
coef_df['Lower CI (95%)'] = coef_df['Lower CI (95%)'].astype(float)
coef_df['Upper CI (95%)'] = coef_df['Upper CI (95%)'].astype(float)

# Print the estimated coefficients with confidence intervals and p-values
print("Estimated Coefficients with Confidence Intervals and p-values:")
print(coef_df)
# Save the estimated coefficients with confidence intervals and p-values to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
coef_df.to_csv(path_folder + '/working/processed/dec_an03_sidd_estimated_coefficients_with_ci_unscaled.csv', index=False)

# now get the covariance matrix
cov_matrix = result_full.cov_params()
# check the covariance matrix
print("Covariance Matrix:")
print(cov_matrix)
# rename the index and columns
cov_matrix.index = ['Intercept'] + list(X.columns)
cov_matrix.columns = ['Intercept'] + list(X.columns)
# save the covariance matrix
cov_matrix.to_csv(path_folder + '/working/processed/dec_an03_sidd_covariance_matrix_statsmodels_unscaled.csv')