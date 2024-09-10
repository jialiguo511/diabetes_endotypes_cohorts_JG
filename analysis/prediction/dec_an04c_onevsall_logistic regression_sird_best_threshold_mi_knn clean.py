# The purpose of this file is to run one vs all logistic regression on the imputed dataset to find the best threshold to predict the class labels
# NOTE: This script uses Statsmodels library to run the logistic regression
# NOTE: This script also uses standard units for the variables
# NOTE: This script is to test different thresholds to predict the class labels
# NOTE: This script produces coefficients and covariance matrix using the best threshold
# first run the k means clustering to create the TRUE labels

filename = 'dec_an02_kmeans_5var_mi_knn_clean.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()

# #################### One vs all logistic regression: SIRD vs non_SIRD ####################
# use statsmodels to estimate the coefficients of the logistic regression

import pandas as pd
import numpy as np
import statsmodels.api as sm
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.metrics import f1_score, roc_auc_score, classification_report, confusion_matrix

# Load and prepare your dataset
method_sird = analytic_dataset_cluster.copy()
method_sird['cluster'] = method_sird['cluster'].replace({'MARD': 'NON-SIRD', 'MOD': 'NON-SIRD', 'SIDD': 'NON-SIRD'})

var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
X = method_sird[var_9]
y = method_sird['cluster'].map({'NON-SIRD': 0, 'SIRD': 1})

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=57, stratify=y)
X_train_const = sm.add_constant(X_train)
X_test_const = sm.add_constant(X_test)

# StratifiedKFold ensures each fold is representative of the whole
kf = StratifiedKFold(n_splits=5, random_state=57, shuffle=True)
thresholds = np.arange(0.1, 0.8, 0.01)
threshold_f1_scores = {}
threshold_auc_scores = {}

# Cross-validation process
for threshold in thresholds:
    f1_scores = []
    auc_scores = []
    
    for train_index, val_index in kf.split(X_train_const, y_train):
        X_train_fold = X_train_const.iloc[train_index]
        y_train_fold = y_train.iloc[train_index]
        X_val_fold = X_train_const.iloc[val_index]
        y_val_fold = y_train.iloc[val_index]

        # Model fitting
        model = sm.Logit(y_train_fold, X_train_fold)
        result = model.fit(disp=0)
        
        # Predictions for AUC and F1 score
        y_val_pred_proba = result.predict(X_val_fold)
        y_val_pred = (y_val_pred_proba >= threshold).astype(int)
        
        # F1 score is threshold dependent
        f1 = f1_score(y_val_fold, y_val_pred)
        f1_scores.append(f1)
        
        # AUC is evaluated from probabilities, hence independent of threshold
        auc = roc_auc_score(y_val_fold, y_val_pred_proba)
        auc_scores.append(auc)
    
    threshold_f1_scores[threshold] = np.mean(f1_scores)
    threshold_auc_scores[threshold] = np.mean(auc_scores)

# Determine the best threshold based on F1 scores
best_threshold = max(threshold_f1_scores, key=threshold_f1_scores.get)
best_f1_score = threshold_f1_scores[best_threshold]
best_auc_score = threshold_auc_scores[best_threshold]

# Report results
print("Threshold performance:")
for t in thresholds:
    print(f"Threshold: {t:.2f}, Avg F1-Score: {threshold_f1_scores[t]:.6f}, Avg AUC: {threshold_auc_scores[t]:.4f}")

print(f"\nBest Threshold: {best_threshold:.2f}, Best Avg F1-Score: {best_f1_score:.6f}, Best Avg AUC: {best_auc_score:.4f}")

# Final evaluation on the test set
result_full = sm.Logit(y_train, X_train_const).fit(disp=0)
y_test_pred_proba = result_full.predict(X_test_const)
y_test_pred = (y_test_pred_proba >= best_threshold).astype(int)
print("\nClassification Report for Test Set with Best Threshold:")
print(classification_report(y_test, y_test_pred, target_names=['NON-SIRD', 'SIRD']))
print("Confusion Matrix with Best Threshold:")
print(confusion_matrix(y_test, y_test_pred))


# Define the function calculate_metrics
def calculate_metrics(conf_matrix):
    TN, FP, FN, TP = conf_matrix.ravel()
    sensitivity = TP / (TP + FN) if TP + FN != 0 else 0
    specificity = TN / (TN + FP) if TN + FP != 0 else 0
    PPV = TP / (TP + FP) if TP + FP != 0 else 0
    NPV = TN / (TN + FN) if TN + FN != 0 else 0
    return {
        'Sensitivity': sensitivity,
        'Specificity': specificity,
        'PPV': PPV,
        'NPV': NPV
    }

# Calculate metrics at the best threshold
metrics_at_best_threshold = calculate_metrics(confusion_matrix(y_test, y_test_pred))
print("\nMetrics at Best Threshold:")
for metric, value in metrics_at_best_threshold.items():
    print(f'{metric}: {value:.4f}')

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
coef_df.to_csv(path_folder + '/working/processed/dec_an04c_sird_estimated_coefficients_with_ci_clean_0.12.csv', index=False)

# now get the covariance matrix
cov_matrix = result_full.cov_params()
# check the covariance matrix
print("Covariance Matrix:")
print(cov_matrix)
# rename the index and columns
cov_matrix.index = ['Intercept'] + list(X.columns)
cov_matrix.columns = ['Intercept'] + list(X.columns)
# save the covariance matrix
cov_matrix.to_csv(path_folder + '/working/processed/dec_an04c_sird_covariance_matrix_statsmodels_clean_0.12.csv')


# Save the sensitivity, specificity, PPV, and NPV and F1 score for the test set at the best threshold
test_f1_score = f1_score(y_test, y_test_pred) 
test_auc_score = roc_auc_score(y_test, y_test_pred_proba)  

metrics_at_best_threshold.update({
    'F1': test_f1_score,  
    'AUC': test_auc_score,  
    'Threshold': best_threshold,
    'Sample_Size': len(y_test)
})

# Convert the dictionary to a DataFrame
metrics_df = pd.DataFrame([metrics_at_best_threshold])

# Save the DataFrame to a CSV file
metrics_df.to_csv(path_folder + '/working/processed/dec_an04c_sird_performance_at_best_threshold_clean_0.12.csv', index=True)