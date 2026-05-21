import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score, mean_squared_error
import numpy as np
import seaborn as sns
import matplotlib.pyplot as plt
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)
df = pd.read_csv('Y4_RATA_RETENTIE_CTE.csv')
print("Toate randurile din date:")
print(df.to_string())
plt.figure(figsize=(8, 6))
sns.heatmap(df.corr(), annot=True, cmap="coolwarm", fmt=".2f")
plt.title("Corelatii Y4 RATA_RETENTIE")
plt.xticks(rotation=45, ha='right')
plt.yticks(rotation=0)
plt.tight_layout()
plt.savefig('Y4_heatmap_corelatii.png', dpi=150)
plt.show()
X = df[["X1_Luna", "X2_ID_Utilizator", "X3_NR_Sesiuni_Active", "X4_Rata_Autentificare"]]
y = df["Y_RATA_RETENTIE"]
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.3, random_state=42)
model = LinearRegression()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)
print("\nRezultate Regresie Liniara Y4:")
print(f"  R2: {r2_score(y_test, y_pred):.3f}")
print(f"  RMSE: {np.sqrt(mean_squared_error(y_test, y_pred)):.3f}")
print(f"  Coeficienti: {model.coef_}")
print(f"  Intercept: {model.intercept_}")
plt.figure(figsize=(8, 5))
sns.scatterplot(x=df["X3_NR_Sesiuni_Active"], y=df["Y_RATA_RETENTIE"], label="Date reale")
sns.lineplot(x=df["X3_NR_Sesiuni_Active"], y=model.predict(X), color="red", label="Regresie")
plt.xlabel("X3_NR_Sesiuni_Active")
plt.ylabel("Y_RATA_RETENTIE")
plt.title("Relatia RATA_RETENTIE = f(NR_SESIUNI_ACTIVE)")
plt.xticks(rotation=45, ha='right')
plt.tight_layout()
plt.legend()
plt.savefig('Y4_grafic_regresie.png', dpi=150)
plt.show()