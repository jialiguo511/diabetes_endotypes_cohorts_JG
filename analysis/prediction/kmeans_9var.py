# The purpose of this python file is to run k means on nine variables: age of diagnosis, bmi, HbA1c, hdl, ldl, sbp, dbp, tgl, and ratio_th

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


path = '/Users/zhongyuli/Desktop/python/cluster analysis/dataset/final_dataset_6c_cc_homa2.csv'

analytic_dataset = pd.read_csv(path) 

#select variables 
selected_variables = ['bmi', 'hba1c', 'dmagediag','homa2b','homa2ir','tgl','ldlc','ratio_th','sbp','dbp','hdlc','study','race','female']

#drop missing values in the selected variables
analytic_dataset = analytic_dataset[selected_variables]
analytic_dataset = analytic_dataset.dropna()

#check the data
analytic_dataset.head()

study = analytic_dataset['study']
race = analytic_dataset['race']
female = analytic_dataset['female']
# drop the variables: study, race, and female
analytic_dataset = analytic_dataset.drop(columns = ['study','race','female'])
analytic_dataset.shape

#check if any missing values
analytic_dataset.isnull().sum()
#check variable types
analytic_dataset.dtypes

#run kmeans clustering to create the TRUE labels
#standardize the data
scaler = StandardScaler()
data_scaled = scaler.fit_transform(analytic_dataset)

data_scaled = pd.DataFrame(data_scaled, columns=analytic_dataset.columns)

data_scaled.head()

# run kmeans and get cluster labels from the five variable method (method 3)
kmeans = KMeans(
    init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57
)

# select nine variables to cluster
var_9 = ['bmi', 'hba1c', 'dmagediag','sbp','dbp','tgl','ldlc','ratio_th','hdlc']
cluster_v9 = data_scaled[var_9]

kmeans = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans.fit(cluster_v9)

# summarize the cluster labels to the original dataset
analytic_dataset_cluster = analytic_dataset.copy()
analytic_dataset_cluster['cluster'] = kmeans.labels_
analytic_dataset_cluster.groupby('cluster').mean()

# relabel the cluster labels 
analytic_dataset_cluster['cluster'] = analytic_dataset_cluster['cluster'].replace({0:'MOD', 1:'SIRD', 2:'SIDD', 3:'MARD'})
analytic_dataset_cluster['cluster'].value_counts()

# add study, race, and female back to the dataset
analytic_dataset_cluster['study'] = study
analytic_dataset_cluster['race'] = race
analytic_dataset_cluster['female'] = female

# plot the clusters
# add the cluster labels to the copy of the scaled data

data_scaled_cluster = data_scaled.copy()
data_scaled_cluster['cluster'] = kmeans.labels_
# relabel the cluster labels
data_scaled_cluster['cluster'] = data_scaled_cluster['cluster'].replace({0:'MOD', 1:'SIRD', 2:'SIDD', 3:'MARD'})

import seaborn as sns
# Create a new DataFrame with the cluster assignments and variables
data_clustered = pd.concat([data_scaled_cluster['cluster'], data_scaled_cluster[['bmi', 'hba1c', 'dmagediag', 'homa2b', 'homa2ir','sbp','dbp','tgl','ldlc','ratio_th','hdlc']]], axis=1)

# Melt the DataFrame to convert it into long format
data_melted = data_clustered.melt(id_vars='cluster', var_name='Variable', value_name='Value')

# Create the boxplot
plt.figure(figsize=(10, 6))
sns.boxplot(x='cluster', y='Value', hue='Variable', data=data_melted)
plt.title('Variables by Clusters')
plt.xlabel('Cluster')
plt.ylabel('Value')
plt.xticks(rotation=45)
plt.show()

# show race, study, and female by clusters 
# Create a new DataFrame with the cluster assignments and variables

analytic_dataset_cluster.head()