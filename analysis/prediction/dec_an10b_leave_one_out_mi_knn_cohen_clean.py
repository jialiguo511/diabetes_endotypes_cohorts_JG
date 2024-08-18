##### this script is to perform sensitivity analysis by excluding each study site one at a time using Cohen's Kappa 

import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import cohen_kappa_score

# Load the data
path = '/Users/zhongyuli/Desktop/python/cluster analysis/dataset/final_dataset_6c_clean_mi_imputed_homa2.csv'
analytic_dataset = pd.read_csv(path)

# Select variables
selected_variables = ['study_id', 'bmi', 'hba1c', 'dmagediag', 'homa2b', 'homa2ir', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc', 'study', 'race', 'female']

# Drop missing values in the selected variables
analytic_dataset = analytic_dataset[selected_variables]
analytic_dataset = analytic_dataset.dropna()

study_sites = ['aric', 'cardia', 'dpp', 'dppos', 'jhs', 'mesa']

# Standardize the entire dataset
scaler = StandardScaler()
var_5 = ['bmi', 'hba1c', 'dmagediag', 'homa2b', 'homa2ir']
cluster_v5 = scaler.fit_transform(analytic_dataset[var_5])

# Perform KMeans clustering on the entire dataset
kmeans = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans.fit(cluster_v5)
original_labels = kmeans.labels_

# add the original cluster labels to the analytic dataset
analytic_dataset['cluster'] = original_labels
# check the mean values of the variables in each cluster 
print(analytic_dataset.groupby('cluster')[var_5].mean())

# Relabel the original labels to the true labels
relabelled_original_labels = pd.Series(original_labels).map({
    0: "MOD",  
    1: "SIRD",  
    2: "SIDD",  
    3: "MARD"  
})
# Print the relabeled clusters to verify
print("Relabeled Original Labels:")
print(relabelled_original_labels.value_counts())

results = []

# Step 1: Exclude study site "aric"
study_site_1 = 'aric'
excluded_dataset_1 = analytic_dataset[analytic_dataset['study'] != study_site_1]
excluded_cluster_v5_1 = scaler.fit_transform(excluded_dataset_1[var_5])
kmeans_excluded_1 = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_excluded_1.fit(excluded_cluster_v5_1)
excluded_labels_1 = kmeans_excluded_1.labels_
# add the cluster labels to the excluded dataset
excluded_dataset_1['cluster'] = excluded_labels_1
# check the mean values of the variables in each cluster
print(excluded_dataset_1.groupby('cluster')[var_5].mean())

# relabel the excluded labels
relabelled_excluded_labels_1 = pd.Series(excluded_labels_1).map({
    0: "SIRD",  
    1: "MOD",  
    2: "SIDD",  
    3: "MARD"  
})
# Print the relabeled clusters to verify
print("Relabeled Excluded Labels:")
print(relabelled_excluded_labels_1.value_counts())

relabelled_original_labels = relabelled_original_labels.reset_index(drop=True)
analytic_dataset = analytic_dataset.reset_index(drop=True)

original_labels_excluded_1 = relabelled_original_labels[analytic_dataset['study'] != study_site_1]
kappa_1 = cohen_kappa_score(original_labels_excluded_1, relabelled_excluded_labels_1)
results.append({'Study Site Removed': study_site_1, 'Sample Size': len(excluded_dataset_1), 'Cohen\'s Kappa': kappa_1})


# Step 2: Exclude study site "cardia"
study_site_2 = 'cardia'
excluded_dataset_2 = analytic_dataset[analytic_dataset['study'] != study_site_2]
excluded_cluster_v5_2 = scaler.fit_transform(excluded_dataset_2[var_5])
kmeans_excluded_2 = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_excluded_2.fit(excluded_cluster_v5_2)
excluded_labels_2 = kmeans_excluded_2.labels_
# add the cluster labels to the excluded dataset
excluded_dataset_2['cluster'] = excluded_labels_2
# check the mean values of the variables in each cluster
print(excluded_dataset_2.groupby('cluster')[var_5].mean())
# relabel the excluded labels
relabelled_excluded_labels_2 = pd.Series(excluded_labels_2).map({
    0: "MOD",  
    1: "MARD",  
    2: "SIRD",  
    3: "SIDD"  
})
# Print the relabeled clusters to verify
print("Relabeled Excluded Labels:")
print(relabelled_excluded_labels_2.value_counts())


original_labels_excluded_2 = relabelled_original_labels[analytic_dataset['study'] != study_site_2]
kappa_2 = cohen_kappa_score(original_labels_excluded_2, relabelled_excluded_labels_2)
results.append({'Study Site Removed': study_site_2, 'Sample Size': len(excluded_dataset_2), 'Cohen\'s Kappa': kappa_2})




# Step 3: Exclude study site "dpp"
study_site_3 = 'dpp'
excluded_dataset_3 = analytic_dataset[analytic_dataset['study'] != study_site_3]
excluded_cluster_v5_3 = scaler.fit_transform(excluded_dataset_3[var_5])
kmeans_excluded_3 = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_excluded_3.fit(excluded_cluster_v5_3)
excluded_labels_3 = kmeans_excluded_3.labels_
# add the cluster labels to the excluded dataset
excluded_dataset_3['cluster'] = excluded_labels_3
# check the mean values of the variables in each cluster
print(excluded_dataset_3.groupby('cluster')[var_5].mean())
# relabel the excluded labels
relabelled_excluded_labels_3 = pd.Series(excluded_labels_3).map({
    0: "MOD",  
    1: "SIRD",  
    2: "MARD",  
    3: "SIDD"  
})
# Print the relabeled clusters to verify
print("Relabeled Excluded Labels:")
print(relabelled_excluded_labels_3.value_counts())


original_labels_excluded_3 = relabelled_original_labels[analytic_dataset['study'] != study_site_3]
kappa_3 = cohen_kappa_score(original_labels_excluded_3, relabelled_excluded_labels_3)
results.append({'Study Site Removed': study_site_3, 'Sample Size': len(excluded_dataset_3), 'Cohen\'s Kappa': kappa_3})



# Step 4: Exclude study site "dppos"
study_site_4 = 'dppos'
excluded_dataset_4 = analytic_dataset[analytic_dataset['study'] != study_site_4]
excluded_cluster_v5_4 = scaler.fit_transform(excluded_dataset_4[var_5])
kmeans_excluded_4 = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_excluded_4.fit(excluded_cluster_v5_4)
excluded_labels_4 = kmeans_excluded_4.labels_

# add the cluster labels to the excluded dataset
excluded_dataset_4['cluster'] = excluded_labels_4
# check the mean values of the variables in each cluster
print(excluded_dataset_4.groupby('cluster')[var_5].mean())
# relabel the excluded labels
relabelled_excluded_labels_4 = pd.Series(excluded_labels_4).map({
    0: "SIDD",  
    1: "MOD",  
    2: "MARD",  
    3: "SIRD"  
})
# Print the relabeled clusters to verify
print("Relabeled Excluded Labels:")
print(relabelled_excluded_labels_4.value_counts())


original_labels_excluded_4 = relabelled_original_labels[analytic_dataset['study'] != study_site_4]
kappa_4 = cohen_kappa_score(original_labels_excluded_4, relabelled_excluded_labels_4)
results.append({'Study Site Removed': study_site_4, 'Sample Size': len(excluded_dataset_4), 'Cohen\'s Kappa': kappa_4})

# Step 5: Exclude study site "jhs"
study_site_5 = 'jhs'
excluded_dataset_5 = analytic_dataset[analytic_dataset['study'] != study_site_5]
excluded_cluster_v5_5 = scaler.fit_transform(excluded_dataset_5[var_5])
kmeans_excluded_5 = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_excluded_5.fit(excluded_cluster_v5_5)
excluded_labels_5 = kmeans_excluded_5.labels_

# add the cluster labels to the excluded dataset
excluded_dataset_5['cluster'] = excluded_labels_5
# check the mean values of the variables in each cluster
print(excluded_dataset_5.groupby('cluster')[var_5].mean())
# relabel the excluded labels
relabelled_excluded_labels_5 = pd.Series(excluded_labels_5).map({
    0: "MARD",  
    1: "SIDD",  
    2: "MOD",  
    3: "SIRD"  
})
# Print the relabeled clusters to verify
print("Relabeled Excluded Labels:")
print(relabelled_excluded_labels_5.value_counts())


original_labels_excluded_5 = relabelled_original_labels[analytic_dataset['study'] != study_site_5]
kappa_5 = cohen_kappa_score(original_labels_excluded_5, relabelled_excluded_labels_5)
results.append({'Study Site Removed': study_site_5, 'Sample Size': len(excluded_dataset_5), 'Cohen\'s Kappa': kappa_5})

# Step 6: Exclude study site "mesa"
study_site_6 = 'mesa'
excluded_dataset_6 = analytic_dataset[analytic_dataset['study'] != study_site_6]
excluded_cluster_v5_6 = scaler.fit_transform(excluded_dataset_6[var_5])
kmeans_excluded_6 = KMeans(init="random", n_clusters=4, n_init=10, max_iter=300, random_state=57)
kmeans_excluded_6.fit(excluded_cluster_v5_6)
excluded_labels_6 = kmeans_excluded_6.labels_

# add the cluster labels to the excluded dataset
excluded_dataset_6['cluster'] = excluded_labels_6
# check the mean values of the variables in each cluster
print(excluded_dataset_6.groupby('cluster')[var_5].mean())
# relabel the excluded labels
relabelled_excluded_labels_6 = pd.Series(excluded_labels_6).map({
    0: "SIRD",  
    1: "MARD",  
    2: "MOD",  
    3: "SIDD"  
})
# Print the relabeled clusters to verify
print("Relabeled Excluded Labels:")
print(relabelled_excluded_labels_6.value_counts())


original_labels_excluded_6 = relabelled_original_labels[analytic_dataset['study'] != study_site_6]
kappa_6 = cohen_kappa_score(original_labels_excluded_6, relabelled_excluded_labels_6)
results.append({'Study Site Removed': study_site_6, 'Sample Size': len(excluded_dataset_6), 'Cohen\'s Kappa': kappa_6})

# Convert results to DataFrame
results_df = pd.DataFrame(results)

# Define the desired order
results_df['Study Site Removed'] = pd.Categorical(results_df['Study Site Removed'])
results_df = results_df.sort_values('Study Site Removed')

# Print the results
print(results_df)

# Save results to a CSV file
results_df.to_csv('/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)/working/processed/dec_an10b_sensitivity_analysis_results_cohen_clean.csv', index=False)