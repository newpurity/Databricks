-- Databricks notebook source
select * from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where  (YEARNESTLE="2023" or YEARNESTLE="2022")

-- COMMAND ----------

select Max (SEMANA_NESTLE_NUM) from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where  YEARNESTLE="2023" and CATEGORIA="Purina" and VENTAS_UNIDADES>0 

-- COMMAND ----------

select  CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR
from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where   CATEGORIA="Purina" and VENTAS_VALOR<>0 and CANAL="Dist Horiz" and (YEARNESTLE="2023" or YEARNESTLE="2022")

-- COMMAND ----------

select CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR
from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where  YEARNESTLE="2023" and CATEGORIA="Purina" and VENTAS_UNIDADES>0 and CHAINSTORE="Casa Ley" and (SEMANA_NESTLE_NUM=31 or SEMANA_NESTLE_NUM=30)

-- COMMAND ----------

SELECT CHAINSTORE, CODESTORE, UPC, YEARNESTLE,SUM(VENTAS_VALOR) AS TOTAL_VENTAS
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
WHERE VENTAS_VALOR <> 0 and CATEGORIA="Purina" and( YEARNESTLE = "2023" or YEARNESTLE = "2022") 
AND CODESTORE in('DUERO370', 'ABAMTY819', 'ABAMTY819', 'ALVISAR018', 'SCORPI182', 'SCORPI187', 'ABAMTY798', 'SCORPI181', 'SCORPI184', 'SCORPI185', 'DUERO336', '7ELEVEN020', 'SCORPI188', 'SCORPI183', 'SCORPI186', 'SCORPI180')
GROUP BY CHAINSTORE, CODESTORE,UPC,YEARNESTLE;

-- COMMAND ----------


select CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where CANAL="Ecommerce" and CATEGORIA="Purina" and VENTAS_VALOR<>0 and (YEARNESTLE="2023" or YEARNESTLE="2022")

-- COMMAND ----------

SELECT CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR 
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
WHERE YEARNESTLE = "2023" AND UPC IN ('7501055034475') AND VENTAS_UNIDADES > 0 and CHAINSTORE = "Sam's" and SEMANA_NESTLE_NUM<=35

-- COMMAND ----------


select distinct CHAINSTORE,CANAL, UPC   from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where  YEARNESTLE="2023" and CATEGORIA="Sin Asignacion" and VENTAS_UNIDADES > 0

-- COMMAND ----------

select DISTINCT CHAINSTORE  from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where  VENTAS_UNIDADES > 0 and CATEGORIA="Purina" and YEARNESTLE="2023" 

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ##Base Total Purina

-- COMMAND ----------

select CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where VENTAS_VALOR <> 0 and CATEGORIA="Purina" and YEARNESTLE="2023" and SEMANA_NESTLE_NUM in ('31','32','33','34','35')

-- COMMAND ----------

SELECT CHAINSTORE, FORMATO, YEARNESTLE, MES_NESTLE_NUM, SEMANA_NESTLE_NUM, CANAL, UPC, DESCRIPCION_PRODUCTO,sum(VENTAS_UNIDADES), sum(VENTA_KILOS_SEM),sum(VENTAS_VALOR) FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` where  VENTAS_UNIDADES <> 0 and DIVISION ='Purina' and (YEARNESTLE='2023' or YEARNESTLE='2022') and(CANAL='Autoservicios' or CANAL='Clubes' or CANAL='Conveniencia')
GROUP BY CHAINSTORE, FORMATO, YEARNESTLE, MES_NESTLE_NUM, SEMANA_NESTLE_NUM, CANAL, UPC, DESCRIPCION_PRODUCTO;


-- COMMAND ----------

SELECT Base.CHAINSTORE, Base.CODESTORE, Base.TIENDA_DSC, Base.FORMATO, Base.SEMANA_NESTLE, Base.SEMANA_NESTLE_NUM, Base.CANAL, Base.UPC, Base.DESCRIPCION_PRODUCTO, Base.VENTAS_UNIDADES, Base.VENTA_KILOS_SEM, Base.VENTAS_VALOR, cat.cliente6_dsc_nestle
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` as Base
LEFT JOIN delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1` AS cat
ON Base.codeStore = cat.codeStore -- Replace with the actual columns to join
WHERE Base.VENTAS_UNIDADES <> 0 
  AND Base.DIVISION = 'Purina' 
  AND (Base.YEARNESTLE = '2025' OR Base.YEARNESTLE = '2022') 
  AND (Base.CANAL = 'Mayoreo' OR Base.CANAL = 'Dist Activ' OR Base.CANAL = 'Dist Horiz');


-- COMMAND ----------

select * from delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1`
Where (Canal='Mayoreo' or canal='Dist Activ' or canal='Dist Horiz') 

-- COMMAND ----------

  AND (CANAL = 'Pet Specialty' OR CANAL = 'Departamentales' OR CANAL = 'Ecommerce');

-- COMMAND ----------

SELECT *
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
WHERE VENTAS_UNIDADES <> 0
  AND DIVISION = 'Purina'
  AND (YEARNESTLE = '2025' OR YEARNESTLE = '2023')
  AND UPC='7501055034475'


-- COMMAND ----------

-- MAGIC %Python
-- MAGIC
-- MAGIC df = spark.sql( CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
-- MAGIC where VENTAS_UNIDADES > 0 and CATEGORIA="Purina" and YEARNESTLE="2023" and (SEMANA_NESTLE_NUM=31 or SEMANA_NESTLE_NUM=30))
-- MAGIC

-- COMMAND ----------

select CHAINSTORE, codeStore, FORMATO,CANAL, sum(VENTAS_VALOR)
from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where YEARNESTLE="2023" and (canal = "Mayoreo" or canal = "Dist Horiz" or canal='Dist Activ')
group by CHAINSTORE, codeStore, FORMATO, CANAL

-- COMMAND ----------

select CHAINSTORE, codeStore, FORMATO,CANAL, sum(VENTAS_VALOR)
from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where YEARNESTLE="2023" and (FORMATO= "Sin Asignacion" or FORMATO= "Sin Formato" )
group by CHAINSTORE, codeStore, FORMATO, CANAL

-- COMMAND ----------

select CHAINSTORE, codeStore, FORMATO, sum(VENTAS_UNIDADES)
from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where canal='Purina' 
group by CHAINSTORE, codeStore, FORMATO

-- COMMAND ----------


SELECT DISTINCT codeStore, cliente6_dsc_nestle, FORMATO
FROM delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1`
Where canal='Purina' or canal='Dist Activ' or canal = 'Dist Horiz' or canal = 'Mayoreo' VENTAS_UNIDADES > 0

-- COMMAND ----------


SELECT count(Base.CHAINSTORE, Base.CODESTORE, Base.TIENDA_DSC, Base.FORMATO, Base.SEMANA_NESTLE, Base.SEMANA_NESTLE_NUM, Base.CANAL, Base.UPC, Base.DESCRIPCION_PRODUCTO, Base.VENTAS_UNIDADES, Base.VENTA_KILOS_SEM, Base.VENTAS_VALOR, cat.cliente6_dsc_nestle)
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` as Base
right JOIN (
    SELECT DISTINCT codeStore, cliente6_dsc_nestle
    FROM delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1`
    WHERE (cliente6_dsc_nestle  IS NOT NULL and (canal = 'Mayoreo' OR canal = 'Dist Activ' OR canal = 'Dist Horiz')) 
) AS cat
ON Base.CODESTORE = cat.codeStore
WHERE Base.VENTAS_UNIDADES <> 0 
  AND Base.DIVISION = 'Purina' 
  AND (Base.YEARNESTLE = '2025' OR Base.YEARNESTLE = '2022') 
  AND (Base.CANAL = 'Mayoreo' OR Base.CANAL = 'Dist Activ' OR Base.CANAL = 'Dist Horiz');


-- COMMAND ----------

Base.CHAINSTORE, Base.CODESTORE, Base.TIENDA_DSC, Base.FORMATO, Base.SEMANA_NESTLE, Base.SEMANA_NESTLE_NUM, Base.CANAL, Base.UPC, Base.DESCRIPCION_PRODUCTO, Base.VENTAS_UNIDADES, Base.VENTA_KILOS_SEM, Base.VENTAS_VALOR, cat.cliente6_dsc_nestle
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`

-- COMMAND ----------


SELECT Count(*)
FROM delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo` as Base
WHERE Base.VENTAS_UNIDADES <> 0 
  AND Base.DIVISION = 'Purina' 
  AND (Base.YEARNESTLE = '2025' OR Base.YEARNESTLE = '2023') 
  AND (Base.CANAL = 'Mayoreo' OR Base.CANAL = 'Dist Activ' OR Base.CANAL = 'Dist Horiz');

-- COMMAND ----------

    select CHAINSTORE, CANAL, codeStore, MES_NESTLE, YEARNESTLE , TIENDA_DSC, sum(VENTAS_VALOR)
    from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
    WHERE  VENTAS_VALOR <> 0 and CATEGORIA="Purina" and YEARNESTLE = '2023' and MES_NESTLE in ('Febrero','Marzo','Abril','Mayo','Junio','Julio')
    GROUP BY CHAINSTORE, CANAL, codeStore,TIENDA_DSC, MES_NESTLE, YEARNESTLE

-- COMMAND ----------


left JOIN (
    SELECT DISTINCT codeStore, cliente6_dsc_nestle
    FROM delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1`
    WHERE (cliente6_dsc_nestle  IS NOT NULL and (canal = 'Mayoreo' OR canal = 'Dist Activ' OR canal = 'Dist Horiz')) 
) AS cat
ON Base.CODESTORE = cat.codeStore

-- COMMAND ----------

select * from delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1`
Where canal = 'Mayoreo' OR canal = 'Dist Activ' OR canal = 'Dist Horiz'

-- COMMAND ----------

select * from delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationProducts_C1`
Where UPC ="17501072201598"

-- COMMAND ----------

select * from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_CALENDAR_NESTLE` 

-- COMMAND ----------



-- COMMAND ----------

SELECT * from sales_gold.cv_mx_so_ventas_unificadas

-- COMMAND ----------

left join delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationProducts_C1` as cat
on Inv.UPC= cat.upc

-- COMMAND ----------

select  Inv.CodeStore, Inv.UPC,cat.negocio,cat.descripcion_producto, client.chainStore,sum(Inv.Inventario_Unidades)
from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Inventarios_Unificados` as Inv
left join delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationProducts_C1` as cat
on Inv.UPC= cat.upc
left join delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1` as client
on Inv.CodeStore= client.CodeStore
Where cat.negocio ="Purina" and Inv.Fecha="2023-08-31" and chainStore in('Liverpool','ECOM-Liverpool')
GROUP BY  cat.negocio,client.chainStore, Inv.CodeStore, Inv.UPC, cat.descripcion_producto

--Where UPC='7501072217318'

-- COMMAND ----------

---`/mnt/amsmxpradls/solutions/siweb/vSegmentationStoreCategories_C1`

-- COMMAND ----------

select *
from delta.`/mnt/amsmxpradls/solutions/siweb/vSegmentationProducts_C1`

-- COMMAND ----------

select *
from delta.'/mnt/amsmxpradls/solutions/INVENTARIO_REAL/VENTA_PROM_REAL'

-- COMMAND ----------

select distinct CANAL from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where  YEARNESTLE="2023" and CATEGORIA="Purina" and CHAINSTORE='Chedraui'


-- COMMAND ----------

-- MAGIC %python
-- MAGIC connection = pyodbc.connect(connection_string)

-- COMMAND ----------

select CHAINSTORE,CODESTORE, MES_NESTLE_NUM, YEARNESTLE, TIENDA_DSC,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,VENTAS_UNIDADES, VENTA_KILOS_SEM,VENTAS_VALOR from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where VENTAS_VALOR <> 0 and CATEGORIA="Purina" and YEARNESTLE="2022" and SEMANA_NESTLE_NUM=32 and CHAINSTORE="Sam's" and CODESTORE="SAMS4746"

-- COMMAND ----------

select CHAINSTORE,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO,sum(VENTAS_UNIDADES) as VENTAS_UNIDADES,sum(VENTA_KILOS_SEM)as VENTA_KILOS_SEM,sum(VENTAS_VALOR) as VENTAS_VALOR
from delta.`/mnt/amsmxpradls/solutions/dataset/CV_MX_SO_Prometeo`
where  YEARNESTLE="2023" and CATEGORIA="Purina" and VENTAS_VALOR <>0  and YEARNESTLE in('2022','2023') and CHAINSTORE in ('San Francisco De Asis','Tiendas Garces S.a De C.v','Super Gutierrez','Tiendas Grand')
group by CHAINSTORE,FORMATO,SEMANA_NESTLE,SEMANA_NESTLE_NUM,CANAL,UPC,DESCRIPCION_PRODUCTO
