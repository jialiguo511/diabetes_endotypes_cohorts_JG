# The purpose of this python file is to run k means on five variables: age of diagnosis, bmi, HbA1c, fasting insulin, and fasting glucose
# In this analysis, we will use coordiantes from ANDIS cohort to create the "TRUE" labels for the kmeans clustering and compare the results with the kmeans clustering results from the entire dataset
# This scripts will run kmeans clustering on the dataset with imputed missing values using KNN imputation.
# KNN imputation is conducted in a separate script. 
# load libraries
import pandas as pd 
import numpy as np
import os as os

import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler
from scipy.spatial.distance import cdist

#### uncomment the following line if you are NOT using a MACBOOK ####

#os. getlogin()
#if os.getlogin()=="JVARGH7":
    #path_folder = 'C:/Cloud/Emory University/li, zhongyu - Diabetes Endotypes Project (JV and ZL)'
#if os.getlogin()=='zhongyuli':
    #path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
# Rename the dataset into analytic sample
#analytic_dataset = pd.read_csv(path_folder + '/working/processed/final_dataset_6c_cc.csv')


#################### Load the data ####################

# first, we will load the data and conduct k means clustering to create the "TRUE labels"
# we will use the HOMA2IR and HOMA2B data to create the labels
# we will use the first 6 cohorts


path = '/Users/zhongyuli/Desktop/python/cluster analysis/dataset/final_dataset_6c_clean_mi_imputed_homa2.csv'

analytic_dataset = pd.read_csv(path) 

#select variables 
selected_variables = ['study_id','bmi', 'hba1c', 'dmagediag','homa2b','homa2ir','tgl','ldlc','ratio_th','sbp','dbp','hdlc','study','race','female']

#drop missing values in the selected variables
analytic_dataset = analytic_dataset[selected_variables]
analytic_dataset = analytic_dataset.dropna()

# convert HbA1c to mmol/mol from % 
analytic_dataset['hba1c'] = (analytic_dataset['hba1c']-2.15)*10.93

# check the mean and standard deviation of the HbA1c
print(analytic_dataset['hba1c'].mean())
print(analytic_dataset['hba1c'].std())

#check if any missing values
analytic_dataset.isnull().sum()
#check variable types
analytic_dataset.dtypes

#check the data
analytic_dataset.head()

# select five variables to cluster
var_5 = ['hba1c', 'bmi', 'dmagediag','homa2b','homa2ir']



##### ANDIS coordiantes ##### 

############## Scale Method: Z-score normalization by our study sample ##############

# Split dataset into female and male
data_female = analytic_dataset[analytic_dataset['female'] == 1]
data_male = analytic_dataset[analytic_dataset['female'] == 0]

# Apply Z-score normalization separately for each gender using their own means and SDs
scaler_female = StandardScaler()
X_female_normalized = scaler_female.fit_transform(data_female[var_5])

scaler_male = StandardScaler()
X_male_normalized = scaler_male.fit_transform(data_male[var_5])

# Published ANDIS centroids (unchanged - no standardization applied)
published_centroids_female = np.array([
    [1.8702613, -0.2415449, -0.1929637, -0.97446899, 0.056469],  # SIDD
    [-0.254848, 0.5189057, 0.3214557, 1.35581907, 1.1801933],   # SIRD
    [-0.3003478, 0.6683606, -0.9388278, -0.03556857, -0.1405151],  # MOD
    [-0.4582762, -0.5854255, 0.5980858, -0.14552652, -0.4254893]  # MARD
])

published_centroids_male = np.array([
    [1.52185804, -0.4284673, -0.4017103, -0.98397328, -0.1630751],  # SIDD
    [-0.39080167, 0.5396294, 0.4235841, 1.29059153, 1.1801031],   # SIRD
    [-0.06915764, 1.0305317, -1.0157681, 0.15742215, 0.1343923],  # MOD
    [-0.5367578, -0.4776681, 0.5031031, -0.09004338, -0.4233873]  # MARD
])

# Calculate RMSE between each case and the fixed centroids (no standardization applied to centroids)
def calculate_rmse(X, centroids):
    rmse_matrix = np.sqrt(np.mean((X[:, np.newaxis] - centroids) ** 2, axis=2))
    return rmse_matrix

# Calculate RMSE and assign clusters for females
rmse_female = calculate_rmse(X_female_normalized, published_centroids_female)
cluster_assignments_female = np.argmin(rmse_female, axis=1)

# Calculate RMSE and assign clusters for males
rmse_male = calculate_rmse(X_male_normalized, published_centroids_male)
cluster_assignments_male = np.argmin(rmse_male, axis=1)

# Add cluster assignments back to the original dataset
data_female['published_cluster'] = cluster_assignments_female
data_male['published_cluster'] = cluster_assignments_male

# Combine female and male datasets back into one DataFrame
data_combined = pd.concat([data_female, data_male])

# Output the combined dataset with assigned clusters
data_combined.head()

# relabel the cluster labels
data_combined['published_cluster'] = data_combined['published_cluster'].replace({0:'SIDD', 1:'SIRD', 2:'MOD', 3:'MARD'})

# check the cluster sample size for the published cluster
data_combined['published_cluster'].value_counts()


##### K mean clustering for the entire dataset #####

#standardize the data
scaler = StandardScaler()
data_scaled = scaler.fit_transform(analytic_dataset[var_5])


# run kmeans and get cluster labels from the five variable method 

kmeans = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans.fit(data_scaled)

# add the cluster labels to the copy of the dataset
analytic_dataset_cluster = analytic_dataset.copy()
analytic_dataset_cluster['cluster_all'] = kmeans.labels_

# summarize the cluster labels to the original dataset
analytic_dataset_cluster[var_5].groupby(analytic_dataset_cluster['cluster_all']).mean()

# relabel the cluster labels 
analytic_dataset_cluster['cluster_all'] = analytic_dataset_cluster['cluster_all'].replace({0:'SIDD', 1:'MOD', 2:'MARD', 3:'SIRD'})
analytic_dataset_cluster['cluster_all'].value_counts()
analytic_dataset_cluster.head()

# merge the dataset with the published cluster labels
analytic_dataset_cluster = analytic_dataset_cluster.merge(data_combined[['study_id','published_cluster']], on='study_id', how='left')

# check the data
analytic_dataset_cluster.head()


##### Compare the two clustering results: cluster_all and published cluster from ANDIS #####

# cross tabulate the cluster labels for the cluster_all and published cluster
cross_tab = pd.crosstab(analytic_dataset_cluster['cluster_all'], analytic_dataset_cluster['published_cluster'])

# output the cross tabulation to a csv file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
print(cross_tab)


cross_tab.to_csv(path_folder + '/working/processed/dec_an11_ANDIS_crosstab.csv', index=True)


from sklearn.metrics import adjusted_rand_score

# Calculate Adjusted Rand Index between the published clusters and k-means clusters
ari = adjusted_rand_score(analytic_dataset_cluster['published_cluster'], analytic_dataset_cluster['cluster_all'])
print(f"Adjusted Rand Index: {ari}")

from sklearn.metrics import normalized_mutual_info_score

# Calculate Normalized Mutual Information
nmi = normalized_mutual_info_score(analytic_dataset_cluster['published_cluster'], analytic_dataset_cluster['cluster_all'])
print(f"Normalized Mutual Information (NMI): {nmi}")

# Calculate mean values for each cluster in the gender-split k-means clustering
mean_values_split = analytic_dataset_cluster[var_5].groupby(analytic_dataset_cluster['published_cluster']).mean()
print("Mean values for gender-split k-means clusters:\n", mean_values_split)
sd_values_split = analytic_dataset_cluster[var_5].groupby(analytic_dataset_cluster['published_cluster']).std()
print(sd_values_split)
# Calculate mean values for each cluster in the full-sample k-means clustering
mean_values_full_sample = analytic_dataset_cluster[var_5].groupby(analytic_dataset_cluster['cluster_all']).mean()
print("Mean values for full-sample k-means clusters:\n", mean_values_full_sample)
sd_values_full_sample = analytic_dataset_cluster[var_5].groupby(analytic_dataset_cluster['cluster_all']).std()
print(sd_values_full_sample)
# Define a function to calculate NRI
def calculate_nri(df, cluster_col_old, cluster_col_new):
    # Calculate upward and downward reclassification
    # Here, upward reclassification means a change from one cluster to another.
    # For simplicity, we're treating reclassification as any difference between cluster assignments.
    
    # Count the number of individuals reclassified between the two methods
    up_reclassified = sum(df[cluster_col_new] != df[cluster_col_old])
    down_reclassified = 0  # Not applicable in this case as there's no ordering of clusters
    
    total_individuals = len(df)
    
    # Calculate proportions of reclassifications
    P_up = up_reclassified / total_individuals
    P_down = down_reclassified / total_individuals  # Always 0 in this case
    
    # NRI is just the difference between up and down reclassification
    nri = P_up - P_down
    return nri


from sklearn.metrics import confusion_matrix
# Apply the NRI calculation function to compare the two clustering methods
nri_value = calculate_nri(
    analytic_dataset_cluster, 
    cluster_col_old='published_cluster',  # RMSE method (from ANDIS centroids)
    cluster_col_new='cluster_all'  # K-means clustering method
)

print(f"NRI between 'published_cluster' and 'cluster_all': {nri_value}")

# confusion matrix using the correct label names
conf_matrix = confusion_matrix(
    analytic_dataset_cluster['published_cluster'],  # RMSE method (from ANDIS centroids)
    analytic_dataset_cluster['cluster_all']  # K-means clustering method
)

# Based on the crosstab, the labels should be reordered as follows
cluster_labels_rmse = ['MARD', 'MOD', 'SIDD', 'SIRD']  # Rows: published_cluster (RMSE)
cluster_labels_kmeans = ['MARD', 'MOD', 'SIDD', 'SIRD']  # Columns: cluster_all (K-means)

# Create a DataFrame for better readability of the confusion matrix
conf_matrix_df = pd.DataFrame(conf_matrix, 
                              index=cluster_labels_rmse,  # RMSE cluster labels
                              columns=cluster_labels_kmeans)  # K-means cluster labels

# Display the confusion matrix with correct labels
plt.figure(figsize=(8, 6))
sns.heatmap(conf_matrix_df, annot=True, fmt='d', cmap='Blues')
plt.xlabel('Clusters (K-means)')
plt.ylabel('Clusters (RMSE)')
plt.title('Confusion Matrix: Published Cluster (RMSE) vs. K-means Cluster')
plt.show()

# Filter individuals who were classified as SIDD by k-means but reclassified into MOD or MARD by RMSE method
reclassified_sidd = analytic_dataset_cluster[
    (analytic_dataset_cluster['cluster_all'] == 'SIDD') & 
    (analytic_dataset_cluster['published_cluster'].isin(['MOD', 'MARD']))
]

# Check the number of individuals reclassified from SIDD to MOD or MARD
print("Number of SIDD individuals reclassified to MOD or MARD:")
print(reclassified_sidd['published_cluster'].value_counts())

# Compare the characteristics of these individuals with those who remained in the SIDD cluster in both methods
# We will compare their mean values for the key variables (e.g., HbA1c, BMI, Age, etc.)
sidd_to_mod_or_mard = reclassified_sidd[var_5].mean()
sidd_remained = analytic_dataset_cluster[
    (analytic_dataset_cluster['cluster_all'] == 'SIDD') & 
    (analytic_dataset_cluster['published_cluster'] == 'SIDD')
][var_5].mean()

# Create a DataFrame to compare the means
comparison_df = pd.DataFrame({
    'Reclassified to MOD or MARD': sidd_to_mod_or_mard,
    'Remained in SIDD': sidd_remained
})

# Output the comparison of means between those reclassified and those who remained in SIDD
print("Comparison of characteristics for SIDD individuals reclassified vs. those who remained in SIDD:")
print(comparison_df)

# Optionally, visualize the comparison using a bar plot
import matplotlib.pyplot as plt
comparison_df.plot(kind='bar', figsize=(10, 6), title='Comparison of Reclassified vs. Remained in SIDD')
plt.ylabel('Mean Value')
plt.xticks(rotation=0)
plt.show()