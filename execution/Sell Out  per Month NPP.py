# Databricks notebook source
import pandas as pd
from datetime import datetime
from dateutil.relativedelta import relativedelta
from pyspark.sql.functions import col

# COMMAND ----------

# MAGIC %sql
# MAGIC Select * from sales_bronze.tb_MayoreoDigital_Liquidaciones

# COMMAND ----------

from pyspark.sql import SparkSession

# Crear una instancia de SparkSession
spark = SparkSession.builder.getOrCreate()

# Leer la tabla de la base de datos con el separador "|"
tabla_liquidaciones = spark.read.option("delimiter", "|").table("sales_bronze.tb_MayoreoDigital_Liquidaciones")

# Convertir la tabla a DataFrame
df_liquidaciones = tabla_liquidaciones.toDF()

# Mostrar el contenido del DataFrame
df_liquidaciones.show()

# COMMAND ----------

data = tabla_liquidaciones.toPandas()

# COMMAND ----------

data = spark.createDataFrame(data)

# COMMAND ----------

data = data.withColumn("Precio_Unitario", col("Precio_Unitario").cast("decimal(9,2)"))
data = data.withColumn("Subtotal", col("Subtotal").cast("decimal(9,2)"))
data = data.withColumn("IEPS", col("IEPS").cast("decimal(9,2)"))
data = data.withColumn("IVA", col("IVA").cast("decimal(9,2)"))
data = data.withColumn("Total", col("Total").cast("decimal(9,2)"))

# COMMAND ----------

data.write.mode("overwrite").saveAsTable("sales_bronze.tb_MayoreoDigital_Liquidaciones")

# COMMAND ----------



# COMMAND ----------



# COMMAND ----------



# COMMAND ----------

dbutils.fs.ls("dbfs:/mnt/dev/inbound/mayoreo_digital/liquidaciones/")
