import pandas as pd
import numpy as np
import csv
from sklearn import datasets, linear_model
from sklearn.model_selection import train_test_split, cross_val_score, cross_val_predict
from matplotlib import pyplot as plt
from sklearn import metrics, preprocessing
from sklearn.impute import SimpleImputer

#Reading Data from csv, placing it into working format

print("Note: Above 40% cancellation is a decent chance at cancellation.")
print("Woe be to those on March 13, 2006, for which our model predicted 100% cancellation")

precip_Jan = .98/31
precip_Feb = 1.38/28
precip_Mar = 2.72/31

while True:
    month = input("Please input the month (J, F, M):\n")
    if (month == 'J' or month == 'F' or month == 'M'):
        break

while True:
    raw_inp = input("Please input the predicted wind speed, PoP in decimal, max temperature, and min temperature, with one space between them\n")
    raw_sample = raw_inp.split()
    inp_sample = []
    for f in raw_sample:
        try:
            inp_sample.append(float(f))
        except ValueError:
            pass
    g=0
    if (len(inp_sample) == 4):
        for f in inp_sample:
            if type(f) == type(1.0):
                g+= 1
    if (g == 4):
        break
            

raw_sample = []

for s in inp_sample:
    raw_sample.append(float(s))

if (month=="J"):
    raw_sample[1] = precip_Jan * raw_sample[1]
if (month=="F"):
    raw_sample[1] = precip_Feb * raw_sample[1]
if (month=="M"):
    raw_sample[1] = precip_Mar * raw_sample[1]

columns = "Wind_Speed Precipitation Max_Temperature Min_Temperature".split(" ")

samples = 209

data = np.empty((samples, 4))
prediction = np.zeros((samples,1))

for i in range(0, 29):
    prediction[i] = 1

successReader = csv.reader(open('successes.csv', newline =''))

i = 0
for row in successReader:
    data[i] = row
    i+=1

failureReader = csv.reader(open('failures.csv', newline=''))

for row in failureReader:
    data[i] = row
    i+=1

data[208] = raw_sample

imp = SimpleImputer(missing_values=np.nan, strategy='mean')

data = imp.fit_transform(data)

df = pd.DataFrame(data, columns=columns)

target = pd.DataFrame(prediction, columns=["Prediction"])

X = df
y = target["Prediction"]

X_train, X_test, y_train, y_test = train_test_split(df, y, test_size=0.2)

scaler = preprocessing.StandardScaler().fit(X_train)
X_scaled = scaler.transform(X_train)
X_test_scaled = scaler.transform(X_test)

lm = linear_model.LinearRegression()
model = lm.fit(X_train,y_train)

scores = cross_val_score(model, X, y, cv=samples)

predictions = cross_val_predict(model, X, y, cv=samples)
predictions = predictions.reshape(-1,1)

min_max_scaler = preprocessing.MinMaxScaler()
pred_new = min_max_scaler.fit_transform(predictions)

print("School has a %", pred_new[208], "chance of cancellation that day.")
'''
accuracy = metrics.r2_score(y, pred_new)

print(accuracy)

print(np.argmax(pred_new))

plt.scatter(y, pred_new)
plt.xlabel("True Values")
plt.ylabel("Predictions")
plt.show()
'''

