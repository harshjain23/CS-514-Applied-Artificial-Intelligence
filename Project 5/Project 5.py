import numpy as np
import pandas as pd
import lightgbm as lgb
from sklearn.ensemble import RandomForestRegressor
from sklearn.ensemble import ExtraTreesRegressor
from sklearn.model_selection import GridSearchCV
from sklearn.linear_model import LinearRegression
from sklearn.linear_model import BayesianRidge
# from sklearn.neighbors import KNeighborsRegressor
from sklearn.neural_network import MLPRegressor
# from sklearn.svm import SVR

#train = pd.read_csv('train_2016_v2.csv')
#properties = pd.read_csv('properties_2016.csv')
#train = pd.read_csv('train_2017.csv')
#properties = pd.read_csv('properties_2017.csv')
#sample = pd.read_csv('sample_submission.csv')
train = pd.read_csv(r"../input/train_2016_v2.csv")
properties = pd.read_csv(r"../input/properties_2016.csv")
#train2 = pd.read_csv(r"../input/train_2017.csv")
#props2 = pd.read_csv(r"../input/properties_2017.csv")
#frames1 = [train1,train2]
#train = pd.concat(frames1)
#frames2 = [props1,props2]
#properties = pd.concat(frames2)
sample = pd.read_csv(r"../input/sample_submission.csv")


# properties.drop(['basementsqft','buildingclasstypeid','finishedsquarefeet13','storytypeid'], axis=1)
# properties = properties.select_dtypes(exclude=[object])
# train = train.loc[:,['parcelid','logerror']].merge(properties,how='left',left_on='parcelid',right_on='parcelid')
# train_x = train.drop(['parcelid','logerror'],axis=1,inplace=False)
# train_y = train['logerror']
# train_y.fillna(-1,inplace=True)
# train_x.fillna(-1,inplace=True)
# test = sample.loc[:,['ParcelId']].merge(properties,how='left',left_on='ParcelId',right_on='parcelid')
# test_x = test.drop(['ParcelId','parcelid'],axis=1,inplace=False)
# test_x.fillna(-1,inplace=True)

#parameters = {'n_estimators':[15],'n_jobs':[-1],'oob_score':[False]}
#model = RandomForestRegressor()
#parameters = {'n_jobs':[-1]}
#model= LinearRegression()
#parameters = {}
#model= BayesianRidge()
# parameters = {}
# model = MLPRegressor(hidden_layer_sizes=(5,2 ), activation='logistic', solver='adam', alpha=0.0001, batch_size='auto',
#                      learning_rate='constant', learning_rate_init=0.001, power_t=0.5, max_iter=200, shuffle=True, random_state=None,
#                      tol=0.0001, verbose=False, warm_start=False, momentum=0.9, nesterovs_momentum=True, early_stopping=False,
#                      validation_fraction=0.1, beta_1=0.9, beta_2=0.999, epsilon=1e-08)
#parameters = {}
#model = ExtraTreesRegressor(n_estimators=10, max_features=32,random_state=0)
#parameters = {}
#model = SVR(kernel='rbf', C=1e3, gamma=0.1)
#model = SVR(kernel='linear', C=1e3)
#model = SVR(kernel='poly', C=1e3, degree=2)

# grid = GridSearchCV(model,param_grid=parameters,scoring='neg_mean_absolute_error',cv=10)
# grid.fit(train_x,train_y)
#
# cv_results = pd.DataFrame(grid.cv_results_)
# print(cv_results[["mean_test_score"]])

# test_y = grid.predict(test_x)
# test_y = pd.DataFrame(test_y)
# test_y[1] = test_y[0]
# test_y[2] = test_y[0]
# test_y[3] = test_y[0]
# test_y[4] = test_y[0]
# test_y[5] = test_y[0]
# test_y.columns = ["201610","201611","201612","201710","201711","201712"]
# submission = test_y.copy()
# submission["parcelid"] = sample["ParcelId"].copy()
# columns = ["parcelid","201610","201611","201612","201710","201711","201712"]
# submission = submission[columns]
# submission.to_csv("Prediction" + '.csv',index=False)

#------------------- lightgbm ---------------------------------#
#train = pd.read_csv(r"../input/train_2016_v2.csv")
#properties = pd.read_csv(r"../input/properties_2016.csv")
#sample = pd.read_csv(r"../input/sample_submission.csv")

for i, dtype in zip(properties.columns, properties.dtypes):
    if dtype == np.float64:
        properties[i] = properties[i].astype(np.float32)

df_train = train.merge(properties, how='left', on='parcelid')

train_x = df_train.drop(['parcelid', 'logerror', 'transactiondate', 'propertyzoningdesc', 'propertycountylandusecode'], axis=1)
y_train = df_train['logerror'].values

train_columns = train_x.columns

for i in train_x.dtypes[train_x.dtypes == object].index.values:
    train_x[i] = (train_x[i] == True)

split = 90000
train_x, y_train, x_valid, y_valid = train_x[:split], y_train[:split], train_x[split:], y_train[split:]
train_x = train_x.values.astype(np.float32, copy=False)
x_valid = x_valid.values.astype(np.float32, copy=False)

d_train = lgb.Dataset(train_x, label=y_train)
d_valid = lgb.Dataset(x_valid, label=y_valid)

params = {}
params['max_bin'] = 10
params['learning_rate'] = 0.0021
params['boosting_type'] = 'gbdt'
params['objective'] = 'regression'
params['metric'] = '11'
params['sub_feature'] = 0.5
params['bagging_fraction'] = 0.85
params['bagging_freq'] = 40
params['num_leaves'] = 512
params['min_data'] = 500
params['min_hessian'] = 0.05

watchlist = [d_valid]
clf = lgb.train(params, d_train, 430, watchlist)

print("Prepare for the prediction ...")
sample['parcelid'] = sample['ParcelId']
df_test = sample.merge(properties, on='parcelid', how='left')
x_test = df_test[train_columns]
for c in x_test.dtypes[x_test.dtypes == object].index.values:
    x_test[c] = (x_test[c] == True)
x_test = x_test.values.astype(np.float32, copy=False)

clf.reset_parameter({"num_threads":1})
p_test = clf.predict(x_test)

output = pd.read_csv(r"../input/sample_submission.csv")
for c in output.columns[output.columns != 'ParcelId']:
    output[c] = p_test

output.to_csv('Prediction.csv', index=False, float_format='%.4f')