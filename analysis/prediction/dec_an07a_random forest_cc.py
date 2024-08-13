# The purpose of this file is to run random forest model to predict the cluster labels 
# NOTE: This script uses sklearn library
# NOTE: This script uses SCALED data UNLIKE all vs one logistic regression model due to convergence issues
# first run the k means clustering to create the TRUE labels

filename = 'dec_an01_kmeans_5var.py'
with open(filename) as file:
    exec(file.read())

analytic_dataset_cluster.head()

# #################### Random Forest Model  ####################
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split, cross_val_score, StratifiedKFold
from sklearn.metrics import classification_report, confusion_matrix,roc_curve, auc
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

# Define the labels for the classes based on your domain knowledge
labels = ['MARD', 'MOD', 'SIDD', 'SIRD']

# Calculate and print metrics for each class
metrics_random_forest = calculate_metrics(conf_matrix, labels)
print("\nMetrics for each class (Random Forest Classification):")
for cls, cls_metrics in metrics_random_forest.items():
    print(f'{cls}:')
    for metric, value in cls_metrics.items():
        print(f'  {metric}: {value:.4f}')


        
# Plot ROC curve for Multinomial Logistic Regression
plt.figure(figsize=(10, 6))
y_test_pred_proba_logistic = random_forest_model.predict_proba(X_test_scaled)
for i in range(len(labels)):
    fpr, tpr, _ = roc_curve(label_binarize(y_test, classes=labels)[:, i], y_test_pred_proba_logistic[:, i])
    roc_auc = auc(fpr, tpr)
    plt.plot(fpr, tpr, label=f'{labels[i]} (AUC = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], color='navy', linestyle='--')
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('ROC Curve (Multinomial Logistic Regression)')
plt.legend()
plt.show()
