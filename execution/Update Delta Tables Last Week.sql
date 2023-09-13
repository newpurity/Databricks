-- Databricks notebook source
-- MAGIC %md
-- MAGIC ###Update Sales Last Week 

-- COMMAND ----------

-- MAGIC %python
-- MAGIC
-- MAGIC from azure.storage.blob import BlobServiceClient, BlobPrefix
-- MAGIC
-- MAGIC # Conectarse al almacenamiento de Azure con nombre de cuenta y clave
-- MAGIC account_name = "nmexpporigdsdh79sta"
-- MAGIC account_key = "LK1+2JxdXfQ4vh54m9GO2c1jvUuqyOr6SvMXGDm2Xuot/6BUdDo5XdFrM47NIYHwh8s0zItwfp1i+AStqAATmQ=="
-- MAGIC
-- MAGIC blob_service_client = BlobServiceClient(account_url=f"https://{account_name}.blob.core.windows.net", credential=account_key)
-- MAGIC

-- COMMAND ----------

-- MAGIC
-- MAGIC %python
-- MAGIC
-- MAGIC # Definir el nombre del contenedor y la carpeta que deseas borrar
-- MAGIC container_name = "datascience"
-- MAGIC folder_name = "dev/sales/gold/Purina/tb_mx_sales_purina_last_week_moderno/_delta_log/__tmp_path_dir"
-- MAGIC
-- MAGIC try:
-- MAGIC     # Obtener una referencia al contenedor y a los blobs en la carpeta
-- MAGIC     container_client = blob_service_client.get_container_client(container_name)
-- MAGIC     blobs = container_client.list_blobs(name_starts_with=folder_name)
-- MAGIC
-- MAGIC
-- MAGIC     # Eliminar los blobs en la carpeta
-- MAGIC     for blob in blobs:
-- MAGIC         blob_client = container_client.get_blob_client(blob)
-- MAGIC         blob_client.delete_blob()
-- MAGIC
-- MAGIC     # Eliminar la carpeta vacía
-- MAGIC     container_client.delete_blob(folder_name)
-- MAGIC except:
-- MAGIC     print("Carpeta eliminada con éxito.1")
-- MAGIC
-- MAGIC
-- MAGIC # Definir el nombre del contenedor y la carpeta que deseas borrar
-- MAGIC container_name = "datascience"
-- MAGIC folder_name = "dev/sales/gold/Purina/tb_mx_sales_purina_last_week_moderno/_delta_log/"
-- MAGIC
-- MAGIC # Obtener una referencia al contenedor y a los blobs en la carpeta
-- MAGIC container_client = blob_service_client.get_container_client(container_name)
-- MAGIC blobs = container_client.list_blobs(name_starts_with=folder_name)
-- MAGIC
-- MAGIC # Obtener una referencia al contenedor y a los blobs en la carpeta
-- MAGIC # Eliminar los blobs en la carpeta
-- MAGIC for blob in blobs:
-- MAGIC     blob_client = container_client.get_blob_client(blob)
-- MAGIC     blob_client.delete_blob()
-- MAGIC
-- MAGIC # Imprimir un mensaje cuando se hayan eliminado los archivos
-- MAGIC print("Archivos eliminados con éxito.2")
-- MAGIC
-- MAGIC # Definir el nombre del contenedor y la carpeta que deseas borrar
-- MAGIC container_name = "datascience"
-- MAGIC folder_name = "dev/sales/gold/Purina/tb_mx_sales_purina_last_week_moderno/"
-- MAGIC
-- MAGIC # Obtener una referencia al contenedor y a los blobs en la carpeta
-- MAGIC container_client = blob_service_client.get_container_client(container_name)
-- MAGIC blobs = container_client.list_blobs(name_starts_with=folder_name)
-- MAGIC
-- MAGIC # Obtener una referencia al contenedor y a los blobs en la carpeta
-- MAGIC # Eliminar los blobs en la carpeta
-- MAGIC for blob in blobs:
-- MAGIC     blob_client = container_client.get_blob_client(blob)
-- MAGIC     blob_client.delete_blob()
-- MAGIC
-- MAGIC # Imprimir un mensaje cuando se hayan eliminado los archivos
-- MAGIC print("Archivos eliminados con éxito 3.")
-- MAGIC

-- COMMAND ----------

DROP TABLE sales_gold.CV_MX_SO_Purina_Last_Week_Moderno;

-- COMMAND ----------

CREATE TABLE IF NOT EXISTS  sales_gold.CV_MX_SO_Purina_Last_Week_Moderno(
CHAINSTORE string,
CODESTORE string,
MES_NESTLE_NUM decimal(6,0),
YEARNESTLE decimal(4,0),
TIENDA_DSC string,
FORMATO string,
SEMANA_NESTLE date,
SEMANA_NESTLE_NUM decimal(6,0),
CANAL string,
--UPC string,
--DESCRIPCION_PRODUCTO string,
VENTAS_UNIDADES string,
VENTA_KILOS_SEM string,
VENTAS_VALOR string
)
USING delta
location '/mnt/datascience/dev/sales/gold/Purina/tb_mx_sales_purina_last_week_moderno'
comment 'Purina Sell out Last week';

    

-- COMMAND ----------

--DELETE FROM sales_gold.CV_MX_SO_Purina_Last_Week;
--OPTIMIZE sales_gold.CV_MX_SO_Purina_Last_Week;


-- COMMAND ----------

INSERT INTO sales_gold.CV_MX_SO_Purina_Last_Week_Moderno
SELECT 
    CHAINSTORE,
    CODESTORE,
    MES_NESTLE_NUM,
    YEARNESTLE,
    TIENDA_DSC,
    FORMATO,
    SEMANA_NESTLE,
    SEMANA_NESTLE_NUM,
    CANAL,
    --UPC,
    --DESCRIPCION_PRODUCTO,
    sum(VENTAS_UNIDADES),
    sum(VENTA_KILOS_SEM),
    sum(VENTAS_VALOR)
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
WHERE (YEARNESTLE = "2023" OR YEARNESTLE = "2022") and CATEGORIA="Purina" and (Canal = "Autoservicios" or Canal = "Autoservicios" or CANAL='Clubes' or CANAL='Conveniencia')
GROUP BY CHAINSTORE, CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO, SEMANA_NESTLE, SEMANA_NESTLE_NUM, CANAL;

-- COMMAND ----------

select * from delta.`/mnt/datascience/dev/sales/gold/Purina/tb_mx_sales_purina_last_week_moderno`


-- COMMAND ----------

--describe  sales_gold.CV_MX_SO_Purina_Last_Week;

-- COMMAND ----------

Select * from gold.vcalendars
