# import the necessary packages
import matplotlib.pyplot as plt
import seaborn as sns
from kneed import KneeLocator
from sklearn.datasets import make_blobs
from sklearn.cluster import KMeans
from sklearn.cluster import AgglomerativeClustering
from scipy.cluster.hierarchy import dendrogram, linkage
from sklearn.metrics import silhouette_score
from sklearn.preprocessing import StandardScaler
import pandas as pd 
import numpy as np
import os as os

if os.getlogin()=="JVARGH7":
    path = 'C:/Cloud/Emory University/li, zhongyu - Diabetes Endotypes Project (JV and ZL)/working/processed/'
    repo = 'C:/code/external/diabetes_endotypes_cohorts/analysis/kmeans'
if os.getlogin()=="zhongyuli":
    path = '/Users/zhongyuli/Desktop/python/cluster analysis/dataset/'



data_6c_imputed = pd.read_csv(path + 'final_dataset_6c_mi_imputed_homa2.csv').dropna() 
data_6c_imputed[:10]
print(data_6c_imputed.shape)
# preprocessing - standardize the data
study_id = data_6c_imputed['study_id']
study = data_6c_imputed['study']

# drop id and study site
data_to_scale = data_6c_imputed[["dmagediag","bmi","hba1c","homa2b","homa2ir",
                                 "ldlc","hdlc","tgl","sbp","dbp","ratio_th"]]
scaler = StandardScaler() 
scaled_data = scaler.fit_transform(data_to_scale)

# Convert scaled data back to a DataFrame and add study_id and study back

scaled_data_df = pd.DataFrame(scaled_data, columns=data_to_scale.columns)
scaled_data_df['study_id'] = study_id.values
scaled_data_df['study'] = study.values
print(scaled_data_df[:5])


# Select initial centroids for k-means based on hierarchical clustering
# Perform hierarchical clustering with k clusters

k = 4

# select five variables to cluster
selected_variables = ['bmi', 'hba1c', 'dmagediag','homa2b','homa2ir']
data_to_cluster = scaled_data_df[selected_variables]

X = data_to_cluster.values
Z = linkage(X, method='ward')
agg_clustering = AgglomerativeClustering(n_clusters=k, linkage='ward')
agg_labels = agg_clustering.fit_predict(X)

# Calculate the centroids based on the hierarchical clustering
initial_centroids = np.array([X[agg_labels == i].mean(axis=0) for i in range(k)])
print(initial_centroids)

kmeans = KMeans(
    init=initial_centroids, n_clusters=4, n_init=10, max_iter=300, random_state=57
)

kmeans.fit(data_to_cluster)

# Add the labels to the scaled dataset
scaled_data_df['cluster'] = kmeans.labels_

kmeans.inertia_
kmeans.cluster_centers_


kmeans_kwargs = { # set the parameters for the kmeans algorithm
    "init": "random",
    "n_init": 10,
    "max_iter": 300,
    "random_state": 57,
}

# A list holds the SSE values for each k
sse = [] #initiate an empty list to store the sum of squared errors 
for k in range(1, 11):
    kmeans = KMeans(n_clusters=k, **kmeans_kwargs)
    kmeans.fit(data_to_cluster)
    sse.append(kmeans.inertia_)

# Determining the elbow point in the SSE curve isn’t always straightforward. 
# If you’re having trouble choosing the elbow point of the curve, then you could use a Python package:
# kneed, to identify the elbow point programmatically:

kl = KneeLocator(range(1, 11), sse, curve="convex", direction="decreasing")
print("Elbow point:" + str(kl.elbow)) # returns the elbow point
cluster_summary = scaled_data_df.groupby('cluster').describe()
print(cluster_summary)
data_to_plot = scaled_data_df[selected_variables + ['cluster']]


# add cluster labels to the original dataset
data_6c_imputed['cluster'] = scaled_data_df['cluster']
# summarize the data by cluster, show the mean of each variable

# Summary of clusters
cluster_summary_or_homa2 = data_6c_imputed[selected_variables + ['cluster']].groupby('cluster').mean()
print(cluster_summary_or_homa2)
# save the summary data
cluster_summary_or_homa2.to_csv(repo + 'analysis/kmeans/decan_kmeans01_cluster_summary_or_homa2.csv') 

data_6c_imputed.to_csv(path + 'decan_kmeans01_data_6c_imputed with cluster labels.csv')
