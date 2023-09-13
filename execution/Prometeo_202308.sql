-- Databricks notebook source
WITH sqlViews AS(
                 select
                 coalesce(b.idRetailerParent,a.idRetailer) as idRetailer,
                 coalesce(b.chainStoreRetailerParent,e.chainstore) as chainstore,
                 d.retailer_dsc_corta,
                 a.idStore,
                 a.retailerStoreKey,
                 a.codestore,
                 d.tienda_dsc,
                 a.idproduct,  
                 trim(LEADING '0' from c.upc) as upc,
                 a.firstDayWeekNestle,
                 a.lastdayweeknestle,
                 a.weekNestle as semana_nestle_num,
                 g.monthNameES as Mes_Nestle,
                 a.monthNestle as Mes_Nestle_Num,
                 a.yearNestle as yearNestle,
                 a.banderaBase as tipo,
                 a.VentaPromUnidades_Sem as Promedio_VentaUnidades_Semanal,
                 a.VentaPromValor_Sem as Promedio_VentaValor_Semanal,
                 a.inventario1,
                 a.inventario2,
                 a.VentaProm_Sem1,
                 a.VentaProm_Sem2,

                 a.Inventario_Unidades,
                 a.Inventario_Valor,
                 a.Venta_Kilos_Sem,
                 a.Inv_Kilos_Sem,
                 a.VentaPromKilos_SemNestle as Promedio_Venta_Kg,
                 a.Ventas_Valor,
                 a.Ventas_Unidades,
                 
                 d.organizacion_ventas as sales_organization,
                 d.canal_distribucion as dist_channel,
                 d.region_dsc,
                 d.tienda_estado,
                 c.material_sap,
                 d.cliente4_clave_sap,
                 d.cliente5_clave_sap,
                 d.cliente6_clave_sap,
                 d.cliente7_clave_sap,
                 c.formato_equivalente,
                 c.MG,
                 case 
                 when d.canal='MAYOREO OOH' and c.categoria !='AGUAS' then 'PROFESSIONAL'
                 when c.division is NULL then 'RESTO'
                 else c.division end as division, --Todo producto que vendan los clientes de Mayoreo OOH tendrán la división de Professional excepto Aguas | Responsable: Luis Lopez
                 c.in_out,
                 d.formato,
                 d.Tiendas_Blindadas,
                 d.canal,
                 c.categoria,
                 c.Grupopronostico,
                 c.peso_neto,
                 coalesce(d.rtm,'SIN RTM') as rtm,
                 e.muestra_oficial_resto,
                 c.Innovacionformato,
                 c.descripcion_producto,
                 c.linea_promocion ,
                 c.Individual_negocio,
                 e.tipo_retailer,
                 d.distrito_operaciones,
                 d.region_operaciones,
                 d.sector_operaciones,
                 d.plan_norte,
                 c.tasty
                 
                 from datasets.cv_mx_so_modelo_global a
                 
                 left join gold.vretailers b on a.idRetailer=b.idRetailer
                 left join gold.vSegmentationProducts_C1 c on a.idproduct=c.idproduct
                 left join gold.vSegmentationStoreCategories_C1 d on a.retailerStoreKey=d.retailerStoreKey
                 left join gold.vSegmentationRetailers_C1 e on a.idretailer=e.idretailer
                 left join (select distinct month,monthNameES from gold.vcalendars) g on a.monthNestle=g.month 

                 left join datasets.CV_MX_SO_FILTER_CATALOG_COMBINATION_FILE f on case when f.categoria!='' and f.tipomuestra!='' then upper(c.categoria)=upper(f.categoria) and upper(e.tipo_retailer)=upper(f.tipomuestra) else false end  and (a.firstDayWeekNestle between case when f.startdate ='' or f.startdate is NULL then a.firstDayWeekNestle else f.startdate end 
                                                                                         and case when f.enddate ='' or f.enddate is NULL then a.firstDayWeekNestle else f.EndDate end) 
                                                       and (f.ruleenddate ='' or f.ruleenddate is NULL)
                 
                 where f.categoria is NULL 
),


tempProm as (
                  select
                  a.idRetailer,
                  a.retailer_dsc_corta,
                  a.idStore,
                  a.retailerStoreKey,
                  a.codestore,
                  a.tienda_dsc,
                  a.idproduct,
                  a.upc,
                  a.firstDayWeekNestle as firstday_semana_nestle,
                  a.lastdayweeknestle as lastday_semana_nestle,
                  a.semana_nestle_num,
                  a.Mes_Nestle,
                  a.Mes_Nestle_Num,
                  a.yearNestle,
                  a.tipo,
                  a.sales_organization,
                  a.dist_channel,
                  a.region_dsc,
                  a.tienda_estado,
                  a.material_sap,
                  a.formato_equivalente,
                  a.MG,
                  a.division,
                  a.canal,
                  a.in_out,
                  a.formato,
                  a.Tiendas_Blindadas,
                  a.categoria,
                  a.Grupopronostico,
                  a.peso_neto,
                  a.muestra_oficial_resto,
                  a.Innovacionformato,
                  a.descripcion_producto,
                  a.chainstore,
                  a.linea_promocion,
                  a.Individual_negocio,

                  a.tipo_retailer,
                  a.distrito_operaciones,
                  a.region_operaciones,
                  a.sector_operaciones,
                  a.plan_norte,
                  a.tasty,
                  
                  a.ventas_unidades,
                  a.ventas_valor,
                  
                  case when a.Inventario_Unidades <0 then 0 else a.Inventario_Unidades end as Inventario_Unidades,--Todo inventario negativo se cambia por 0 | Responsable: A. Ruz 
                  case when a.Inventario_Valor <0 then 0 else a.Inventario_Valor end as Inventario_Valor,--Todo inventario negativo se cambia por 0 | Responsable: A. Ruz
                  case when a.Venta_Kilos_Sem <0 then 0 else a.Venta_Kilos_Sem end as Venta_Kilos_Sem,--Todo inventario negativo se cambia por 0 | Responsable: A. Ruz
                  case when a.Inv_Kilos_Sem <0 then 0 else a.Inv_Kilos_Sem end as Inv_Kilos_Sem,--Todo inventario negativo se cambia por 0 | Responsable: A. Ruz
                  a.Promedio_VentaUnidades_Semanal,
                  a.Promedio_VentaValor_Semanal,
                  a.Promedio_Venta_Kg,
                  inventario1,
                  inventario2,
                  VentaProm_Sem1,
                  VentaProm_Sem2,
                  
                  case 
                  when b.chainStoreRetailerParent is not NULL --Abarrotes Monterrey,Ctral Viveresdel Sureste 
                  then  concat(a.rtm,'-',a.idretailer) 
                  else a.rtm 
                  end as rtm --Se alinean los Clientes de Grupo Z con Abarrotes Monterrey | Ctral Viveresdel Sureste con Detalle de Cervisur - Super Iberia | Así lo quiere ver el canal y la alineación se hace por descripcion de Cliente y se vizualiza la diferencia en el campo RTM | Responsable: A. Ruz
                  
                  from sqlViews a
                  left join gold.vretailers b on a.idRetailer=b.idRetailer
                  left join gold.vSegmentationProducts_C1 c on a.idproduct=c.idproduct
                  left join (select 
                             categoria, 
                             startdate, 
                             enddate,
                             rulestartdate,
                             ruleenddate 
                             from datasets.CV_MX_SO_FILTER_CATALOG_ALL_FILE
                             where categoria IS NOT NULL) d on (upper(c.categoria)=upper(d.categoria)) and 
                                                               (concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) between case when d.startdate ='' or d.startdate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.startdate end and 
                                                               case when d.startdate ='' or d.startdate is NULL then case when d.enddate ='' or d.enddate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.EndDate end else 999999 end) and 
                                                               (d.ruleenddate ='' or d.ruleenddate is NULL)

                  left join (select 
                             idretailer, 
                             startdate, 
                             enddate,
                             rulestartdate,
                             ruleenddate 
                             from datasets.CV_MX_SO_FILTER_CATALOG_ALL_FILE
                             where idretailer IS NOT NULL) e on (upper(a.idretailer)=upper(e.idretailer)) and 
                                                               (concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) between case when d.startdate ='' or d.startdate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.startdate end and 
                                                               case when d.startdate ='' or d.startdate is NULL then case when d.enddate ='' or d.enddate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.EndDate end else 999999 end) and 
                                                               (d.ruleenddate ='' or d.ruleenddate is NULL)  
                  left join (select 
                             idstore, 
                             startdate, 
                             enddate,
                             rulestartdate,
                             ruleenddate 
                             from datasets.CV_MX_SO_FILTER_CATALOG_ALL_FILE
                             where idstore IS NOT NULL) f on (upper(a.idstore)=upper(f.idstore)) and 
                                                               (concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) between case when d.startdate ='' or d.startdate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.startdate end and 
                                                               case when d.startdate ='' or d.startdate is NULL then case when d.enddate ='' or d.enddate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.EndDate end else 999999 end) and 
                                                               (d.ruleenddate ='' or d.ruleenddate is NULL)  
                  left join (select 
                             idproduct, 
                             startdate, 
                             enddate,
                             rulestartdate,
                             ruleenddate 
                             from datasets.CV_MX_SO_FILTER_CATALOG_ALL_FILE
                             where idproduct IS NOT NULL) h on (upper(a.idproduct)=upper(h.idproduct)) and 
                                                               (concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) between case when d.startdate ='' or d.startdate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.startdate end and 
                                                               case when d.startdate ='' or d.startdate is NULL then case when d.enddate ='' or d.enddate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else d.EndDate end else 999999 end) and 
                                                               (d.ruleenddate ='' or d.ruleenddate is NULL)  

                  left join (select 
                             division, 
                             startdate, 
                             enddate,
                             rulestartdate,
                             ruleenddate 
                             from datasets.CV_MX_SO_FILTER_CATALOG_ALL_FILE
                             where division IS NOT NULL) i on (upper(a.division)=upper(i.division)) and 
                                                               (concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) between case when i.startdate ='' or i.startdate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else i.startdate end and 
                                                               case when i.startdate ='' or i.startdate is NULL then case when i.enddate ='' or i.enddate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else i.EndDate end else 999999 end) and 
                                                               (i.ruleenddate ='' or i.ruleenddate is NULL) 

                  left join (select 
                             MG, 
                             startdate, 
                             enddate,
                             rulestartdate,
                             ruleenddate 
                             from datasets.CV_MX_SO_FILTER_CATALOG_ALL_FILE
                             where MG IS NOT NULL) j on (upper(a.MG)=upper(j.MG)) and 
                                                               (concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) between case when j.startdate ='' or j.startdate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else j.startdate end and 
                                                               case when j.startdate ='' or j.startdate is NULL then case when j.enddate ='' or j.enddate is NULL then concat(year(a.firstDayWeekNestle),lpad(month(a.firstDayWeekNestle),2,00),lpad(day(a.firstDayWeekNestle),2,00)) else j.EndDate end else 999999 end) and 
                                                               (j.ruleenddate ='' or j.ruleenddate is NULL)  

                  
                  where 
                  coalesce(substring(upper(a.CodeStore),1,2),0) !='M_' --No se muestra la información de tiendas maduras para el cliente OXXO (M_) | Responsable: A. Ruz
                  and d.categoria is NULL --Ocultar información de Nestea desde Abr 2018 | Responsable: Negocio Cafes
                  and e.idretailer is NULL--Esconder manualmente clientes a voluntad que por algún motivo tengan un error de información aunque formen parte de la muestra Oficial | Responsable: A. Ruz
                  and f.idstore is NULL--Esconder manualmente clientes a voluntad que por algún motivo tengan un error de información aunque formen parte de la muestra Oficial | Responsable: A. Ruz
                  and h.idproduct is NULL--Esconder manualmente clientes a voluntad que por algún motivo tengan un error de información aunque formen parte de la muestra Oficial | Responsable: A. Ruz
                  and i.division is NULL--Esconder manualmente clientes a voluntad que por algún motivo tengan un error de información aunque formen parte de la muestra Oficial | Responsable: A. Ruz
                  and j.MG is NULL--Se esconde la data de SO del MG de Maquinas DG | Responsable: GLOBE/S. García
                 ),


bd_final_so as (
                select
                idRetailer,
                chainstore,
                coalesce(retailer_dsc_corta,'SIN ASIGNACION') as retailer_dsc_corta,
                idstore,
                retailerStoreKey,
                codestore,
                coalesce(tienda_dsc,'SIN ASIGNACION') as tienda_dsc,
                idproduct,
                upc,
                coalesce(descripcion_producto,'SIN ASIGNACION') as descripcion_producto,
                firstday_semana_nestle,
                lastday_semana_nestle,
                semana_nestle_num,
                Mes_Nestle,
                Mes_Nestle_Num,
                yearNestle,
                coalesce(sales_organization,'SIN ASIGNACION') as sales_organization,
                coalesce(dist_channel,'SIN ASIGNACION') as dist_channel,
                coalesce(canal,'SIN ASIGNACION') as canal,
                coalesce(tienda_estado,'SIN ASIGNACION') as tienda_estado,
                coalesce(region_dsc,'SIN ASIGNACION') as region_dsc,
                coalesce(formato,'SIN ASIGNACION') as formato,
                coalesce(muestra_oficial_resto,'SIN ASIGNACION') as muestra_oficial_resto,
                coalesce(Innovacionformato,'SIN ASIGNACION') as Innovacionformato,
                coalesce(formato_equivalente,'SIN ASIGNACION') as formato_equivalente,
                coalesce(MG,'SIN ASIGNACION') as MG,
                coalesce(categoria,'SIN ASIGNACION') as categoria,
                coalesce(division,'SIN ASIGNACION') as division,
                coalesce(linea_promocion,'SIN ASIGNACION') as linea_promocion,
                coalesce(Individual_negocio,'SIN ASIGNACION') as Individual_negocio,
                coalesce(in_out,'SIN ASIGNACION') as in_out,
                coalesce(distrito_operaciones,'SIN ASIGNACION') as distrito_operaciones,
                coalesce(region_operaciones,'SIN ASIGNACION') as region_operaciones,
                coalesce(sector_operaciones,'SIN ASIGNACION') as sector_operaciones,
                coalesce(plan_norte,'SIN ASIGNACION') as plan_norte,
                coalesce(tasty,'SIN ASIGNACION') as tasty,
                ventas_unidades,
                Venta_Kilos_Sem,
                ventas_valor,
                Inventario_Unidades,  
                Inventario_Valor,
                case when upper(tipo_retailer)!='TRADICIONAL' then Promedio_VentaUnidades_Semanal/7 else Promedio_VentaUnidades_Semanal end as Promedio_VentaUnidades_Semanal,
                case when upper(tipo_retailer)!='TRADICIONAL' then Promedio_VentaValor_Semanal/7 else Promedio_VentaValor_Semanal end as Promedio_VentaValor_Semanal,
                inventario1,
                inventario2,
                VentaProm_Sem1,
                VentaProm_Sem2


                from tempProm
             ),

BD_SI AS (
          select
          9999 as idretailer,
          'DOLCE GUSTO' as chainstore,
          'DG' as retailer_dsc_corta,
          NULL as idstore,
          NULL as retailerStoreKey,
          NULL as codestore,
          NULL as tienda_dsc,
          NULL as idproduct,
          NULL as upc,
          NULL as descripcion_producto,
          d.firstDayCustomWeek as firstday_semana_nestle,
          d.lastDayCustomWeek as lastday_semana_nestle,
          d.customWeek as semana_nestle_num,
          g.monthNameES as Mes_Nestle,
          d.custommonth as Mes_Nestle_Num,
          d.customyear as yearNestle,
          a.SALES_ORG_KEY as sales_organization,
          a.DISTRIBUTION_CHANNEL_KEY as dist_channel,
          'ECOMMERCE' as canal,
          NULL as tienda_estado,
          NULL as region_dsc,
          NULL as formato,
          'RESTO' as muestra_oficial_resto,
          NULL as Innovacionformato,
          NULL as formato_equivalente,
          b.MATERIAL_GROUP_DESC as MG,
          b.categoria,
          b.division,
          NULL as linea_promocion,
          NULL as Individual_negocio,
          NULL as in_out,
          NULL as distrito_operaciones,
          NULL as region_operaciones,
          NULL as sector_operaciones,
          NULL as plan_norte,
          NULL as tasty,

          format_number(NNS,4) as ventas_valor,
          format_number(BASEQUANTITY,4) as ventas_unidades,
          format_number(REPORTINGQUANTITY,4) as Venta_Kilos_Sem

          from datasets.CV_MX_SI_Net_Customer_Sales a
          left join datasets.CV_MX_SI_Material_Credit b on a.MATERIAL_KEY=b.MATERIAL_KEY
          left join datasets.CV_MX_SI_Clientes_CL4_STG c on a.CLIENT_CL4_KEY=c.client_key
          left join (select * from gold.vcalendars where idCalendar=5) d on CAST(UNIX_TIMESTAMP(a.FECHA_KEY, 'dd/MM/yyyy') AS TIMESTAMP)=CAST(UNIX_TIMESTAMP(d.calendarday, 'yyyy-MM-dd') AS TIMESTAMP)
          left join (select distinct month,monthNameES from gold.vcalendars) g on d.custommonth=g.month 

          where cast(a.DISTRIBUTION_CHANNEL_KEY as int)=14 and cast(a.Jer_clte_Nivel_4 as int)=4836492 
        ),

BD_FinAll as(
             SELECT
             idretailer,
             chainstore,
             retailer_dsc_corta,
             idstore,
             retailerStoreKey,
             codestore,
             tienda_dsc,
             idproduct,
             upc,
             descripcion_producto,
             firstday_semana_nestle,
             lastday_semana_nestle,
             semana_nestle_num,
             Mes_Nestle,
             Mes_Nestle_Num,
             yearNestle,
             sales_organization,
             dist_channel,
             canal,
             tienda_estado,
             region_dsc,
             formato,
             muestra_oficial_resto,
             Innovacionformato,
             formato_equivalente,
             MG,
             categoria,
             division,
             linea_promocion,
             Individual_negocio,
             in_out,
             distrito_operaciones,
             region_operaciones,
             sector_operaciones,
             plan_norte,
             tasty,
             ventas_unidades,
             Venta_Kilos_Sem,
             ventas_valor,
             Inventario_Unidades,  
             Inventario_Valor,
             Promedio_VentaUnidades_Semanal,
             Promedio_VentaValor_Semanal,
             inventario1,
             inventario2,
             VentaProm_Sem1,
             VentaProm_Sem2
             from bd_final_so
             
             union all
             SELECT
             idretailer,
             chainstore,
             retailer_dsc_corta,
             idstore,
             retailerStoreKey,
             codestore,
             tienda_dsc,
             idproduct,
             upc,
             descripcion_producto,
             firstday_semana_nestle,
             lastday_semana_nestle,
             semana_nestle_num,
             Mes_Nestle,
             Mes_Nestle_Num,
             yearNestle,
             sales_organization,
             dist_channel,
             canal,
             tienda_estado,
             region_dsc,
             formato,
             muestra_oficial_resto,
             Innovacionformato,
             formato_equivalente,
             MG,
             categoria,
             division,
             linea_promocion,
             Individual_negocio,
             in_out,
             distrito_operaciones,
             region_operaciones,
             sector_operaciones,
             plan_norte,
             tasty,
             ventas_unidades,
             Venta_Kilos_Sem,
             ventas_valor,
             NULL as Inventario_Unidades,  
             NULL as Inventario_Valor,
             0 as Promedio_VentaUnidades_Semanal,
             0 as Promedio_VentaValor_Semanal,
             NULL as inventario1,
             NULL as inventario2,
             NULL as VentaProm_Sem1,
             NULL as VentaProm_Sem2
             from BD_SI
            ),

BD_FILTER_TIME AS (
                   select 
                   firstDayCustomWeek 
                   from (
                         SELECT 
                         firstDayCustomWeek, 
                         row_number() OVER (PARTITION BY customYear,customMonth order by firstDayCustomWeek desc) as rk 
                         from gold.vcalendars where idCalendar=5
                         ) g 
                   where rk=1
                  ),


bd_final_filter as (          
                    Select
                    IDRETAILER,
                    CHAINSTORE,
                    RETAILER_DSC_CORTA,
                    IDSTORE,
                    RETAILERSTOREKEY,
                    CODESTORE,
                    TIENDA_DSC,
                    IDPRODUCT,
                    UPC,
                    DESCRIPCION_PRODUCTO,
                    FIRSTDAY_SEMANA_NESTLE as SEMANA_NESTLE,
                    SEMANA_NESTLE_NUM,
                    MES_NESTLE,
                    MES_NESTLE_NUM,
                    YEARNESTLE,
                    SALES_ORGANIZATION,
                    DIST_CHANNEL,
                    CANAL,
                    TIENDA_ESTADO,
                    REGION_DSC,
                    FORMATO,
                    MUESTRA_OFICIAL_RESTO,
                    INNOVACIONFORMATO,
                    FORMATO_EQUIVALENTE,
                    MG,
                    CATEGORIA,
                    DIVISION,
                    LINEA_PROMOCION,
                    INDIVIDUAL_NEGOCIO,
                    IN_OUT,
                    DISTRITO_OPERACIONES,
                    REGION_OPERACIONES,
                    SECTOR_OPERACIONES,
                    PLAN_NORTE,
                    TASTY,
                    VENTAS_UNIDADES,
                    VENTA_KILOS_SEM,
                    VENTAS_VALOR,
                    INVENTARIO_UNIDADES,  
                    INVENTARIO_VALOR,
                    PROMEDIO_VENTAUNIDADES_SEMANAL,
                    PROMEDIO_VENTAVALOR_SEMANAL,
                    INVENTARIO1,
                    INVENTARIO2,
                    VENTAPROM_SEM1,
                    VENTAPROM_SEM2,
                    case when year(current_date()-10)=a.yearNestle and month(current_date()-10)=a.mes_nestle_num then 
                    case when current_date()-10 BETWEEN a.FIRSTDAY_SEMANA_NESTLE and a.LASTDAY_SEMANA_NESTLE then 1 else 0 end
                    else
                    case when b.firstDayCustomWeek is NULL then 0 else 1 end 
                    end
                    as FLAG_ULT_SEM_MES 

                    from BD_FinAll a
                    LEFT JOIN BD_FILTER_TIME b on a.FIRSTDAY_SEMANA_NESTLE=b.firstDayCustomWeek 
                  ),

bd_filter_semana as (
                     select
                     MAX(SEMANA_NESTLE) as ULT_SEMANA_NESTLE
                     from(
                          Select
                          distinct 
                          SEMANA_NESTLE
                          From bd_final_filter
                          where FLAG_ULT_SEM_MES=1
                         )
                    )
                    
SELECT
IDRETAILER,
CHAINSTORE,
RETAILER_DSC_CORTA,
IDSTORE,
RETAILERSTOREKEY,
CODESTORE,
TIENDA_DSC,
IDPRODUCT,
UPC,
DESCRIPCION_PRODUCTO,
SEMANA_NESTLE,
SEMANA_NESTLE_NUM,
FLAG_ULT_SEM_MES,
MES_NESTLE,
MES_NESTLE_NUM,
YEARNESTLE,
SALES_ORGANIZATION,
DIST_CHANNEL,
CANAL,
TIENDA_ESTADO,
REGION_DSC,
FORMATO,
MUESTRA_OFICIAL_RESTO,
INNOVACIONFORMATO,
FORMATO_EQUIVALENTE,
MG,
CATEGORIA,
DIVISION,
LINEA_PROMOCION,
INDIVIDUAL_NEGOCIO,
IN_OUT,
DISTRITO_OPERACIONES,
REGION_OPERACIONES,
SECTOR_OPERACIONES,
PLAN_NORTE,
TASTY,
VENTAS_UNIDADES,
VENTA_KILOS_SEM,
VENTAS_VALOR,
INVENTARIO_UNIDADES,  
INVENTARIO_VALOR,
PROMEDIO_VENTAUNIDADES_SEMANAL,
PROMEDIO_VENTAVALOR_SEMANAL,
INVENTARIO1,
INVENTARIO2,
VENTAPROM_SEM1,
VENTAPROM_SEM2

from bd_final_filter a  
join bd_filter_semana b 

where SEMANA_NESTLE <=b.ULT_SEMANA_NESTLE


