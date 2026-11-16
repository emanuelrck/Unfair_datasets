"""Group ratio (GR), imbalance ratio (IR) and number of available instances of each
dataset / sensitive attribute combination, with the binarisation used in the experiment
scripts (Table 2 of the paper). GR is the proportion of the protected group and IR the
proportion of the positive class. Run from the repository root: python table_gr_ir.py
"""
import pandas as pd

rows = []


def add(dataset, attribute, group, target, protected, positive, n_subdataset):
    mask = group.notna() & target.notna()
    group, target = group[mask], target[mask]
    rows.append((dataset, attribute, len(group), round((group == protected).mean(), 2),
                 round((target == positive).mean(), 2), n_subdataset))


# Adult: protected = not White / Female; positive = income > 50K
a = pd.read_csv('data/adult.data', sep=', ', engine='python', na_values=['?'], header=None)
add('Adult', 'Race', a[8].where(a[8] == 'White', 'notwhite'), a[14], 'notwhite', '>50K', 1400)
add('Adult', 'Sex', a[9], a[14], 'Female', '>50K', 2100)

# Bank Marketing: protected = not adult (age < 25 or >= 60); positive = subscribed
b = pd.read_csv('data/bank-full.csv', sep=';')
age = b['age'].apply(lambda x: 'adult' if 25 <= x < 60 else 'notAdult')
add('Bank Marketing', 'Age', age, b['y'], 'notAdult', 'yes', 1500)

# COMPAS: protected = Female / not White / not adult; positive = recidivism (event = 1)
c = pd.read_csv('data/compasTransformed.data', sep=';')
add('COMPAS', 'Sex', c['sex'], c['event'], 'Female', 1, 1000)
add('COMPAS', 'Race', c['race'], c['event'], 'notWhite', 1, 2000)
add('COMPAS', 'Age', c['age_cat'], c['event'], 'notAdult', 1, 2800)

# Credit Card Default: protected = not adult / SEX = 1 (male); positive = default
cc = pd.read_csv('data/default of credit card clients.csv', sep=';')
age = cc['AGE'].apply(lambda x: 'adult' if 25 <= x < 60 else 'notAdult')
add('Credit Card Default', 'Age', age, cc['default payment next month'], 'notAdult', 1, 1500)
add('Credit Card Default', 'Sex', cc['SEX'], cc['default payment next month'], 1, 1, 5000)

# Crime: protected = high proportion of black population; positive = high violent crime rate
cr = pd.read_csv('data/crimeTransformed.data', sep=';', na_values='NA')
add('Crime', 'Race', cr['race'], cr['crime'], 'high', 'high', 102)

# Law School: protected = woman / non-white; positive = did not pass the bar (pass_bar = 0)
l = pd.read_csv('data/lawTransformed.data', sep=';')
add('Law School', 'Sex', l['male'], l['pass_bar'], 'mulher', 0, 1500)
add('Law School', 'Race', l['racetxt'], l['pass_bar'], 0, 0, 800)

# German Credit: protected = female / young (age <= 25); positive = bad credit (class 2)
g = pd.read_csv('data/german.data', sep=',')
add('German Credit', 'Sex', g['sex9'], g['classlabel21'], 'female', 2, 200)
age = g['Age13'].apply(lambda x: 'young' if x <= 25 else 'adult')
add('German Credit', 'Age', age, g['classlabel21'], 'young', 2, 150)

table = pd.DataFrame(rows, columns=['Dataset', 'Sensitive attribute', 'Instances', 'GR', 'IR', 'n'])
print(table.to_string(index=False))
