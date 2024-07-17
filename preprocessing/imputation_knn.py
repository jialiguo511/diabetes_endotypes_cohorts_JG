# the purpose of this python file is to impute missing values using k nearest neighbors
# the original data is the final_dataset_6c_mi.csv in which everyone has no missing values in age, bmi, and hba1c. 


# load libraries
import numpy as np
import pandas as pd
from sklearn.impute import KNNImputer

# load the data

# change the path to the location of the dataset. Zhongyu uses a MacBook so it cannot read (but can write into) the path from the OneDrive folder.
path = '/Users/zhongyuli/Desktop/python/cluster analysis/dataset/final_dataset_6c_mi.csv'
data_mi = pd.read_csv(path) 

#select variables 
selected_variables = ['study_id','bmi', 'hba1c', 'dmagediag','insulinf2','glucosef2','tgl','ldlc','ratio_th','sbp','dbp','hdlc','study','race','female']

#drop missing values in the selected variables
data_mi = data_mi[selected_variables]

data_mi.head()



############### Do KNN Imputation with K = 5 by Study Sites #####################
columns_to_impute = ['bmi', 'dmagediag', 'hba1c', 'insulinf2', 'glucosef2', 'tgl', 'ldlc', 'ratio_th', 'sbp', 'dbp', 'hdlc']

# Function to impute data for one study site
def impute_study_data(data, n_neighbors=5):
    imputer = KNNImputer(n_neighbors=n_neighbors)
    data[columns_to_impute] = imputer.fit_transform(data[columns_to_impute])
    return data
# Impute data for each study site
study_sites = data_mi['study'].unique()
imputed_datasets = []

for site in study_sites:
    site_data = data_mi[data_mi['study'] == site].copy()
    imputed_data = impute_study_data(site_data)
    imputed_datasets.append(imputed_data)

# Merge all imputed datasets back to one
imputed_data_merged = pd.concat(imputed_datasets)

# Check if there are any missing values
print(imputed_data_merged.isnull().sum())
print(data_mi.isnull().sum())
# compare the imputed data with the original data
data_mi.describe()
imputed_data_merged.describe()

# save the imputed data
path_folder = '/Users/zhongyuli/Library/CloudStorage/OneDrive-EmoryUniversity/Diabetes Endotypes Project (JV and ZL)'
imputed_data_merged.to_csv(path_folder + '/working/processed/final_dataset_6c_mi_imputed.csv', index=False)

#### before running the kmeans clustering, we need to use the homa calculator to calculate the HOMA2IR and HOMA2B values and add to the imputed dataset. 














