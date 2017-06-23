-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
-- clean code for monthly view
---Add these to the final table and select those for the report on downtraders
--Parent Account Number	Company Name 	Customer Number (CUS ID)	Sales Territory	FY Revenue 2016	YTD Revenue 2016	YTD Revenue 2017	% Variance	Last 3 months Revenue 2017	Same 3 months revenue 2016	% Variance	Last 3 month Cons 2017	Same 3 months Cons 2016	% Variance	Last 3 months revenue 2017	Previous 3 monts revenue 2017	% Variance	Last Sales Contact Date
DROP TABLE if exists stg2_Customer_downtraders_monthly;
--select count(*), acc_country from stg2_Customer_downtraders_monthly group by acc_country;
CREATE TABLE stg2_Customer_downtraders_monthly 
AS
SELECT acc.cus_id,
       lac_legacy_cou_cd AS acc_country,
       DATE_TRUNC('month',fc.con_create_dt) AS month_dt,
       DATE_TRUNC('quarter',fc.con_create_dt) AS quarter_dt,
       DATE_TRUNC('year',fc.con_create_dt) AS year_dt,
       MAX(fc.con_create_dt) AS max_con_create_dt,
       MIN(fc.con_create_dt) AS min_con_create_dt,
       MAX(fc.rs_insert_date) AS rs_insert_date,
       COUNT(*) AS count_consignments,
       SUM(CAST(fc.is_sender_pays AS INTEGER)) AS is_sender_pays,
       SUM(CAST(fc.is_receiver_pays AS INTEGER)) AS is_receiver_pays,
       SUM(CAST(fc.is_international_shipment AS INTEGER)) AS is_international_shipment,
       SUM(CAST(fc.is_dangerous_shipment AS INTEGER)) AS is_dangerous_shipment,
       MAX(fc.bul_id_orig) AS bul_id_orig,
       COUNT(fc.cac_id) AS count_accounts_under_customer,
       --MAX(acc.lac_legacy_cou_cd) AS acc_country,
       SUM(fc.goods_value) AS goods_value,
       SUM(fc.shipments) AS shipments,
       CAST(SUM(fc.revenue) AS INT) AS revenue,
       SUM(fc.sum_volume) AS sum_volume,
       SUM(fc.sum_items) AS sum_items,
       SUM(fc.sum_weight) AS sum_weight,
       SUM(CAST(prd.is_express_prdct AS INTEGER)) AS is_express_prdct,
       SUM(CAST(prd.is_economy_prdct AS INTEGER)) AS is_economy_prdct,
       SUM(CAST(prd.is_special_prdct AS INTEGER)) AS is_special_prdct,
       SUM(con.is_express_tool) AS is_express_tool,
       SUM(con.is_mytnt_tool) AS is_mytnt_tool,
       SUM(con.is_local_tool) AS is_local_tool,
       SUM(con.is_open_tool) AS is_open_tool,
       SUM(con.is_custom_tool) AS is_custom_tool,
       SUM(con.is_digital_tool) AS is_digital_tool,
       SUM(con.is_manual_tool) AS is_manual_tool,
       SUM(CASE WHEN prd.product_family_cd = 'VA' THEN 1 ELSE 0 END) AS prod_is_VA,
       SUM(CASE WHEN prd.product_family_cd = 'DT' THEN 1 ELSE 0 END) AS prod_is_DT,
       SUM(CASE WHEN prd.product_family_cd = 'XF' THEN 1 ELSE 0 END) AS prod_is_XF,
       SUM(CASE WHEN prd.product_family_cd = 'EF' THEN 1 ELSE 0 END) AS prod_is_EF,
       SUM(CASE WHEN prd.product_family_cd = 'EE' THEN 1 ELSE 0 END) AS prod_is_EE,
       SUM(CASE WHEN prd.product_family_cd = 'SS' THEN 1 ELSE 0 END) AS prod_is_SS,
       SUM(CASE WHEN prd.product_family_cd = 'SE' THEN 1 ELSE 0 END) AS prod_is_SE,
       SUM(CASE WHEN prd.product_family_cd = 'OT' THEN 1 ELSE 0 END) AS prod_is_OT,
       SUM(CASE WHEN prd.product_family_cd = 'FR' THEN 1 ELSE 0 END) AS prod_is_FR,
       SUM(CASE WHEN prd.product_family_cd = 'EX' THEN 1 ELSE 0 END) AS prod_is_EX,
       --create a sum for digital and for non_digital for revenue, volume and shipments
       SUM(CASE WHEN is_digital_tool = 1 THEN revenue END) AS digital_revenue,
       SUM(CASE WHEN is_digital_tool = 1 THEN shipments END) AS digital_shipments,
       SUM(CASE WHEN is_digital_tool = 1 THEN sum_volume END) AS digital_volume,
       SUM(CASE WHEN is_digital_tool = 1 THEN sum_weight END) AS digital_weight,
       SUM(CASE WHEN is_digital_tool = 1 THEN sum_items END) AS digital_items,
       SUM(CASE WHEN is_mytnt_tool = 1 THEN revenue END) AS is_mytnt_revenue,
       SUM(CASE WHEN is_mytnt_tool = 1 THEN shipments END) AS is_mytnt_shipments,
       SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_volume END) AS is_mytnt_volume,
       SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_weight END) AS is_mytnt_weight,
       SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_items END) AS is_mytnt_items,
       SUM(CASE WHEN is_digital_tool != 1 THEN revenue END) AS no_dig_revenue,
       SUM(CASE WHEN is_digital_tool != 1 THEN shipments END) AS no_dig_shipments,
       SUM(CASE WHEN is_digital_tool != 1 THEN sum_volume END) AS no_dig_volume,
       SUM(CASE WHEN is_digital_tool != 1 THEN sum_weight END) AS no_dig_weight,
       SUM(CASE WHEN is_digital_tool != 1 THEN sum_items END) AS no_dig_items
FROM (SELECT *
      FROM stg1_financialconsignment
      WHERE is_invoice_cancelled != 1
      AND   is_shipment_cancelled != 1
      AND   revenue > 0
      AND   shipments > 0
      AND   is_invoice_cancelled = 0
      AND   is_shipment_cancelled = 0) AS fc
  LEFT JOIN stg1_consource AS con ON con.con_source_cd = fc.con_source_cd
  LEFT JOIN stg1_product AS prd ON fc.product_id = prd.product_id
  LEFT JOIN stg1_accntxref AS acc ON fc.cac_id = acc.cac_id
WHERE fc.is_invoice_cancelled != 1
AND   acc.cus_id > 0
AND   fc.is_shipment_cancelled != 1
AND   fc.revenue > 0
AND   fc.shipments > 0
AND   fc.is_invoice_cancelled = 0
AND   fc.is_shipment_cancelled = 0
AND   con_create_dt >= '2014-01-01'
AND   acc.lac_legacy_cou_cd IN ('UK','IE','NL','DE','CY','GR', 'BE')
GROUP BY acc.cus_id,
         acc.lac_legacy_cou_cd,
         DATE_TRUNC('month',fc.con_create_dt),
         DATE_TRUNC('quarter',fc.con_create_dt),
         DATE_TRUNC('year',fc.con_create_dt)
ORDER BY cus_id,
         acc.lac_legacy_cou_cd,
         DATE_TRUNC('month',fc.con_create_dt),
         DATE_TRUNC('quarter',fc.con_create_dt),
         DATE_TRUNC('year',fc.con_create_dt);

-- monthly expand table
DROP TABLE if exists stg2_Customer_downtraders_monthly_exp_all1;

CREATE TABLE stg2_Customer_downtraders_monthly_exp_all1 
AS
SELECT DISTINCT t1.cus_id AS cus_id2,
       t1.acc_country AS acc_country2,
       t2.month_dt AS month_dt2
FROM (SELECT DISTINCT cus_id,
             acc_country
      FROM stg2_Customer_downtraders_monthly) AS t1
  RIGHT OUTER JOIN (SELECT DISTINCT month_dt
                    FROM stg2_Customer_downtraders_monthly) AS t2 ON t1.cus_id = t1.cus_id
GROUP BY cus_id,
         acc_country,
         month_dt
ORDER BY cus_id2,
         acc_country2,
         month_dt2;

--select * from stg2_Customer_downtraders_monthly_exp_all1 ORDER BY cus_id2,         month_dt2 limit 150;
DROP TABLE if exists stg2_Customer_downtraders_monthly_exp_all2;

CREATE TABLE stg2_Customer_downtraders_monthly_exp_all2 
AS
SELECT t1.*,
       t2.*
FROM stg2_Customer_downtraders_monthly_exp_all1 AS t1
  LEFT JOIN stg2_Customer_downtraders_monthly AS t2
--WHERE acc_country IN ('NL','DE')) AS t2

        ON t1.cus_id2 = t2.cus_id
        AND t1.month_dt2 = t2.month_dt
        AND t1.acc_country2 = t2.acc_country
ORDER BY t1.cus_id2,
         t1.acc_country2,
         t1.month_dt2;

DROP TABLE if exists stg2_Customer_downtraders_monthly_cus;

CREATE TABLE stg2_Customer_downtraders_monthly_cus 
AS
SELECT DISTINCT *
FROM (SELECT *
      FROM stg2_Customer_downtraders_monthly_exp_all2 AS fc
        LEFT JOIN (SELECT all_cus_id,
                          all_country,
                          all_max_date,
                          all_min_date
                   FROM stg2_customer_metrics_customer) AS cus
               ON cus.all_cus_id = fc.cus_id2
              AND cus.all_country = fc.acc_country2
              AND month_dt2 <= DATE_TRUNC ('month',all_max_date)
              AND month_dt2 >= DATE_TRUNC ('month',all_min_date))
WHERE month_dt2 >= '2014-01-01'
AND   DATE_TRUNC('month',all_max_date) >= month_dt2
AND   DATE_TRUNC('month',all_min_date) <= month_dt2
ORDER BY cus_id2,
         acc_country2,
         month_dt2;

--select * from stg2_Customer_downtraders_monthly_seq limit 100;
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DROP TABLE if exists stg2_Customer_downtraders_monthly_seq;
--select * from stg2_Customer_downtraders_monthly_seq order by cus_id, month_dt limit 100;
CREATE TABLE stg2_Customer_downtraders_monthly_seq 
AS
SELECT *,
       -- Calculate the revenue for before 3 months
       CASE
         WHEN month_seq_con > 1 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_1,
       CASE
         WHEN month_seq_con > 2 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_2,
       CASE
         WHEN month_seq_con > 3 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_3,
       CASE
         WHEN month_seq_con > 4 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_4,
       CASE
         WHEN month_seq_con > 5 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_5,
       CASE
         WHEN month_seq_con > 6 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_6,
       CASE
         WHEN month_seq_con > 9 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_9,
       CASE
         WHEN month_seq_con > 12 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_12,
       CASE
         WHEN month_seq_con > 24 THEN AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_avg_revenue_24,
       CASE
         WHEN month_seq_con > 1 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_1,
       CASE
         WHEN month_seq_con > 2 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_2,
       CASE
         WHEN month_seq_con > 3 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_3,
       CASE
         WHEN month_seq_con > 4 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_4,
       CASE
         WHEN month_seq_con > 5 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_5,
       CASE
         WHEN month_seq_con > 6 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_6,
       CASE
         WHEN month_seq_con > 9 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_9,
       CASE
         WHEN month_seq_con > 12 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_12,
       CASE
         WHEN month_seq_con > 24 THEN AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_avg_shipments_24,
       CASE
         WHEN month_seq_con > 1 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_1,
       CASE
         WHEN month_seq_con > 2 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_2,
       CASE
         WHEN month_seq_con > 3 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_3,
       CASE
         WHEN month_seq_con > 4 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_4,
       CASE
         WHEN month_seq_con > 5 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_5,
       CASE
         WHEN month_seq_con > 6 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_6,
       CASE
         WHEN month_seq_con > 9 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_9,
       CASE
         WHEN month_seq_con > 12 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_12,
       CASE
         WHEN month_seq_con > 24 THEN AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_volume_24,
       CASE
         WHEN month_seq_con > 1 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_1,
       CASE
         WHEN month_seq_con > 2 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_2,
       CASE
         WHEN month_seq_con > 3 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_3,
       CASE
         WHEN month_seq_con > 4 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_4,
       CASE
         WHEN month_seq_con > 5 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_5,
       CASE
         WHEN month_seq_con > 6 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_6,
       CASE
         WHEN month_seq_con > 9 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_9,
       CASE
         WHEN month_seq_con > 12 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_12,
       CASE
         WHEN month_seq_con > 24 THEN AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_items_24,
       CASE
         WHEN month_seq_con > 1 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_1,
       CASE
         WHEN month_seq_con > 2 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_2,
       CASE
         WHEN month_seq_con > 3 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_3,
       CASE
         WHEN month_seq_con > 4 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_4,
       CASE
         WHEN month_seq_con > 5 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_5,
       CASE
         WHEN month_seq_con > 6 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_6,
       CASE
         WHEN month_seq_con > 9 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_9,
       CASE
         WHEN month_seq_con > 12 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_12,
       CASE
         WHEN month_seq_con > 24 THEN AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_avg_sum_weight_24,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_1,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_2,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_3,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_4,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_5,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_6,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_9,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_12,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_std_revenue_24,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_1,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_2,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_3,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_4,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_5,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_6,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_9,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_12,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_std_shipments_24,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_1,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_2,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_3,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_4,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_5,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_6,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_9,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_12,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_volume_24,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_1,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_2,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_3,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_4,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_5,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_6,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_9,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_12,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_items_24,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_1,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_2,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_3,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_4,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_5,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_6,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_9,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_12,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_std_sum_weight_24,
       ---------------------------------------------------
       --Time inbetween
       ---------------------------------------------------
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 1 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between1,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between2,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 3 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between3,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between4,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 5 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between5,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 6 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between6,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 9 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between9,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 12 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between12,
       CASE
         WHEN month_seq_con > 1 THEN stddev_pop (datediff (month,month_dt,month_lag_dt)) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN 24 PRECEDING AND CURRENT ROW)
       END AS month_std_months_between24,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_sender_pays AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_sender_pays,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_receiver_pays AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_receiver_pays,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_international_shipment AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_international_shipment,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_dangerous_shipment AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_dangerous_shipment,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_express_prdct AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_express_prdct,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_economy_prdct AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_economy_prdct,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_special_prdct AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_special_prdct,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_express_tool AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_express_tool,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_mytnt_tool AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_mytnt_tool,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_local_tool AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_local_tool,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_open_tool AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_open_tool,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_custom_tool AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_custom_tool,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_digital_tool AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_digital_tool,
       CASE
         WHEN month_seq_count_consignments > 0 THEN CAST(CAST(month_seq_is_manual_tool AS FLOAT) / month_seq_count_consignments AS FLOAT)
         ELSE 0
       END AS m_perc_is_manual_tool
FROM (
-- at this level we have already aggregated all our data on an account con_create dt
-- we will create using windowing the necessary consignment and con create date information
-- on teh next step will create a customer level table
-- it runs

     SELECT*,ROW_NUMBER() OVER (PARTITION BY cus_id,acc_country
ORDER BY month_dt) AS month_seq_con,
         SUM(is_sender_pays) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_sender_pays,
         SUM(count_consignments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_count_consignments,
         SUM(is_receiver_pays) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_receiver_pays,
         SUM(is_international_shipment) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_international_shipment,
         SUM(is_dangerous_shipment) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_dangerous_shipment,
         SUM(goods_value) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_goods_value,
         SUM(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_shipments,
         SUM(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_revenue,
         SUM(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_volume,
         SUM(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_items,
         SUM(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_weight,
         -- Digital  
         SUM(digital_shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_digital_shipments,
         SUM(digital_revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_digital_revenue,
         SUM(digital_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_digital_volume,
         SUM(digital_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_digital_items,
         SUM(digital_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_digital_weight,
         -- my_tnt  
         SUM(is_mytnt_shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_mytnt_shipments,
         SUM(is_mytnt_revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_mytnt_revenue,
         SUM(is_mytnt_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_mytnt_volume,
         SUM(is_mytnt_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_mytnt_items,
         SUM(is_mytnt_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_mytnt_weight,
         -- non digital 
         SUM(no_dig_shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_no_dig_shipments,
         SUM(no_dig_revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_no_dig_revenue,
         SUM(no_dig_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_no_dig_volume,
         SUM(no_dig_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_no_dig_items,
         SUM(no_dig_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_no_dig_weight,
         SUM(is_express_prdct) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_express_prdct,
         SUM(is_economy_prdct) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_economy_prdct,
         SUM(is_special_prdct) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_special_prdct,
         SUM(is_express_tool) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_express_tool,
         SUM(is_mytnt_tool) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_mytnt_tool,
         SUM(is_local_tool) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_local_tool,
         SUM(is_open_tool) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_open_tool,
         SUM(is_custom_tool) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_custom_tool,
         SUM(is_digital_tool) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_digital_tool,
         SUM(is_manual_tool) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_is_manual_tool,
         SUM(prod_is_VA) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_VA,
         SUM(prod_is_DT) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_DT,
         SUM(prod_is_XF) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_XF,
         SUM(prod_is_EF) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_EF,
         SUM(prod_is_EE) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_EE,
         SUM(prod_is_SS) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_SS,
         SUM(prod_is_SE) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_SE,
         SUM(prod_is_OT) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_OT,
         SUM(prod_is_FR) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_FR,
         SUM(prod_is_FR) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_prod_is_EX,
         AVG(goods_value) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_avg_goods_value,
         AVG(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_avg_shipments,
         AVG(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_avg_revenue,
         AVG(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_avg_volume,
         AVG(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_avg_items,
         AVG(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_avg_weight,
         stddev_pop(goods_value) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_std_goods_value,
         stddev_pop(shipments) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_std_shipments,
         stddev_pop(revenue) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_std_revenue,
         stddev_pop(sum_volume) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_std_volume,
         stddev_pop(sum_items) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_std_items,
         stddev_pop(sum_weight) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS month_seq_std_weight,
         LAG(month_dt,1) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt) AS month_lag_dt,
         LAG(month_dt,1) OVER (PARTITION BY cus_id,acc_country ORDER BY month_dt DESC) AS month_churn_lag_dt FROM (SELECT DISTINCT month_dt2 AS month_dt,
                                                                                                                          cus_id2 AS cus_id,
                                                                                                                          acc_country2 AS acc_country,
                                                                                                                          CASE
                                                                                                                            WHEN max_con_create_dt IS NULL THEN 0
                                                                                                                            ELSE 1
                                                                                                                          END AS active_month,
                                                                                                                          CASE
                                                                                                                            WHEN max_con_create_dt IS NULL THEN month_dt2
                                                                                                                            ELSE max_con_create_dt
                                                                                                                          END AS max_con_create_dt,
                                                                                                                          CASE
                                                                                                                            WHEN min_con_create_dt IS NULL THEN month_dt2
                                                                                                                            ELSE min_con_create_dt
                                                                                                                          END AS min_con_create_dt,
                                                                                                                          COALESCE(count_consignments,0) AS count_consignments,
                                                                                                                          COALESCE(is_sender_pays,0) AS is_sender_pays,
                                                                                                                          COALESCE(is_receiver_pays,0) AS is_receiver_pays,
                                                                                                                          COALESCE(is_international_shipment,0) AS is_international_shipment,
                                                                                                                          COALESCE(is_dangerous_shipment,0) AS is_dangerous_shipment,
                                                                                                                          COALESCE(goods_value,0) AS goods_value,
                                                                                                                          COALESCE(shipments,0) AS shipments,
                                                                                                                          COALESCE(revenue,0) AS revenue,
                                                                                                                          COALESCE(sum_volume,0) AS sum_volume,
                                                                                                                          COALESCE(sum_items,0) AS sum_items,
                                                                                                                          COALESCE(sum_weight,0) AS sum_weight,
                                                                                                                          COALESCE(is_express_prdct,0) AS is_express_prdct,
                                                                                                                          COALESCE(is_economy_prdct,0) AS is_economy_prdct,
                                                                                                                          COALESCE(is_special_prdct,0) AS is_special_prdct,
                                                                                                                          COALESCE(is_express_tool,0) AS is_express_tool,
                                                                                                                          COALESCE(is_mytnt_tool,0) AS is_mytnt_tool,
                                                                                                                          COALESCE(is_local_tool,0) AS is_local_tool,
                                                                                                                          COALESCE(is_open_tool,0) AS is_open_tool,
                                                                                                                          COALESCE(is_custom_tool,0) AS is_custom_tool,
                                                                                                                          COALESCE(is_digital_tool,0) AS is_digital_tool,
                                                                                                                          COALESCE(is_manual_tool,0) AS is_manual_tool,
                                                                                                                          COALESCE(prod_is_va,0) AS prod_is_va,
                                                                                                                          COALESCE(prod_is_dt,0) AS prod_is_dt,
                                                                                                                          COALESCE(prod_is_xf,0) AS prod_is_xf,
                                                                                                                          COALESCE(prod_is_ef,0) AS prod_is_ef,
                                                                                                                          COALESCE(prod_is_ee,0) AS prod_is_ee,
                                                                                                                          COALESCE(prod_is_ss,0) AS prod_is_ss,
                                                                                                                          COALESCE(prod_is_se,0) AS prod_is_se,
                                                                                                                          COALESCE(prod_is_ot,0) AS prod_is_ot,
                                                                                                                          COALESCE(prod_is_fr,0) AS prod_is_fr,
                                                                                                                          COALESCE(prod_is_ex,0) AS prod_is_ex,
                                                                                                                          COALESCE(digital_revenue,0) AS digital_revenue,
                                                                                                                          COALESCE(digital_shipments,0) AS digital_shipments,
                                                                                                                          COALESCE(digital_volume,0) AS digital_volume,
                                                                                                                          COALESCE(digital_weight,0) AS digital_weight,
                                                                                                                          COALESCE(digital_items,0) AS digital_items,
                                                                                                                          COALESCE(is_mytnt_revenue,0) AS is_mytnt_revenue,
                                                                                                                          COALESCE(is_mytnt_shipments,0) AS is_mytnt_shipments,
                                                                                                                          COALESCE(is_mytnt_volume,0) AS is_mytnt_volume,
                                                                                                                          COALESCE(is_mytnt_weight,0) AS is_mytnt_weight,
                                                                                                                          COALESCE(is_mytnt_items,0) AS is_mytnt_items,
                                                                                                                          COALESCE(no_dig_revenue,0) AS no_dig_revenue,
                                                                                                                          COALESCE(no_dig_shipments,0) AS no_dig_shipments,
                                                                                                                          COALESCE(no_dig_volume,0) AS no_dig_volume,
                                                                                                                          COALESCE(no_dig_weight,0) AS no_dig_weight,
                                                                                                                          COALESCE(no_dig_items,0) AS no_dig_items
                                                                                                                   FROM stg2_Customer_downtraders_monthly_cus));

-- join customer table and fincon daily table and keep only necessary fields
--create table stg2_Customer_downtraders_monthly_seq_full_backup as select * from stg2_Customer_downtraders_monthly_seq_full;
DROP TABLE if exists stg2_Customer_downtraders_monthly_seq_full;
--select distinct conf_10_interval_95 from stg2_Customer_downtraders_monthly_seq_full limit 100;
CREATE TABLE stg2_Customer_downtraders_monthly_seq_full 
AS
SELECT DISTINCT * /*
      CASE
         WHEN downtrade_monthly_weight_3 < -0.20 AND focus_churn_monthly = 1 THEN 1
         ELSE 0
       END AS downtrade_monthly_weight_3_flag,
       CASE
         WHEN downtrade_monthly_weight_6 < -0.20 AND focus_churn_monthly = 1 THEN 1
         ELSE 0
       END AS downtrade_monthly_weight_6_flag,
       CASE
         WHEN downtrade_monthly_revenue_3 < -0.20 AND focus_churn_monthly = 1 THEN 1
         ELSE 0
       END AS downtrade_monthly_revenue_3_flag,
       CASE
         WHEN downtrade_monthly_revenue_6 < -0.20 AND focus_churn_monthly = 1 THEN 1
         ELSE 0
       END AS downtrade_monthly_revenue_6_flag*/
-- Calculate the downtraders flags
       -- Create at least 3 downtrader flags based on the period of time back
       -- Calculate the significance intervals of the downtraders
       -------------------------------------------------------------------------------------------------------------------------------------------------------       
       -------------------------------------------------------------------------------------------------------------------------------------------------------       
       FROM (SELECT t1.*,
                    ABS((datediff (DAY,month_dt,DATE_TRUNC('month',all_min_date)))) AS lifetime,
                    CASE
                      WHEN seq_shipments > 0 AND seq_revenue > 0 AND seq_volume > 0 THEN 0
                      ELSE 7
                    END AS month_seq_days_between,
                    CASE
                      WHEN month_avg_sum_weight_12 > 0 THEN (month_avg_sum_weight_3 - month_avg_sum_weight_12) / month_avg_sum_weight_12
                      ELSE 0
                    END AS downtrade_monthly_weight_3,
                    CASE
                      WHEN month_avg_sum_weight_12 > 0 THEN (month_avg_sum_weight_6 - month_avg_sum_weight_12) / month_avg_sum_weight_12
                      ELSE 0
                    END AS downtrade_monthly_weight_6,
                    CASE
                      WHEN month_avg_revenue_12 > 0 THEN (month_avg_revenue_3 - month_avg_revenue_12) / month_avg_revenue_12
                      ELSE 0
                    END AS downtrade_monthly_revenue_3,
                    CASE
                      WHEN month_avg_revenue_12 > 0 THEN (month_avg_revenue_6 - month_avg_revenue_12) / month_avg_revenue_12
                      ELSE 0
                    END AS downtrade_monthly_revenue_6,
                    ----
                    CASE
                      WHEN t2.max_cons >= 30 AND month_avg_sum_weight_12 > 0 AND t2.all_sum_revenue >= 1000 THEN 1
                      ELSE 0
                    END AS focus_downtrader_monthly,
                    CASE
                      WHEN t2.max_cons >= 30 AND month_avg_sum_weight_12 > 0 AND t2.all_sum_revenue >= 300 THEN 1
                      ELSE 0
                    END AS focus_churn_monthly,
                    CASE
                      WHEN t2.nrmd_churn_dt > max_con_create_dt THEN 1
                      ELSE 0
                    END churn_month_flag,
                    CASE
                      WHEN t2.nrm_10_churn_dt > max_con_create_dt THEN 1
                      ELSE 0
                    END churn_10_month_flag,
                    t2.con_create_dt,
                    t2.lag_dt,
                    t2.churn_lag_dt,
                    t2.seq_days_between,
                    t2.seq_avg3_days_between,
                    t2.seq_avg10_days_between,
                    t2.seq_avg30_days_between,
                    t2.seq_avg_days_between,
                    t2.seq_std_days_between,
                    t2.seq_std10_days_between,
                    t2.seq_median_days_between,
                    t2.weekly,
                    t2.biweekly,
                    t2.monthly,
                    t2.quarterly,
                    t2.half_yearly,
                    t2.yearly,
                    t2.nonactive,
                    t2.frequency,
                    t2.all_cus_id,
                    t2.all_days_active,
                    t2.all_country,
                    t2.seq_ytd_shipments,
                    t2.seq_ytd_revenue,
                    t2.seq_ytd_volume,
                    t2.seq_ytd_items,
                    t2.seq_ytd_weight,
                    --t2.all_lac_legacy_acg_cd,
                    --t2.all_lac_legacy_acct_nr,
                    --t2.all_lac_legacy_nad_cd,
                    t2.all_shipments_2014,
                    t2.all_shipments_2015,
                    t2.all_shipments_2016,
                    t2.all_shipments_2017,
                    t2.all_revenue_2014,
                    t2.all_revenue_2015,
                    t2.all_revenue_2016,
                    t2.all_revenue_2017,
                    t2.all_sum_volume_2014,
                    t2.all_sum_volume_2015,
                    t2.all_sum_volume_2016,
                    t2.all_sum_volume_2017,
                    t2.all_sum_weight_2014,
                    t2.all_sum_weight_2015,
                    t2.all_sum_weight_2016,
                    t2.all_sum_weight_2017,
                    t2.all_sum_items_2014,
                    t2.all_sum_items_2015,
                    t2.all_sum_items_2016,
                    t2.all_sum_items_2017,
                    t2.all_weekly,
                    t2.all_biweekly,
                    t2.all_monthly,
                    t2.all_quarterly,
                    t2.all_half_yearly,
                    t2.all_yearly,
                    t2.all_avg_days_between,
                    t2.all_std_days_between,
                    t2.max_cons,
                    t2.all_count_consignments,
                    t2.count_seq_con,
                    t2.all_is_sender_pays,
                    t2.all_is_receiver_pays,
                    t2.all_is_international_shipment,
                    t2.all_is_dangerous_shipment,
                    t2.all_bul_id_orig,
                    t2.all_sum_goods_value,
                    t2.all_sum_shipments,
                    t2.all_sum_revenue,
                    t2.all_sum_volume,
                    t2.all_sum_items,
                    t2.all_sum_weight,
                    t2.all_is_express_prdct,
                    t2.all_is_economy_prdct,
                    t2.all_is_special_prdct,
                    t2.all_is_express_tool,
                    t2.all_is_mytnt_tool,
                    t2.all_is_local_tool,
                    t2.all_is_open_tool,
                    t2.all_is_custom_tool,
                    t2.all_is_digital_tool,
                    t2.all_is_manual_tool,
                    t2.all_min_date,
                    t2.all_max_date,
                    t2.all_avg_goods_value,
                    t2.all_avg_shipments,
                    t2.all_avg_revenue,
                    t2.all_avg_volume,
                    t2.all_avg_items,
                    t2.all_avg_weight,
                    t2.all_std_goods_value,
                    t2.all_std_shipments,
                    t2.all_std_revenue,
                    t2.all_std_volume,
                    t2.all_std_items,
                    t2.all_std_weight,
                    t2.all_digital_revenue,
                    t2.all_digital_shipments,
                    t2.all_digital_volume,
                    t2.all_digital_weight,
                    t2.all_digital_items,
                    t2.all_is_mytnt_revenue,
                    t2.all_is_mytnt_shipments,
                    t2.all_is_mytnt_volume,
                    t2.all_is_mytnt_weight,
                    t2.all_is_mytnt_items,
                    t2.all_no_dig_revenue,
                    t2.all_no_dig_shipments,
                    t2.all_no_dig_volume,
                    t2.all_no_dig_weight,
                    t2.all_no_dig_items,
                    t2.growth_cust,
                    t2.st_cus_id,
                    t2.cus_cou_id,
                    t2.cust_sales_territory_cd,
                    t2.st_cust_sales_type_desc2,
                    t2.all_perc_weekly,
                    t2.all_perc_biweekly,
                    t2.all_perc_monthly,
                    t2.all_perc_half_yearly,
                    t2.all_perc_quarterly,
                    t2.all_perc_yearly,
                    t2.perc_all_is_sender_pays,
                    t2.perc_all_is_receiver_pays,
                    t2.perc_all_is_international_shipment,
                    t2.perc_all_is_dangerous_shipment,
                    t2.perc_all_is_express_prdct,
                    t2.perc_all_is_economy_prdct,
                    t2.perc_all_is_special_prdct,
                    t2.perc_all_is_express_tool,
                    t2.perc_all_is_mytnt_tool,
                    t2.perc_all_is_local_tool,
                    t2.perc_all_is_open_tool,
                    t2.perc_all_is_custom_tool,
                    t2.perc_all_is_digital_tool,
                    t2.perc_all_is_manual_tool,
                    t2.conf_10_interval_95,
                    t2.conf_interval_95,
                    t2.churn_days_between,
                    t2.perc_seq_prod_is_va,
                    t2.perc_seq_prod_is_dt,
                    t2.perc_seq_prod_is_xf,
                    t2.perc_seq_prod_is_ef,
                    t2.perc_seq_prod_is_ee,
                    t2.perc_seq_prod_is_ss,
                    t2.perc_seq_prod_is_se,
                    t2.perc_seq_prod_is_ot,
                    t2.perc_seq_prod_is_fr,
                    t2.perc_seq_prod_is_ex,
                    t2.nrmd_churn_dt,
                    t2.nrm_10_churn_dt,
                    t2.yellow_nrmd_churn_dt,
                    t2.yellow_nrm_10_churn_dt,
                    t2.yellow_conf_10_interval_95,
                    t2.yellow_conf_interval_95,
                    t2.churn_10nrw_dis,
                    t2.churn_nrw_dis,
                    t2.churn_nrw_10days,
                    t2.churn_nrw_30days,
                    t2.churn_nrw_90days,
                    t2.churn_nrw_365days,
                    ABS(datediff (days,t1.month_dt,CURRENT_DATE)) AS month_seq_days_from_today,
                    ABS(datediff (days,t1.month_dt,all_min_date)) AS month_seq_days_active
             -------------------------------------------------------------------------------------------------------------------------------------------------------       
                    -------------------------------------------------------------------------------------------------------------------------------------------------------       
                    FROM stg2_Customer_downtraders_monthly_seq AS t1
               LEFT JOIN stg2_customer_daily_metrics_customer AS t2
                      ON t1.cus_id = t2.cus_id
                     AND t1.acc_country = t2.all_country
                     AND ( (t2.con_create_dt <= t1.max_con_create_dt
                     AND t2.churn_lag_dt > t1.max_con_create_dt)
                      OR t2.con_create_dt = t1.max_con_create_dt))
ORDER BY all_country,
         cus_id,
         month_dt;

GRANT SELECT
  ON stg2_Customer_downtraders_monthly_seq_full
  TO public;
/*
SELECT t2.yellow_nrmd_churn_dt,
       t2.yellow_nrm_10_churn_dt,
       t2.yellow_conf_10_interval_95,
       t2.yellow_conf_interval_95
FROM stg2_Customer_downtraders_monthly_seq_full AS t2;

SELECT *
FROM stg2_Customer_downtraders_monthly_seq_full
ORDER BY cus_id DESC LIMIT 1000;

--select cus_id, con_create_dt, all_country, count(*) from stg2_customer_daily_metrics_customer group by cus_id, con_create_dt, all_country having count(*)>1 ORDER BY count(*) DESC;
--drop table if exists xx;
--create table xx as select * from stg2_Customer_downtraders_monthly_seq_full where all_lac_legacy_cou_cd = 'GR' and all_max_date > '2017-01-01' order by all_lac_legacy_cou_cd, cus_id, month_dt limit 100000; 
--select * from stg2_Customer_downtraders_monthly_seq_full where cust_sales_type_desc is not null limit 100;
--select distinct all_lac_legacy_cou_cd, count(*) from stg2_Customer_downtraders_monthly_seq_full group by all_lac_legacy_cou_cd order by all_lac_legacy_cou_cd ;
--select * from stg2_customer_metrics_customer where all_min_date > '2016-01-01' order by all_lac_legacy_cou_cd, all_sum_revenue, all_cus_id limit 500000;

stg2_Customer_downtraders_monthly_seq_full
