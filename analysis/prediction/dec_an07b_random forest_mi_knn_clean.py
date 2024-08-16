# The purpose of this file is to run random forest model to predict the cluster labels 
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
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.metrics import classification_report, confusion_matrix, roc_curve, auc, f1_score, roc_auc_score
from sklearn.preprocessing import label_binarize

# Select the variables for the model
var_9 = ['bmi', 'hba1c', 'dmagediag', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']
X = analytic_dataset_cluster[var_9]
y = analytic_dataset_cluster['cluster']

# Split the data into training and testing sets (30% test dataset)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=57, stratify=y)

# Standardize the dataset
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Initialize the Random Forest classifier
random_forest_model = RandomForestClassifier(n_estimators=100, random_state=57)

# Setup cross-validation
cv = StratifiedKFold(n_splits=5, shuffle=True, random_state=57)

# Calculate cross-validation scores (accuracy)
cv_scores = cross_val_score(random_forest_model, X_train_scaled, y_train, cv=cv)
average_cv_accuracy = np.mean(cv_scores)
print("Average Cross-Validation Accuracy: {:.2f}%".format(average_cv_accuracy * 100))

# Fit the model on the entire training dataset
random_forest_model.fit(X_train_scaled, y_train)

# Predict on the test dataset
y_test_pred = random_forest_model.predict(X_test_scaled)
y_test_pred_proba = random_forest_model.predict_proba(X_test_scaled)

# Generate and print the classification report for the test set
print("\nClassification Report for Random Forest Classification:")
print(classification_report(y_test, y_test_pred))

# Calculate and print the confusion matrix for the test set
conf_matrix = confusion_matrix(y_test, y_test_pred)
print("Confusion Matrix:")
print(conf_matrix)

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

# Define the labels 
labels = ['MARD', 'MOD', 'SIDD', 'SIRD']

# Calculate and print metrics for each class
metrics_random_forest = calculate_metrics(conf_matrix, labels)
print("\nMetrics for each class (Random Forest Classification):")
for cls, cls_metrics in metrics_random_forest.items():
    print(f'{cls}:')
    for metric, value in cls_metrics.items():
        print(f'  {metric}: {value:.4f}')

# Binarize the output
y_test_binarized = label_binarize(y_test, classes=labels)

# Calculate F1 score and AUC for each class
f1_scores = []
auc_scores = []

for i, label in enumerate(labels):
    f1 = f1_score(y_test_binarized[:, i], label_binarize(y_test_pred, classes=labels)[:, i])
    auc_score = roc_auc_score(y_test_binarized[:, i], y_test_pred_proba[:, i])
    f1_scores.append(f1)
    auc_scores.append(auc_score)
    print(f"\n{label} F1 Score: {f1:.4f}")
    print(f"{label} AUC Score: {auc_score:.4f}")

# Save the sensitivity, specificity, PPV, NPV, F1 score, and AUC for the test set to CSV
metrics_list = []
for i, label in enumerate(labels):
    metrics = {
        'Class': label,
        'Sensitivity': metrics_random_forest[label]['Sensitivity'],
        'Specificity': metrics_random_forest[label]['Specificity'],
        'PPV': metrics_random_forest[label]['PPV'],
        'NPV': metrics_random_forest[label]['NPV'],
        'F1': f1_scores[i],
        'AUC': auc_scores[i],
    }
    metrics_list.append(metrics)

# Convert the list of dictionaries to a DataFrame
metrics_df = pd.DataFrame(metrics_list)

# Save the DataFrame to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
metrics_df.to_csv(path_folder + '/working/processed/dec_an07b_random_forest_performance_metrics_clean.csv', index=False)

# Plot ROC curve for Random Forest Classification
plt.figure(figsize=(10, 6))
for i in range(len(labels)):
    fpr, tpr, _ = roc_curve(y_test_binarized[:, i], y_test_pred_proba[:, i])
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{labels[i]} (AUC = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve (Random Forest Classification)')
plt.legend()
plt.show()