# Databricks notebook source
# MAGIC %md
# MAGIC ###Beginning

# COMMAND ----------



# COMMAND ----------

import pandas as pd
from datetime import datetime
from dateutil.relativedelta import relativedelta
from pyspark.sql import SparkSession
import warnings
pd.options.mode.chained_assignment = None 

warnings.filterwarnings("ignore")

# COMMAND ----------

# MAGIC %md
# MAGIC #Pet Specialty
# MAGIC
# MAGIC
# MAGIC
# MAGIC

# COMMAND ----------

df_compact = spark.sql("SELECT CHAINSTORE,CODESTORE, TIENDA_DSC,MES_NESTLE_NUM, YEARNESTLE,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,sum(VENTAS_UNIDADES) as VENTAS_UNIDADES, sum(VENTA_KILOS_SEM) as VENTA_KILOS_SEM, sum(VENTAS_VALOR) as VENTAS_VALOR  FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and (CHAINSTORE='Maskota' or CHAINSTORE='Liverpool' or CHAINSTORE ='Ecom-liverpool' or CHAINSTORE='Ecom-maskota') GROUP BY CHAINSTORE,CODESTORE, TIENDA_DSC, MES_NESTLE_NUM, YEARNESTLE, FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO") 
df_Ps = df_compact.toPandas()
df_Ps["CHAINSTORE"].unique()
df_Ps = df_Ps[['CHAINSTORE','CODESTORE', 'TIENDA_DSC','SEMANA_NESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO','VENTAS_UNIDADES', 'VENTA_KILOS_SEM','VENTAS_VALOR']]
df_Ps = df_Ps[(df_Ps["VENTAS_UNIDADES"]!=0)&(df_Ps["VENTAS_VALOR"]!=0)]
df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Liverpool"] = df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Liverpool"]/1.16
df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Ecom-liverpool"] = df_Ps["VENTAS_VALOR"][df_Ps["CHAINSTORE"]=="Ecom-liverpool"]/1.16

df_Ps.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/PetSpecialty/" + "PS.csv", index=False,index_label=False)


# COMMAND ----------



# COMMAND ----------

# MAGIC %md
# MAGIC #Tradicional

# COMMAND ----------

df_compact= spark.sql("SELECT  CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` Where  DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and CANAL in ('Mayoreo','Dist Activ') and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0 UNION SELECT  CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` Where  DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022')and FORMATO in('Super Mayoreo','Super Express','Sin Asignacion','Mostrador') and CHAINSTORE ='Casa Ley' and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0") 
df_tradi = df_compact.toPandas()
df_tradi['CHAINSTORE'].unique()
df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Grupo Z (pcz)"] = df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Grupo Z (pcz)"]/1.16
df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Casa Ley"] = df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="Casa Ley"]/1.16
df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="May- Abarrotera Del Duero"] = df_tradi["VENTAS_VALOR"][df_tradi["CHAINSTORE"]=="May- Abarrotera Del Duero"]/1.16


df_tradi.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Tradi/" + "Tradicional.csv", index=False,index_label=False)

# COMMAND ----------

# MAGIC %md
# MAGIC #Moderno

# COMMAND ----------

df_compact = spark.sql("SELECT CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and (Canal='Autoservicios' or Canal='Clubes' or Canal ='Conveniencia') and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0 UNION SELECT  CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` Where  DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022')  and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0 and CHAINSTORE in ('San Francisco De Asis','Tiendas Garces S.a De C.v','Super Gutierrez','Tiendas Grand')") 
df_moderno = df_compact.toPandas()

df_temp = df_moderno[df_moderno["CHAINSTORE"]=='Casa Ley']
df_moderno = df_moderno[df_moderno["CHAINSTORE"]!='Casa Ley']
formatos_deseados = ["Super Mayoreo", "Super Express", "Sin Asignacion", "Mostrador"]
df_temp = df_temp[(df_temp["CHAINSTORE"] == "Casa Ley") &(~df_temp["FORMATO"].isin(formatos_deseados))]
df_moderno=pd.concat([df_moderno,df_temp],axis=0)

df_moderno["UPC"][(df_moderno["CHAINSTORE"]=="Oxxo")&(df_moderno["UPC"]=="7501072201614")]="1614"
df_moderno["UPC"][(df_moderno["CHAINSTORE"]=="Oxxo")&(df_moderno["UPC"]=="7501777037198")]="7198"

df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Casa Ley")]=df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Casa Ley")]/1.16
df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Smart")]=df_moderno["VENTAS_VALOR"][(df_moderno["CHAINSTORE"]=="Smart")]/1.16
df_moderno["VENTAS_VALOR"][df_moderno["CHAINSTORE"]=="San Francisco De Asis"] = df_moderno["VENTAS_VALOR"][df_moderno["CHAINSTORE"]=="San Francisco De Asis"]/1.16

###Carga de Rutero Nacional
df_moderno["VENTAS_VALOR"].sum() , len(df_moderno)
rutero = pd.read_excel("/dbfs/mnt/dev/input/Purina/Catalog/Rutero Nacional NPP.xlsx")
df_moderno = pd.merge(left=df_moderno, right=rutero[["ID","Región"]],
                    how='left', left_on='CODESTORE' , right_on='ID')

del df_moderno["ID"]
df_moderno["Región"].fillna("Sin Region", inplace=True)
if rutero['ID'].duplicated().any() ==True :
    print("We have duplicates, Please Check Rutero Nacional NPP")
else:
    df_moderno.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Moderno/" + "Moderno.csv", index=False,index_label=False)
    df_moderno.groupby(['CHAINSTORE','FORMATO','YEARNESTLE','SEMANA_NESTLE_NUM','CANAL','UPC','DESCRIPCION_PRODUCTO','Región'],as_index=False).sum().to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Moderno/" + "Moderno_Agrupado.csv", index=False,index_label=False)

# COMMAND ----------

# MAGIC %md
# MAGIC #E-Commerce

# COMMAND ----------

df_compact = spark.sql("SELECT CHAINSTORE,CODESTORE, TIENDA_DSC,FORMATO,YEARNESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and VENTAS_UNIDADES <>0 and VENTAS_VALOR<>0  and CANAL='Ecommerce'")
df_ecom = df_compact.toPandas()
df_ecom.to_csv("/dbfs/mnt/dev/input/Purina/Datasets/Ecommerce/" + "Ecom_NPP.csv", index=False,index_label=False)
