# The purpose of this python file is to compared the kmeans clustering results from the the 5 var methods from the analytic sample and the complete case sample

# This scripts will run kmeans clustering on the dataset with imputed missing values using KNN imputation.
# KNN imputation is conducted in a separate script. 
# load libraries
import pandas as pd 
import numpy as np
import os as os

import matplotlib.pyplot as plt
import seaborn as sns
from kneed import KneeLocator
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler

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


path_imputed = '/Users/zhongyuli/Desktop/python/cluster analysis/dataset/final_dataset_6c_mi_imputed_homa2.csv'

imputed_dataset = pd.read_csv(path_imputed) 

path_cc = '/Users/zhongyuli/Desktop/python/cluster analysis/dataset/final_dataset_6c_cc_homa2.csv'

complete_case_dataset = pd.read_csv(path_cc) 

#select variables 
selected_variables = ['study_id','bmi', 'hba1c', 'dmagediag','homa2b','homa2ir','tgl','ldlc','ratio_th','sbp','dbp','hdlc','study','race','female']

#drop missing values in the selected variables
imputed_dataset = imputed_dataset[selected_variables]
imputed_dataset = imputed_dataset.dropna()

complete_case_dataset = complete_case_dataset[selected_variables]
complete_case_dataset = complete_case_dataset.dropna()


# Ensure the 'study_id' column exists in both datasets for merging
imputed_dataset = imputed_dataset.dropna(subset=['study_id'])
complete_case_dataset = complete_case_dataset.dropna(subset=['study_id'])

# Select relevant variables for clustering
var_5 = ['bmi', 'hba1c', 'dmagediag', 'homa2b', 'homa2ir']

# Standardize the datasets
scaler = StandardScaler()
imputed_scaled = scaler.fit_transform(imputed_dataset[var_5])
complete_case_scaled = scaler.fit_transform(complete_case_dataset[var_5])

# Perform KMeans clustering on the imputed dataset
kmeans_imputed = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_imputed.fit(imputed_scaled)
imputed_dataset['cluster'] = kmeans_imputed.labels_

# Perform KMeans clustering on the complete case dataset
kmeans_complete_case = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_complete_case.fit(complete_case_scaled)
complete_case_dataset['cluster'] = kmeans_complete_case.labels_

# check the cluster labels
imputed_dataset['cluster'].value_counts()
complete_case_dataset['cluster'].value_counts()

# check the mean values for the five variables in each cluster and relabel the clusters
imputed_dataset.groupby('cluster')[var_5].mean()
imputed_dataset['cluster'] = imputed_dataset['cluster'].replace({0:'MOD', 1:'SIRD', 2:'MARD', 3:'SIDD'})


complete_case_dataset.groupby('cluster')[var_5].mean()
complete_case_dataset['cluster'] = complete_case_dataset['cluster'].replace({0:'SIDD', 1:'MARD', 2:'SIRD', 3:'MOD'})

# Ensure the correct order to match the table in the manuscript
order_5var = ['SIDD', 'SIRD', 'MOD', 'MARD']
imputed_dataset['cluster'] = pd.Categorical(imputed_dataset['cluster'], categories=order_5var, ordered=True)
complete_case_dataset['cluster'] = pd.Categorical(complete_case_dataset['cluster'], categories=order_5var, ordered=True)

# Merge the two datasets to compare cluster assignments
comparison_df = pd.merge(imputed_dataset[['study_id', 'cluster']], complete_case_dataset[['study_id', 'cluster']], on='study_id', suffixes=('_imputed', '_complete_case'))

# Create a cross-tabulation to show the number of observations in each cluster for both datasets
contingency_table = pd.crosstab(comparison_df['cluster_imputed'], comparison_df['cluster_complete_case'], margins=True)
print(contingency_table)

# Save the contingency table to a CSV file
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
contingency_table.to_csv(path_folder + '/working/processed/dec_an08c_contingency_table_comparison.csv')