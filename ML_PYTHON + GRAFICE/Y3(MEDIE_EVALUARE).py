import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score, mean_squared_error
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
df = pd.read_csv('Y3_MEDIE_EVALUARE_INTEROGARE_SIMPLA.csv')
print("Toate randurile din date:")
print(df.to_string())
plt.figure(figsize=(8, 6))
sns.heatmap(df.corr(), annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Corelatii Y3 MEDIE_EVALUARE")
plt.xticks(rotation=45, ha='right')
plt.yticks(rotation=0)
plt.tight_layout()
plt.savefig('Y3_heatmap_corelatii.png', dpi=150)
plt.show()
X = df[["X1_Luna", "X2_ID_Articol", "X3_NR_Comentarii", "X4_Rata_Comentare"]]
y = df["Y_MEDIE_EVALUARE"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
model = LinearRegression()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
print("\nRezultate Regresie Liniara Y3:")
print(f"  R2: {r2_score(y_test, y_pred):.3f}")
print(f"  RMSE: {np.sqrt(mean_squared_error(y_test, y_pred)):.3f}")
print(f"  Coeficienti: {model.coef_}")
print(f"  Intercept: {model.intercept_}")
plt.figure(figsize=(8, 5))
sns.scatterplot(x=df["X3_NR_Comentarii"], y=df["Y_MEDIE_EVALUARE"], label="Date reale")
sns.lineplot(x=df["X3_NR_Comentarii"], y=model.predict(X), color="red", label="Regresie")
plt.xlabel("X3_NR_Comentarii")
plt.ylabel("Y_MEDIE_EVALUARE")
plt.title("Relatia MEDIE_EVALUARE = f(NR_COMENTARII)")
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.legend()
plt.savefig('Y3_grafic_regresie.png', dpi=150)
plt.show()