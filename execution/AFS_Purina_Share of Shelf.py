# Databricks notebook source
# MAGIC %md
# MAGIC ## Inicio 

# COMMAND ----------

import pandas as pd
from datetime import datetime
from dateutil.relativedelta import relativedelta

# COMMAND ----------

answers_df = spark.read.format("parquet").load("/mnt/data/input/Purina/AFS/df_answers_afs.parquet")
customer_df = spark.read.format("parquet").load("/mnt/data/input/Purina/AFS/df_customer_afs.parquet")

# COMMAND ----------

fecha_actual = datetime.now().date()
fecha_resta = fecha_actual - relativedelta(months=1)
fecha_resta = fecha_resta.replace(day=1)
fecha_inicial_carga = fecha_resta.strftime("%Y-%m-%d")
fecha_inicial_carga

# COMMAND ----------

answers_df = answers_df.toPandas()
customer_df= customer_df.toPandas()

# COMMAND ----------

answers_df["Answer_Date"].unique()

# COMMAND ----------

df_2 = spark.read.csv('dbfs:/mnt/data/input/Purina/AFS/F_MonitoringAnswer' +  '*.csv', header='true', sep=';')
cat_question = spark.read.csv('dbfs:/mnt/data/input/Purina/AFS/Catalogos/D_Monitoring' +  '*.csv', header='true', sep=';')
df_2= df_2.toPandas()
cat_question = cat_question.toPandas()

# COMMAND ----------

df_2 = pd.merge(right=df_2,left=cat_question[["MTD_MTDR_ID","Question"]],
        how='right', right_on="MTD_MTDR_ID",left_on="MTD_MTDR_ID")

# COMMAND ----------

df_2 = df_2[["MTD_MTDR_ID","Answer_Date","Question","Answer_As_Text","CUS_ID","USR_ID"]]

# COMMAND ----------

df_2.rename(columns={"Answer_As_Text":"Answer_as_Text"},inplace=True)

# COMMAND ----------

df_2 = df_2[df_2["Question"].str.contains("frentes")]

# COMMAND ----------

df_2["Answer_Date"] = pd.to_datetime(df_2["Answer_Date"])


# COMMAND ----------

answers_df = answers_df[answers_df["Answer_Date"]<fecha_inicial_carga]

# COMMAND ----------

df_2 = df_2[df_2["Answer_Date"]>fecha_inicial_carga]

# COMMAND ----------

answers_df = pd.concat([answers_df,df_2],axis=0)

# COMMAND ----------

answers_df.reset_index(drop=True,inplace=True)

# COMMAND ----------

answers_df["Answer_as_Text"] = answers_df["Answer_as_Text"].astype("float")

# COMMAND ----------

answers_df["Answer_Date"] = pd.to_datetime(answers_df["Answer_Date"])

# COMMAND ----------

answers_df = answers_df[~answers_df["Answer_as_Text"].isnull()]
answers_df["Answer_as_Text"] = answers_df["Answer_as_Text"].astype(float)
answers_df = answers_df[answers_df["Answer_as_Text"]>0]
answers_df = answers_df[answers_df['Answer_as_Text']<100]

# COMMAND ----------

answers_df["Answer_Date"].unique()

# COMMAND ----------

spark_df = spark.createDataFrame(answers_df)
spark_df.write.format("parquet").mode("overwrite").save("/mnt/data/input/Purina/AFS/df_answers_afs.parquet")

# COMMAND ----------

df_2["Question"][df_2["Answer_Date"]>fecha_inicial_carga].unique()

# COMMAND ----------

#dbutils.fs.ls("dbfs:/mnt/data/input/Purina/AFS/")

# COMMAND ----------

# MAGIC %md
# MAGIC #Prueba

# COMMAND ----------

answers_df[answers_df["Answer_as_Text"]==80].head(10)

# COMMAND ----------

answers_df = answers_df[~answers_df["Answer_as_Text"].isnull()]
answers_df["Answer_as_Text"] = answers_df["Answer_as_Text"].astype(float)
answers_df = answers_df[answers_df["Answer_as_Text"]>0]
answers_df = answers_df[answers_df['Answer_as_Text']<100]

# COMMAND ----------

import matplotlib.pyplot as plt

# COMMAND ----------

answers_df['Answer_as_Text'].max()

# COMMAND ----------

plt.figure(figsize=(25, 6))
plt.hist(answers_df["Answer_as_Text"].astype(str))
plt.xlim(1, 100) 
plt.xlabel('Valor')
plt.ylabel('Frecuencia')
plt.title('Histograma')
plt.tight_layout()
plt.xticks(rotation=45)
plt.show()

# COMMAND ----------

answers_df["Answer_as_Text"].min()

# COMMAND ----------

answers_df['Answer_as_Text'].max() ,answers_df['Answer_as_Text'].min()

# COMMAND ----------

import numpy as np

# COMMAND ----------

media = answers_df['Answer_as_Text'].mean()
desviacion_estandar = answers_df['Answer_as_Text'].std()

# Crear una serie de valores x para la curva de campana gaussiana
x = np.linspace(answers_df['Answer_as_Text'].min(), answers_df['Answer_as_Text'].max(), 100)

# Calcular los valores y para la campana gaussiana
y = np.exp(-(x - media)**2 / (2 * desviacion_estandar**2)) / (desviacion_estandar * np.sqrt(2 * np.pi))

# Trazar la curva de campana gaussiana
plt.plot(x, y)

# Configurar etiquetas y título
plt.xlabel('Valor')
plt.ylabel('Densidad')
plt.title('Curva de Campana Gaussiana')

# Mostrar el gráfico
plt.show()

# COMMAND ----------

import os

# Obtener la ruta del notebook actual
#notebook_path = os.path.abspath('AFS_Purina_Share of Shelf.py')

# Imprimir la ruta del notebook
#print("La ubicación del notebook es:", notebook_path)
