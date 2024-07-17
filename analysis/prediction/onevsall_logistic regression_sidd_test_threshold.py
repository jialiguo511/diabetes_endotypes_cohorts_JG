# The purpose of this file is to run one vs all logistic regression on the same dataset
# NOTE: This script uses Statsmodels library to run the logistic regression
# NOTE: This script also uses standard units for the variables
# NOTE: This script is to test different thresholds to predict the class labels
# first run the k means clustering to create the TRUE labels

filename = 'kmeans_5var.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()

# #################### One vs all logistic regression: SIDD vs non_SIDD ####################
# use statsmodels to estimate the coefficients of the logistic regression

import pandas as pd
import numpy as np
import statsmodels.api as sm
from sklearn.model_selection import train_test_split, StratifiedKFold
from sklearn.metrics import f1_score, roc_auc_score, classification_report, confusion_matrix

# Load and prepare your dataset
method_sidd = analytic_dataset_cluster.copy()
method_sidd['cluster'] = method_sidd['cluster'].replace({'MARD': 'NON-SIDD', 'MOD': 'NON-SIDD', 'SIRD': 'NON-SIDD'})

var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
X = method_sidd[var_9]
y = method_sidd['cluster'].map({'NON-SIDD': 0, 'SIDD': 1})

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=57, stratify=y)
X_train_const = sm.add_constant(X_train)
X_test_const = sm.add_constant(X_test)

# StratifiedKFold ensures each fold is representative of the whole
kf = StratifiedKFold(n_splits=5, random_state=57, shuffle=True)
thresholds = np.arange(0.1, 0.8, 0.05)
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
    print(f"Threshold: {t:.2f}, Avg F1-Score: {threshold_f1_scores[t]:.4f}, Avg AUC: {threshold_auc_scores[t]:.4f}")

print(f"\nBest Threshold: {best_threshold:.2f}, Best Avg F1-Score: {best_f1_score:.4f}, Best Avg AUC: {best_auc_score:.4f}")

# Final evaluation on the test set
result_full = sm.Logit(y_train, X_train_const).fit(disp=0)
y_test_pred_proba = result_full.predict(X_test_const)
y_test_pred = (y_test_pred_proba >= best_threshold).astype(int)
print("\nClassification Report for Test Set with Best Threshold:")
print(classification_report(y_test, y_test_pred, target_names=['NON-SIDD', 'SIDD']))
print("Confusion Matrix with Best Threshold:")
print(confusion_matrix(y_test, y_test_pred))

# Additional metrics calculation
metrics_at_best_threshold = calculate_metrics(confusion_matrix(y_test, y_test_pred))
print("\nMetrics at Best Threshold:")
for metric, value in metrics_at_best_threshold.items():
    print(f'{metric}: {value:.4f}')
