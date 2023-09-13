# Databricks notebook source
# MAGIC %sql
# MAGIC
# MAGIC select Max (SEMANA_NESTLE_NUM) from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
# MAGIC where  YEARNESTLE="2023" and CATEGORIA="Purina" and VENTAS_UNIDADES>0

# COMMAND ----------



# COMMAND ----------

# MAGIC %md
# MAGIC #Beginning

# COMMAND ----------

import pandas as pd
from datetime import datetime
from dateutil.relativedelta import relativedelta
from pyspark.sql import SparkSession
import warnings
pd.options.mode.chained_assignment = None 

warnings.filterwarnings("ignore")

# COMMAND ----------

#df = spark.sql("SELECT * FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and YEARNESTLE='2023'")#and SEMANA_NESTLE_NUM>26 

# COMMAND ----------

df = spark.sql("SELECT CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and YEARNESTLE='2023'")#and SEMANA_NESTLE_NUM>26 

# COMMAND ----------



df = df.withColumn("SEMANA_NESTLE_NUM", df["SEMANA_NESTLE_NUM"].cast("int"))
df = df.withColumn("MES_NESTLE_NUM", df["MES_NESTLE_NUM"].cast("int"))
df = df.withColumn("VENTAS_VALOR", df["VENTAS_VALOR"].cast("float"))
df = df.withColumn("VENTAS_UNIDADES", df["VENTAS_UNIDADES"].cast("float"))
df = df.withColumn("VENTA_KILOS_SEM", df["VENTA_KILOS_SEM"].cast("float"))
df = df.withColumn("YEARNESTLE", df["YEARNESTLE"].cast("string"))

# COMMAND ----------

df = df.toPandas()

# COMMAND ----------

df["CHAINSTORE"][df["CANAL"]=="Ecommerce"].unique()

# COMMAND ----------

# MAGIC %md
# MAGIC #Pet Specialty

# COMMAND ----------

df_compact = spark.sql("SELECT CHAINSTORE,CODESTORE, TIENDA_DSC,MES_NESTLE_NUM, YEARNESTLE,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,sum(VENTAS_UNIDADES) as VENTAS_UNIDADES, sum(VENTA_KILOS_SEM) as VENTA_KILOS_SEM, sum(VENTAS_VALOR) as VENTAS_VALOR  FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and (CHAINSTORE='Maskota' or CHAINSTORE='Liverpool' or CHAINSTORE ='Ecom-liverpool' or CHAINSTORE='Ecom-maskota') GROUP BY CHAINSTORE,CODESTORE, TIENDA_DSC, MES_NESTLE_NUM, YEARNESTLE, FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO") 

# COMMAND ----------

df_Ps = df_compact.toPandas()

# COMMAND ----------

df_Ps["CHAINSTORE"].unique()

# COMMAND ----------

df_Ps = df_Ps[['CHAINSTORE','CODESTORE', 'TIENDA_DSC','SEMANA_NESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO','VENTAS_UNIDADES', 'VENTA_KILOS_SEM','VENTAS_VALOR']]

# COMMAND ----------

df_Ps = df_Ps[(df_Ps["VENTAS_UNIDADES"]!=0)&(df_Ps["VENTAS_VALOR"]!=0)]

# COMMAND ----------

df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Liverpool"] = df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Liverpool"]/1.16
df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Ecom-liverpool"] = df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Ecom-liverpool"]/1.16

# COMMAND ----------

df_Ps.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/PetSpecialty/" + "PS.csv", index=False,index_label=False)

# COMMAND ----------



# COMMAND ----------

# MAGIC %md
# MAGIC #Tradicional

# COMMAND ----------




# COMMAND ----------

df_compact= spark.sql("SELECT  CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` Where  DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and CANAL in ('Mayoreo','Dist Activ') and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0 UNION SELECT  CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` Where  DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022')and FORMATO in('Super Mayoreo','Super Express','Sin Asignacion','Mostrador') and CHAINSTORE ='Casa Ley' and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0") 

# COMMAND ----------

df_tradi = df_compact.toPandas()

# COMMAND ----------

df_tradi['CHAINSTORE'].unique()

# COMMAND ----------

df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Grupo Z (pcz)"] = df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Grupo Z (pcz)"]/1.16
df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Casa Ley"] = df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Casa Ley"]/1.16
df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="May- Abarrotera Del Duero"] = df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="May- Abarrotera Del Duero"]/1.16


# COMMAND ----------



# COMMAND ----------

df_tradi.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Tradi/" + "Tradicional.csv", index=False,index_label=False)
#df_tradi[df_tradi["SEMANA_NESTLE_NUM"]<=17].to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Tradi/" + "Tradi_2023_Sem_1_17.csv", index=False,index_label=False)
#df_tradi[(df_tradi["SEMANA_NESTLE_NUM"]>17)&(df_tradi["SEMANA_NESTLE_NUM"]<=35)].to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Tradi/" + "Tradi_2023_Sem_18_35.csv", index=False,index_label=False)
#df_tradi[(df_tradi["SEMANA_NESTLE_NUM"]>36)].to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Tradi/" + "Tradi_2022_Sem_36_52.csv", index=False,index_label=False)

# COMMAND ----------

# MAGIC %md
# MAGIC ####Clientes de Moderno en Tradi

# COMMAND ----------

df_compact = spark.sql(" Select CHAINSTORE,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,sum(VENTAS_UNIDADES) as VENTAS_UNIDADES,sum(VENTA_KILOS_SEM) as VENTA_KILOS_SEM,sum(VENTAS_VALOR) as VENTAS_VALOR from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where  CATEGORIA='Purina' and VENTAS_VALOR <>0  and YEARNESTLE in('2022','2023') and CHAINSTORE in ('San Francisco De Asis','Tiendas Garces S.a De C.v','Super Gutierrez','Tiendas Grand') group by CHAINSTORE,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO") 

# COMMAND ----------

df_tradi_resume = df_compact.toPandas()

# COMMAND ----------

df_tradi_resume["CHAINSTORE"].unique()

# COMMAND ----------

#df_tradi_resume = df_tradi[(df_tradi["CHAINSTORE"]=='San Francisco De Asis')|(df_tradi["CHAINSTORE"]=='Tiendas Garces S.a De C.v')|(df_tradi["CHAINSTORE"]=='Super Gutierrez')|(df_tradi["CHAINSTORE"]=='Tiendas Grand')].groupby(['CHAINSTORE','FORMATO','SEMANA_NESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO'],as_index=False).sum()
#df_tradi_resume = df_tradi_resume[df_tradi_resume["VENTAS_UNIDADES"]!=0]

# COMMAND ----------

df_tradi_resume["VENTAS_VALOR"][df_tradi_resume["CHAINSTORE"]=="San Francisco De Asis"] = df_tradi_resume["VENTAS_VALOR"][df_tradi_resume["CHAINSTORE"]=="San Francisco De Asis"]/1.16

# COMMAND ----------

len(df_tradi_resume)

# COMMAND ----------

# MAGIC %md
# MAGIC ###Carga Rutero Nacional

# COMMAND ----------

rutero = pd.read_excel("/dbfs/mnt/dev/input/Purina/Catalog/Rutero Nacional NPP.xlsx")
df_tradi_resume = pd.merge(left=df_tradi_resume, right=rutero[["ID","Región"]],
                    how='left', left_on='CODESTORE' , right_on='ID')

del df_moderno["ID"]

# COMMAND ----------

len(df_tradi_resume)

# COMMAND ----------

df_tradi_resume.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Moderno/" + "Moderno_en_Tradi.csv", index=False,index_label=False)

# COMMAND ----------

df_tradi_resume["CHAINSTORE"].unique()

# COMMAND ----------

#Resumen
#df_tradi = df_tradi.groupby(['CHAINSTORE','FORMATO','SEMANA_NESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO'],as_index=False).sum()
#df_tradi = df_tradi[(df_tradi["VENTAS_UNIDADES"]!=0)&(df_tradi["VENTAS_VALOR"]!=0)]

# COMMAND ----------

# MAGIC %md
# MAGIC #Moderno

# COMMAND ----------

# MAGIC %sql
# MAGIC SELECT COUNT(*) AS NumeroDeRegistros
# MAGIC FROM (
# MAGIC     SELECT CHAINSTORE,CODESTORE,TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR
# MAGIC     FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
# MAGIC     WHERE DIVISION ='Purina' AND (YEARNESTLE='2023' OR YEARNESTLE='2022') AND (Canal='Autoservicios' OR Canal='Clubes' OR Canal ='Conveniencia') AND VENTAS_UNIDADES <> 0 AND VENTAS_VALOR <> 0
# MAGIC     UNION
# MAGIC     SELECT CHAINSTORE,CODESTORE,TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR
# MAGIC     FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
# MAGIC     WHERE DIVISION ='Purina' AND (YEARNESTLE='2023' OR YEARNESTLE='2022') AND VENTAS_UNIDADES <> 0 AND VENTAS_VALOR <> 0 AND CHAINSTORE IN ('San Francisco De Asis','Tiendas Garces S.a De C.v','Super Gutierrez','Tiendas Grand')
# MAGIC ) AS ResultadosTotales;
# MAGIC

# COMMAND ----------

# MAGIC %sql
# MAGIC
# MAGIC SELECT CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR
# MAGIC FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
# MAGIC where DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and (Canal='Autoservicios' or Canal='Clubes' or Canal ='Conveniencia') and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0
# MAGIC UNION
# MAGIC SELECT  CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR
# MAGIC FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
# MAGIC Where  DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022')  and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0 and CHAINSTORE in ('San Francisco De Asis','Tiendas Garces S.a De C.v','Super Gutierrez','Tiendas Grand')
# MAGIC

# COMMAND ----------

df_compact = spark.sql("SELECT CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and (Canal='Autoservicios' or Canal='Clubes' or Canal ='Conveniencia') and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0 UNION SELECT  CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` Where  DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022')  and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0 and CHAINSTORE in ('San Francisco De Asis','Tiendas Garces S.a De C.v','Super Gutierrez','Tiendas Grand')") 

# COMMAND ----------

df_moderno = df_compact.toPandas()

# COMMAND ----------

df_moderno["CHAINSTORE"].unique()

# COMMAND ----------

#df_moderno["VENTAS_UNIDADES"] = df_moderno["VENTAS_UNIDADES"].astype(float)
#df_moderno_group = df_moderno.groupby(['CHAINSTORE','FORMATO','YEARNESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO'],as_index=False).sum()

# COMMAND ----------

df_temp = df_moderno[df_moderno["CHAINSTORE"]=='Casa Ley']
df_moderno = df_moderno[df_moderno["CHAINSTORE"]!='Casa Ley']

# COMMAND ----------

 formatos_deseados = ["Super Mayoreo", "Super Express", "Sin Asignacion", "Mostrador"]
 df_temp = df_temp[(df_temp["CHAINSTORE"] == "Casa Ley") &(~df_temp["FORMATO"].isin(formatos_deseados))]
 df_moderno=pd.concat([df_moderno,df_temp],axis=0)

# COMMAND ----------


df_moderno["UPC"][(df_moderno["CHAINSTORE"]=="Oxxo")&(df_moderno["UPC"]=="7501072201614")]="1614"
df_moderno["UPC"][(df_moderno["CHAINSTORE"]=="Oxxo")&(df_moderno["UPC"]=="7501777037198")]="7198"

df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Casa Ley")]=df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Casa Ley")]/1.16
df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Smart")]=df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Smart")]/1.16
df_moderno["VENTAS_VALOR"][df_moderno["CHAINSTORE"]=="San Francisco De Asis"] = df_moderno["VENTAS_VALOR"][df_moderno["CHAINSTORE"]=="San Francisco De Asis"]/1.16

# COMMAND ----------

# MAGIC %md
# MAGIC ####Carga de Rutero Nacional

# COMMAND ----------

df_moderno["VENTAS_VALOR"].sum() , len(df_moderno)

# COMMAND ----------

rutero = pd.read_excel("/dbfs/mnt/dev/input/Purina/Catalog/Rutero Nacional NPP.xlsx")
df_moderno = pd.merge(left=df_moderno, right=rutero[["rutero","Región"]],
                    how='left', left_on='CODESTORE' , right_on='ID')

del df_moderno["ID"]

# COMMAND ----------

df_moderno["Región"].fillna("Sin Region", inplace=True)

# COMMAND ----------

df_moderno.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Moderno/" + "Moderno.csv", index=False,index_label=False)
df_moderno.groupby(['CHAINSTORE','FORMATO','YEARNESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO','Región'],as_index=False).sum().to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Moderno/" + "Moderno_Agrupado.csv", index=False,index_label=False)

# COMMAND ----------

if rutero['Región'].duplicated().any() ==True :
    print("We have duplicates, Please Check Rutero Nacional NPP")




# COMMAND ----------

duplicados

# COMMAND ----------

rutero = pd.read_excel("/dbfs/mnt/dev/input/Purina/Catalog/Rutero Nacional NPP.xlsx")

# COMMAND ----------

#spark_df = spark.createDataFrame(df_moderno)
#spark.sql("CREATE TABLE IF NOT EXISTS sales_gold.CV_MX_SO_Purina_Total_Moderno USING delta LOCATION '/mnt/data/input/Purina/Datasets/Moderno/Moderno.parquet'")
#spark_df.write.format("delta").mode("overwrite").save("/mnt/data/input/Purina/Datasets/Moderno/Moderno.parquet")

# COMMAND ----------

# MAGIC %md
# MAGIC ###Cliente de Tradi en Moderno

# COMMAND ----------

df_moderno_tradi = df[(df["CANAL"]=="Autoservicios")|(df["CANAL"]=="Clubes")|(df["CANAL"]=="Conveniencia")]

# COMMAND ----------

df_moderno_tradi = df_moderno_tradi [['CHAINSTORE','CODESTORE', 'TIENDA_DSC','FORMATO','SEMANA_NESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO','VENTAS_UNIDADES', 'VENTA_KILOS_SEM','VENTAS_VALOR']]

# COMMAND ----------

 formatos_deseados = ["Super Mayoreo", "Super Express", "Sin Asignacion", "Mostrador"]
 df_moderno_tradi = df_moderno_tradi[(df_moderno_tradi["CHAINSTORE"] == "Casa Ley") &(df_moderno_tradi["FORMATO"].isin(formatos_deseados))]

# COMMAND ----------

df_moderno_tradi = df_moderno_tradi[(df_moderno_tradi["VENTAS_UNIDADES"]!=0)&(df_moderno_tradi["VENTAS_VALOR"]!=0)]

# COMMAND ----------

df_moderno_tradi.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Tradi/" + "Casa_Ley_Tradi_2022.csv", index=False,index_label=False)

# COMMAND ----------

# MAGIC %md
# MAGIC ## Total Moderno last week

# COMMAND ----------

df_moderno = df_moderno[(df_moderno["VENTAS_UNIDADES"]!=0)&(df_moderno["VENTAS_VALOR"]!=0)]
df_moderno[(df_moderno["SEMANA_NESTLE_NUM"]==31].to_csv("/dbfs/mnt/dev/input/Purina/Datasets/" + "Moderno_2023_Sem_31.csv", index=False,index_label=False)

# COMMAND ----------

#df_moderno["SEMANA_NESTLE"]  = df_moderno["SEMANA_NESTLE"].astype(str)
#df_moderno[df_moderno["SEMANA_NESTLE"].str.contains('2023-07')]

# COMMAND ----------



# COMMAND ----------

# MAGIC %md
# MAGIC #E-Commerce

# COMMAND ----------

df_compact = spark.sql("SELECT CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0  and CANAL='Ecommerce'")

# COMMAND ----------

df_ecom = df_compact.toPandas()

# COMMAND ----------

df_ecom.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Ecommerce/" + "Ecom_NPP.csv", index=False,index_label=False)

# COMMAND ----------


