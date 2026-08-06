# Lab: EDA Challenge

## Prerequisites
- Python 3.10+
- Pandas
- Matplotlib
- Seaborn

## Setup

```bash
python -m venv .work.mlt/labs/eda-challenge/.venv
source .work.mlt/labs/eda-challenge/.venv/bin/activate
pip install pandas matplotlib seaborn
```

## Objectives
- Profile a real dataset: shape, dtypes, missing values
- Handle missing data and inspect distributions
- Quantify correlations and relationships between variables
- Produce 3+ plots and summarize findings in writing

## Code

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Seaborn's built-in 'titanic' dataset (~80KB, one-time download).
# It ships with real missing values in age, deck, embarked, and embark_town.
df = sns.load_dataset('titanic')

# --- 1. Profile the data ---
print("Shape:", df.shape)
print("\nDtypes:")
print(df.dtypes)
print("\nFirst rows:")
print(df.head())

print("\nMissing values per column:")
missing = df.isna().sum()
print(missing[missing > 0])
print("\nMissing percentage:")
print((df.isna().mean() * 100).round(1))

# --- 2. Handle missing values ---
# 'deck' is >70% missing: drop the column. Fill 'age' with the median,
# fill 'embarked'/'embark_town' with the mode (most frequent value).
df = df.drop(columns=['deck'])
df['age'] = df['age'].fillna(df['age'].median())
df['embarked'] = df['embarked'].fillna(df['embarked'].mode()[0])
df['embark_town'] = df['embark_town'].fillna(df['embark_town'].mode()[0])
print("\nMissing after cleaning:", df.isna().sum().sum())

# --- 3. Distributions and summary statistics ---
print("\nNumeric summary:")
print(df.describe())
print("\nSurvival rate by class:")
print(df.groupby('pclass')['survived'].mean().round(3))
print("\nSurvival rate by sex:")
print(df.groupby('sex')['survived'].mean().round(3))

# --- 4. Plots (3+) ---
fig, axes = plt.subplots(2, 2, figsize=(12, 9))

# Plot 1: age distribution, split by survival
axes[0, 0].hist(df[df['survived'] == 1]['age'], bins=25, alpha=0.6, label='Survived')
axes[0, 0].hist(df[df['survived'] == 0]['age'], bins=25, alpha=0.6, label='Died')
axes[0, 0].set_xlabel('Age')
axes[0, 0].set_ylabel('Count')
axes[0, 0].set_title('Age Distribution by Survival')
axes[0, 0].legend()

# Plot 2: fare distribution by passenger class
sns.boxplot(x='pclass', y='fare', data=df, ax=axes[0, 1])
axes[0, 1].set_title('Fare by Passenger Class')

# Plot 3: survival count by sex
sns.countplot(x='sex', hue='survived', data=df, ax=axes[1, 0])
axes[1, 0].set_title('Survival Count by Sex')

# Plot 4: correlation heatmap of numeric features
numeric_df = df.select_dtypes(include='number')
sns.heatmap(numeric_df.corr(), annot=True, cmap='coolwarm', center=0, ax=axes[1, 1])
axes[1, 1].set_title('Correlation Heatmap')

plt.tight_layout()
plt.savefig('eda_titanic.png', dpi=100)
plt.show()

# --- 5. Written findings ---
print("\nFindings:")
print("1. Overall survival rate:", round(df['survived'].mean(), 3))
print("2. Female survival rate vs male:",
      round(df[df['sex'] == 'female']['survived'].mean(), 3), "vs",
      round(df[df['sex'] == 'male']['survived'].mean(), 3))
print("3. 1st class survival vs 3rd class:",
      round(df[df['pclass'] == 1]['survived'].mean(), 3), "vs",
      round(df[df['pclass'] == 3]['survived'].mean(), 3))
print("4. Strongest numeric correlate of survival:",
      numeric_df.corr()['survived'].drop('survived').abs().idxmax())
```

## Expected Output
- Shape `(891, 15)`; missing values reported in `age` (~20%), `deck` (~77%), `embarked`/`embark_town` (2 rows)
- Missing values after cleaning: 0
- Survival rates near 0.38 overall, ~0.74 female vs ~0.19 male, ~0.63 1st class vs ~0.24 3rd class
- A 2x2 figure saved as `eda_titanic.png` with age histogram, fare boxplot, survival countplot, and correlation heatmap
- Printed findings identifying sex/class as the dominant survival factors

## Troubleshooting
- `URLError` on `sns.load_dataset`: the built-in datasets download once from GitHub; check network access or run behind a proxy with `HTTPS_PROXY` set
- Blank plot window on headless machines: run with a non-interactive backend (`MPLBACKEND=Agg python eda.py`) and rely on the saved PNG
- `FutureWarning` from seaborn on boxplot/countplot args: harmless; pass `hue` and `legend=False` if a newer seaborn emits warnings
- `ModuleNotFoundError: seaborn`: activate the venv before running, or `pip install seaborn` again

## Cleanup
```bash
deactivate
rm -rf .work.mlt/labs/eda-challenge/.venv
rm -f eda_titanic.png
```
