# The purpose of this file is to run one vs all logistic regression on the imputed dataset to find the best threshold to predict the class labels
# NOTE: This script uses Statsmodels library to run the logistic regression
# NOTE: This script also uses standard units for the variables
# NOTE: This script is to test different thresholds to predict the class labels
# NOTE: This script produces perforamce matrix at best threshold using training data 
# first run the k means clustering to create the TRUE labels

filename = 'dec_an02_kmeans_5var_mi_knn_clean.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()

# #################### One vs all logistic regression: MOD vs non_MOD ####################
# use statsmodels to estimate the coefficients of the logistic regression

import pandas as pd
import numpy as np
import statsmodels.api as sm
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.metrics import f1_score, roc_auc_score, classification_report, confusion_matrix

# Combine three groups (SIRD, MOD, and SIDD) into a new group named "NON-MARD"
method_mard = analytic_dataset_cluster.copy()
method_mard['cluster'] = method_mard['cluster'].replace({'MOD': 'NON-MARD', 'SIRD': 'NON-MARD', 'SIDD': 'NON-MARD'})

# Select the variables
var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
X = method_mard[var_9]
y = method_mard['cluster'].map({'NON-MARD': 0, 'MARD': 1})

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=57, stratify=y)
X_train_const = sm.add_constant(X_train)
X_test_const = sm.add_constant(X_test)

# StratifiedKFold ensures each fold is representative of the whole
kf = StratifiedKFold(n_splits=5, random_state=57, shuffle=True)
thresholds = np.arange(0.1, 0.8, 0.01)
threshold_f1_scores = {}
threshold_auc_scores = {}
threshold_sensitivities = {}
threshold_specificities = {}
threshold_ppvs = {}
threshold_npvs = {}

# Cross-validation process
for threshold in thresholds:
    f1_scores = []
    auc_scores = []
    sensitivities = []
    specificities = []
    ppvs = []
    npvs = []
    
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
        
        # Calculate additional metrics
        conf_matrix = confusion_matrix(y_val_fold, y_val_pred)
        TN, FP, FN, TP = conf_matrix.ravel()
        sensitivity = TP / (TP + FN) if TP + FN != 0 else 0
        specificity = TN / (TN + FP) if TN + FP != 0 else 0
        ppv = TP / (TP + FP) if TP + FP != 0 else 0
        npv = TN / (TN + FN) if TN + FN != 0 else 0
        
        sensitivities.append(sensitivity)
        specificities.append(specificity)
        ppvs.append(ppv)
        npvs.append(npv)
    
    threshold_f1_scores[threshold] = np.mean(f1_scores)
    threshold_auc_scores[threshold] = np.mean(auc_scores)
    threshold_sensitivities[threshold] = np.mean(sensitivities)
    threshold_specificities[threshold] = np.mean(specificities)
    threshold_ppvs[threshold] = np.mean(ppvs)
    threshold_npvs[threshold] = np.mean(npvs)

# Determine the best threshold based on F1 scores
best_threshold = max(threshold_f1_scores, key=threshold_f1_scores.get)
best_f1_score = threshold_f1_scores[best_threshold]
best_auc_score = threshold_auc_scores[best_threshold]
best_sensitivity = threshold_sensitivities[best_threshold]
best_specificity = threshold_specificities[best_threshold]
best_ppv = threshold_ppvs[best_threshold]
best_npv = threshold_npvs[best_threshold]

# Report results
print("Threshold performance:")
for t in thresholds:
    print(f"Threshold: {t:.2f}, Avg F1-Score: {threshold_f1_scores[t]:.6f}, Avg AUC: {threshold_auc_scores[t]:.4f}")

print(f"\nBest Threshold: {best_threshold:.2f}, Best Avg F1-Score: {best_f1_score:.6f}, Best Avg AUC: {best_auc_score:.4f}")

# Save the metrics to a CSV file
metrics_at_best_threshold = {
    'Sensitivity': best_sensitivity,
    'Specificity': best_specificity,
    'AUC': best_auc_score,
    'PPV': best_ppv,
    'NPV': best_npv,
    'F1': best_f1_score,
    'Threshold': best_threshold,
}

# Convert the dictionary to a DataFrame
metrics_df = pd.DataFrame([metrics_at_best_threshold])

# Save the DataFrame to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
metrics_df.to_csv(path_folder + '/working/processed/dec_an04ea_mard_performance_metrics_training_cv_clean.csv', index=False)

print("Metrics saved to CSV file successfully.")