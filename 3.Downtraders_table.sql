-- # of shipments
-- days until last shipment
-- dummy variables of frequency of orders(weekly/ biweekly etc)
-- revenue
-- volume
-- conf_10_interval_95
DROP TABLE if exists stg3_downtraders_sample;

--select yellow_nrmd_churn_dt from stg2_downtraders_monthly_seq_full limit 10;
--select * from x_downtraders_sample limit 100;
CREATE TABLE stg3_downtraders_sample 
AS
SELECT DISTINCT---dateadd(month,1,m1.dmonth_dt1) AS lag_m,
       t1.*,
       m1.*,
       m3.*,
       m12.*
       --perc_chg_month_avg_revenue_3_lag3
-- joins
       FROM (SELECT *,
                    DATE_TRUNC('year',month_dt) AS year_dt,
                    DATE_TRUNC('quarter',month_dt) AS quarter_dt,
                    dateadd(MONTH,-1,month_dt) AS month_lag_dt1,
                    dateadd(MONTH,-3,month_dt) AS month_lag_dt3,
                    dateadd(MONTH,-12,month_dt) AS month_lag_dt12
             FROM stg2_Customer_downtraders_monthly_seq_full
             WHERE cus_id > 0
             --and
             --acc_country IN ('IE','GB', 'GR', 'PT')
             AND   all_max_date > 0
             --AND   max_cons > 20
             --AND   all_sum_shipments > 20
             --AND   all_sum_revenue > 500
             --AND   all_days_active > 300
             ORDER BY cus_id,
                      month_lag_dt1) AS t1
  LEFT JOIN
-- Monthly join lag 1
 (SELECT month_dt AS month_dt_lag1,
         cus_id AS cus_id_lag1,
         active_month AS active_month_lag1,
         --cust_sales_territory_cd,
         --cust_sales_type_desc,
         --cust_sales_territory_desc,
         count_consignments AS count_consignments_lag1,
         goods_value AS goods_value_lag1,
         shipments AS shipments_lag1,
         revenue AS revenue_lag1,
         sum_volume AS sum_volume_lag1,
         sum_items AS sum_items_lag1,
         sum_weight AS sum_weight_lag1,
         seq_ytd_shipments as seq_ytd_shipments_lag1,
         seq_ytd_revenue as seq_ytd_revenue_lag1,
         seq_ytd_volume as seq_ytd_volume_lag1,
         seq_ytd_items as seq_ytd_items_lag1,
         seq_ytd_weight as seq_ytd_weight_lag1,
         /*
         digital_revenue AS digital_revenue_lag1,
         digital_shipments AS digital_shipments_lag1,
         digital_volume AS digital_volume_lag1,
         digital_weight AS digital_weight_lag1,
         digital_items AS digital_items_lag1,
         is_mytnt_revenue AS is_mytnt_revenue_lag1,
         is_mytnt_shipments AS is_mytnt_shipments_lag1,
         is_mytnt_volume AS is_mytnt_volume_lag1,
         is_mytnt_weight AS is_mytnt_weight_lag1,
         is_mytnt_items AS is_mytnt_items_lag1,
         no_dig_revenue AS no_dig_revenue_lag1,
         no_dig_shipments AS no_dig_shipments_lag1,
         no_dig_volume AS no_dig_volume_lag1,
         no_dig_weight AS no_dig_weight_lag1,
         no_dig_items AS no_dig_items_lag1,*/ month_seq_avg_goods_value AS month_seq_avg_goods_value_lag1,
         month_seq_avg_shipments AS month_seq_avg_shipments_lag1,
         month_seq_avg_revenue AS month_seq_avg_revenue_lag1,
         month_seq_avg_volume AS month_seq_avg_volume_lag1,
         month_seq_avg_items AS month_seq_avg_items_lag1,
         month_seq_avg_weight AS month_seq_avg_weight_lag1,
         /* month_seq_std_goods_value AS month_seq_std_goods_value_lag1,
         month_seq_std_shipments AS month_seq_std_shipments_lag1,
         month_seq_std_revenue AS month_seq_std_revenue_lag1,
         month_seq_std_volume AS month_seq_std_volume_lag1,
         month_seq_std_items AS month_seq_std_items_lag1,
         month_seq_std_weight AS month_seq_std_weight_lag1,*/ month_avg_revenue_1 AS month_avg_revenue_1_lag1,
         month_avg_revenue_3 AS month_avg_revenue_3_lag1,
         month_avg_revenue_12 AS month_avg_revenue_12_lag1,
         month_avg_shipments_1 AS month_avg_shipments_1_lag1,
         month_avg_shipments_3 AS month_avg_shipments_3_lag1,
         month_avg_shipments_12 AS month_avg_shipments_12_lag1,
         month_avg_sum_volume_1 AS month_avg_sum_volume_1_lag1,
         month_avg_sum_volume_3 AS month_avg_sum_volume_3_lag1,
         month_avg_sum_volume_12 AS month_avg_sum_volume_12_lag1,
         month_avg_sum_items_1 AS month_avg_sum_items_1_lag1,
         month_avg_sum_items_3 AS month_avg_sum_items_3_lag1,
         month_avg_sum_items_12 AS month_avg_sum_items_12_lag1,
         month_avg_sum_weight_1 AS month_avg_sum_weight_1_lag1,
         month_avg_sum_weight_3 AS month_avg_sum_weight_3_lag1,
         month_avg_sum_weight_12 AS month_avg_sum_weight_12_lag1
  FROM stg2_Customer_downtraders_monthly_seq_full
  WHERE cus_id > 0
  --and  acc_country IN ('IE','GB', 'GR', 'PT')
  AND   all_max_date > 0
  AND   max_cons > 20
  AND   all_sum_shipments > 20
  AND   all_sum_revenue > 500
  --AND   all_days_active > 400
  ORDER BY cus_id_lag1,
           month_dt_lag1
  --WHERE 
           --acc_country IN ('NL','DE','CY')
           --AND   all_max_date > 0
           --AND   max_cons > 20
           --AND   all_sum_shipments > 20
           --AND   all_sum_revenue > 500
           --AND   all_days_active > 90
           ) AS m1
         ON m1.month_dt_lag1 = t1.month_lag_dt1
        AND t1.cus_id = m1.cus_id_lag1
  LEFT JOIN
-- Monthly join lag 3
 (SELECT month_dt AS month_dt_lag3,
         cus_id AS cus_id_lag3,
         active_month AS active_month_lag3,
         count_consignments AS count_consignments_lag3,
         goods_value AS goods_value_lag3,
         shipments AS shipments_lag3,
         revenue AS revenue_lag3,
         sum_volume AS sum_volume_lag3,
         sum_items AS sum_items_lag3,
         sum_weight AS sum_weight_lag3,
         seq_ytd_shipments as seq_ytd_shipments_lag3,
         seq_ytd_revenue as seq_ytd_revenue_lag3,
         seq_ytd_volume as seq_ytd_volume_lag3,
         seq_ytd_items as seq_ytd_items_lag3,
         seq_ytd_weight as seq_ytd_weight_lag3,
         /*
         digital_revenue AS digital_revenue_lag3,
         digital_shipments AS digital_shipments_lag3,
         digital_volume AS digital_volume_lag3,
         digital_weight AS digital_weight_lag3,
         digital_items AS digital_items_lag3,
         is_mytnt_revenue AS is_mytnt_revenue_lag3,
         is_mytnt_shipments AS is_mytnt_shipments_lag3,
         is_mytnt_volume AS is_mytnt_volume_lag3,
         is_mytnt_weight AS is_mytnt_weight_lag3,
         is_mytnt_items AS is_mytnt_items_lag3,
         no_dig_revenue AS no_dig_revenue_lag3,
         no_dig_shipments AS no_dig_shipments_lag3,
         no_dig_volume AS no_dig_volume_lag3,
         no_dig_weight AS no_dig_weight_lag3,
         no_dig_items AS no_dig_items_lag3,*/ month_seq_avg_goods_value AS month_seq_avg_goods_value_lag3,
         month_seq_avg_shipments AS month_seq_avg_shipments_lag3,
         month_seq_avg_revenue AS month_seq_avg_revenue_lag3,
         month_seq_avg_volume AS month_seq_avg_volume_lag3,
         month_seq_avg_items AS month_seq_avg_items_lag3,
         month_seq_avg_weight AS month_seq_avg_weight_lag3,
         /* month_seq_std_goods_value AS month_seq_std_goods_value_lag3,
         month_seq_std_shipments AS month_seq_std_shipments_lag3,
         month_seq_std_revenue AS month_seq_std_revenue_lag3,
         month_seq_std_volume AS month_seq_std_volume_lag3,
         month_seq_std_items AS month_seq_std_items_lag3,
         month_seq_std_weight AS month_seq_std_weight_lag3,*/ month_avg_revenue_1 AS month_avg_revenue_1_lag3,
         month_avg_revenue_3 AS month_avg_revenue_3_lag3,
         month_avg_revenue_12 AS month_avg_revenue_12_lag3,
         month_avg_shipments_1 AS month_avg_shipments_1_lag3,
         month_avg_shipments_3 AS month_avg_shipments_3_lag3,
         month_avg_shipments_12 AS month_avg_shipments_12_lag3,
         month_avg_sum_volume_1 AS month_avg_sum_volume_1_lag3,
         month_avg_sum_volume_3 AS month_avg_sum_volume_3_lag3,
         month_avg_sum_volume_12 AS month_avg_sum_volume_12_lag3,
         month_avg_sum_items_1 AS month_avg_sum_items_1_lag3,
         month_avg_sum_items_3 AS month_avg_sum_items_3_lag3,
         month_avg_sum_items_12 AS month_avg_sum_items_12_lag3,
         month_avg_sum_weight_1 AS month_avg_sum_weight_1_lag3,
         month_avg_sum_weight_3 AS month_avg_sum_weight_3_lag3,
         month_avg_sum_weight_12 AS month_avg_sum_weight_12_lag3
  FROM stg2_Customer_downtraders_monthly_seq_full
  WHERE cus_id > 0
  --acc_country IN ('IE','GB', 'GR', 'PT')
  --AND   all_max_date > 0
  --AND   max_cons > 20
  --AND   all_sum_shipments > 20
  --AND   all_sum_revenue > 500
  --AND   all_days_active > 400
  ORDER BY cus_id_lag3,
           month_dt_lag3
  --WHERE 
           --acc_country IN ('NL','DE','CY')
           --all_max_date > 0
           --AND   max_cons > 20
           --AND   all_sum_shipments > 20
           --AND   all_sum_revenue > 500
           --AND   all_days_active > 90
           ) AS m3
         ON m3.month_dt_lag3 = t1.month_lag_dt3
        AND t1.cus_id = m3.cus_id_lag3
  LEFT JOIN
-- Monthly join lag 12
 (SELECT month_dt AS month_dt_lag12,
         cus_id AS cus_id_lag12,
         active_month AS active_month_lag12,
         count_consignments AS count_consignments_lag12,
         goods_value AS goods_value_lag12,
         shipments AS shipments_lag12,
         revenue AS revenue_lag12,
         sum_volume AS sum_volume_lag12,
         sum_items AS sum_items_lag12,
         sum_weight AS sum_weight_lag12,
         seq_ytd_shipments as seq_ytd_shipments_lag12,
         seq_ytd_revenue as seq_ytd_revenue_lag12,
         seq_ytd_volume as seq_ytd_volume_lag12,
         seq_ytd_items as seq_ytd_items_lag12,
         seq_ytd_weight as seq_ytd_weight_lag12,
         /*
         digital_revenue AS digital_revenue_lag12,
         digital_shipments AS digital_shipments_lag12,
         digital_volume AS digital_volume_lag12,
         digital_weight AS digital_weight_lag12,
         digital_items AS digital_items_lag12,
         is_mytnt_revenue AS is_mytnt_revenue_lag12,
         is_mytnt_shipments AS is_mytnt_shipments_lag12,
         is_mytnt_volume AS is_mytnt_volume_lag12,
         is_mytnt_weight AS is_mytnt_weight_lag12,
         is_mytnt_items AS is_mytnt_items_lag12,
         no_dig_revenue AS no_dig_revenue_lag12,
         no_dig_shipments AS no_dig_shipments_lag12,
         no_dig_volume AS no_dig_volume_lag12,
         no_dig_weight AS no_dig_weight_lag12,
         no_dig_items AS no_dig_items_lag12,*/ month_seq_avg_goods_value AS month_seq_avg_goods_value_lag12,
         month_seq_avg_shipments AS month_seq_avg_shipments_lag12,
         month_seq_avg_revenue AS month_seq_avg_revenue_lag12,
         month_seq_avg_volume AS month_seq_avg_volume_lag12,
         month_seq_avg_items AS month_seq_avg_items_lag12,
         month_seq_avg_weight AS month_seq_avg_weight_lag12,
         /* month_seq_std_goods_value AS month_seq_std_goods_value_lag12,
         month_seq_std_shipments AS month_seq_std_shipments_lag12,
         month_seq_std_revenue AS month_seq_std_revenue_lag12,
         month_seq_std_volume AS month_seq_std_volume_lag12,
         month_seq_std_items AS month_seq_std_items_lag12,
         month_seq_std_weight AS month_seq_std_weight_lag12,*/ month_avg_revenue_1 AS month_avg_revenue_1_lag12,
         month_avg_revenue_3 AS month_avg_revenue_3_lag12,
         month_avg_revenue_12 AS month_avg_revenue_12_lag12,
         month_avg_shipments_1 AS month_avg_shipments_1_lag12,
         month_avg_shipments_3 AS month_avg_shipments_3_lag12,
         month_avg_shipments_12 AS month_avg_shipments_12_lag12,
         month_avg_sum_volume_1 AS month_avg_sum_volume_1_lag12,
         month_avg_sum_volume_3 AS month_avg_sum_volume_3_lag12,
         month_avg_sum_volume_12 AS month_avg_sum_volume_12_lag12,
         month_avg_sum_items_1 AS month_avg_sum_items_1_lag12,
         month_avg_sum_items_3 AS month_avg_sum_items_3_lag12,
         month_avg_sum_items_12 AS month_avg_sum_items_12_lag12,
         month_avg_sum_weight_1 AS month_avg_sum_weight_1_lag12,
         month_avg_sum_weight_3 AS month_avg_sum_weight_3_lag12,
         month_avg_sum_weight_12 AS month_avg_sum_weight_12_lag12
  FROM stg2_Customer_downtraders_monthly_seq_full
  WHERE cus_id > 0
  --acc_country IN ('IE','GB', 'GR', 'PT')
  --AND   all_max_date > 0
  --AND   max_cons > 20
  --AND   all_sum_shipments > 20
  --AND   all_sum_revenue > 500
  --AND   all_days_active > 400
  ORDER BY cus_id_lag12,
           month_dt_lag12
  --WHERE
           -- acc_country IN ('NL','DE','CY')
           --all_max_date > 0
           --AND   max_cons > 20
           --AND   all_sum_shipments > 20
           --AND   all_sum_revenue > 500
           --AND   all_days_active > 90
           ) AS m12
         ON t1.month_lag_dt12 = m12.month_dt_lag12
        AND t1.cus_id = m12.cus_id_lag12
ORDER BY cus_id,
         month_dt;

DROP TABLE if exists stg3_downtraders_sample2;

--select conf_10_interval_95 from xx_downtrade_sample2 limit 100;
CREATE TABLE stg3_downtraders_sample2 
AS
SELECT *,
       CASE
         WHEN month_avg_revenue_1_lag1 > 0 AND month_avg_revenue_1 > 0 THEN month_avg_revenue_1 / month_avg_revenue_1_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_1_lag1,
       CASE
         WHEN month_avg_revenue_1_lag3 > 0 AND month_avg_revenue_1 > 0 THEN month_avg_revenue_1 / month_avg_revenue_1_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_1_lag3,
       CASE
         WHEN month_avg_revenue_1_lag12 > 0 AND month_avg_revenue_1 > 0 THEN month_avg_revenue_1 / month_avg_revenue_1_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_1_lag12,
       CASE
         WHEN month_avg_revenue_3_lag1 > 0 AND month_avg_revenue_3 > 0 THEN month_avg_revenue_3 / month_avg_revenue_3_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_3_lag1,
       CASE
         WHEN month_avg_revenue_3_lag3 > 0 AND month_avg_revenue_3 > 0 THEN month_avg_revenue_3 / month_avg_revenue_3_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_3_lag3,
       CASE
         WHEN month_avg_revenue_3_lag12 > 0 AND month_avg_revenue_3 > 0 THEN month_avg_revenue_3 / month_avg_revenue_3_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_3_lag12,
       CASE
         WHEN month_avg_revenue_12_lag1 > 0 AND month_avg_revenue_12 > 0 THEN month_avg_revenue_12 / month_avg_revenue_12_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_12_lag1,
       CASE
         WHEN month_avg_revenue_12_lag3 > 0 AND month_avg_revenue_12 > 0 THEN month_avg_revenue_12 / month_avg_revenue_12_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_12_lag3,
       CASE
         WHEN month_avg_revenue_12_lag12 > 0 AND month_avg_revenue_12 > 0 THEN month_avg_revenue_12 / month_avg_revenue_12_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_revenue_12_lag12,
       CASE
         WHEN month_avg_shipments_1_lag1 > 0 AND month_avg_shipments_1 > 0 THEN month_avg_shipments_1 / month_avg_shipments_1_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_1_lag1,
       CASE
         WHEN month_avg_shipments_1_lag3 > 0 AND month_avg_shipments_1 > 0 THEN month_avg_shipments_1 / month_avg_shipments_1_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_1_lag3,
       CASE
         WHEN month_avg_shipments_1_lag12 > 0 AND month_avg_shipments_1 > 0 THEN month_avg_shipments_1 / month_avg_shipments_1_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_1_lag12,
       CASE
         WHEN month_avg_shipments_3_lag1 > 0 AND month_avg_shipments_3 > 0 THEN month_avg_shipments_3 / month_avg_shipments_3_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_3_lag1,
       CASE
         WHEN month_avg_shipments_3_lag3 > 0 AND month_avg_shipments_3 > 0 THEN month_avg_shipments_3 / month_avg_shipments_3_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_3_lag3,
       CASE
         WHEN month_avg_shipments_3_lag12 > 0 AND month_avg_shipments_3 > 0 THEN month_avg_shipments_3 / month_avg_shipments_3_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_3_lag12,
       CASE
         WHEN month_avg_shipments_12_lag1 > 0 AND month_avg_shipments_12 > 0 THEN month_avg_shipments_12 / month_avg_shipments_12_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_12_lag1,
       CASE
         WHEN month_avg_shipments_12_lag3 > 0 AND month_avg_shipments_12 > 0 THEN month_avg_shipments_12 / month_avg_shipments_12_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_12_lag3,
       CASE
         WHEN month_avg_shipments_12_lag12 > 0 AND month_avg_shipments_12 > 0 THEN month_avg_shipments_12 / month_avg_shipments_12_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_shipments_12_lag12,
       CASE
         WHEN month_avg_sum_weight_1_lag1 > 0 AND month_avg_sum_weight_1 > 0 THEN month_avg_sum_weight_1 / month_avg_sum_weight_1_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_1_lag1,
       CASE
         WHEN month_avg_sum_weight_1_lag3 > 0 AND month_avg_sum_weight_1 > 0 THEN month_avg_sum_weight_1 / month_avg_sum_weight_1_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_1_lag3,
       CASE
         WHEN month_avg_sum_weight_1_lag12 > 0 AND month_avg_sum_weight_1 > 0 THEN month_avg_sum_weight_1 / month_avg_sum_weight_1_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_1_lag12,
       CASE
         WHEN month_avg_sum_weight_3_lag1 > 0 AND month_avg_sum_weight_3 > 0 THEN month_avg_sum_weight_3 / month_avg_sum_weight_3_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_3_lag1,
       CASE
         WHEN month_avg_sum_weight_3_lag3 > 0 AND month_avg_sum_weight_3 > 0 THEN month_avg_sum_weight_3 / month_avg_sum_weight_3_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_3_lag3,
       CASE
         WHEN month_avg_sum_weight_3_lag12 > 0 AND month_avg_sum_weight_3 > 0 THEN month_avg_sum_weight_3 / month_avg_sum_weight_3_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_3_lag12,
       CASE
         WHEN month_avg_sum_weight_12_lag1 > 0 AND month_avg_sum_weight_12 > 0 THEN month_avg_sum_weight_12 / month_avg_sum_weight_12_lag1::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_12_lag1,
       CASE
         WHEN month_avg_sum_weight_12_lag3 > 0 AND month_avg_sum_weight_12 > 0 THEN month_avg_sum_weight_12 / month_avg_sum_weight_12_lag3::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_12_lag3,
       CASE
         WHEN month_avg_sum_weight_12_lag12 > 0 AND month_avg_sum_weight_12 > 0 THEN month_avg_sum_weight_12 / month_avg_sum_weight_12_lag12::DECIMAL(15,3) - 1
         ELSE 0
       END AS perc_chg_month_avg_sum_weight_12_lag12 /*CASE
         WHEN m_perc_is_sender_pays_lag1 > 0.01 AND m_perc_is_sender_pays > 0.01 THEN m_perc_is_sender_pays / m_perc_is_sender_pays_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_sender_pays_lag1,
       CASE
         WHEN m_perc_is_sender_pays_lag3 > 0.01 AND m_perc_is_sender_pays > 0.01 THEN m_perc_is_sender_pays / m_perc_is_sender_pays_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_sender_pays_lag3,
       CASE
         WHEN m_perc_is_sender_pays_lag12 > 0.01 AND m_perc_is_sender_pays > 0.01 THEN m_perc_is_sender_pays / m_perc_is_sender_pays_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_sender_pays_lag12,
       CASE
         WHEN m_perc_is_receiver_pays_lag1 > 0.01 AND m_perc_is_receiver_pays > 0.01 THEN m_perc_is_receiver_pays / m_perc_is_receiver_pays_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_receiver_pays_lag1,
       CASE
         WHEN m_perc_is_receiver_pays_lag3 > 0.01 AND m_perc_is_receiver_pays > 0.01 THEN m_perc_is_receiver_pays / m_perc_is_receiver_pays_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_receiver_pays_lag3,
       CASE
         WHEN m_perc_is_receiver_pays_lag12 > 0.01 AND m_perc_is_receiver_pays > 0.01 THEN m_perc_is_receiver_pays / m_perc_is_receiver_pays_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_receiver_pays_lag12,
       CASE
         WHEN m_perc_is_international_shipment_lag1 > 0.01 AND m_perc_is_international_shipment > 0.01 THEN m_perc_is_international_shipment / m_perc_is_international_shipment_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_international_shipment_lag1,
       CASE
         WHEN m_perc_is_international_shipment_lag3 > 0.01 AND m_perc_is_international_shipment > 0.01 THEN m_perc_is_international_shipment / m_perc_is_international_shipment_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_international_shipment_lag3,
       CASE
         WHEN m_perc_is_international_shipment_lag12 > 0.01 AND m_perc_is_international_shipment > 0.01 THEN m_perc_is_international_shipment / m_perc_is_international_shipment_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_international_shipment_lag12,
       CASE
         WHEN m_perc_is_dangerous_shipment_lag1 > 0.01 AND m_perc_is_dangerous_shipment > 0.01 THEN m_perc_is_dangerous_shipment / m_perc_is_dangerous_shipment_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_dangerous_shipment_lag1,
       CASE
         WHEN m_perc_is_dangerous_shipment_lag3 > 0.01 AND m_perc_is_dangerous_shipment > 0.01 THEN m_perc_is_dangerous_shipment / m_perc_is_dangerous_shipment_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_dangerous_shipment_lag3,
       CASE
         WHEN m_perc_is_dangerous_shipment_lag12 > 0.01 AND m_perc_is_dangerous_shipment > 0.01 THEN m_perc_is_dangerous_shipment / m_perc_is_dangerous_shipment_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_dangerous_shipment_lag12,
       CASE
         WHEN m_perc_is_express_prdct_lag1 > 0.01 AND m_perc_is_express_prdct > 0.01 THEN m_perc_is_express_prdct / m_perc_is_express_prdct_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_express_prdct_lag1,
       CASE
         WHEN m_perc_is_express_prdct_lag3 > 0.01 AND m_perc_is_express_prdct > 0.01 THEN m_perc_is_express_prdct / m_perc_is_express_prdct_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_express_prdct_lag3,
       CASE
         WHEN m_perc_is_express_prdct_lag12 > 0.01 AND m_perc_is_express_prdct > 0.01 THEN m_perc_is_express_prdct / m_perc_is_express_prdct_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_express_prdct_lag12,
       CASE
         WHEN m_perc_is_economy_prdct_lag1 > 0.01 AND m_perc_is_economy_prdct > 0.01 THEN m_perc_is_economy_prdct / m_perc_is_economy_prdct_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_economy_prdct_lag1,
       CASE
         WHEN m_perc_is_economy_prdct_lag3 > 0.01 AND m_perc_is_economy_prdct > 0.01 THEN m_perc_is_economy_prdct / m_perc_is_economy_prdct_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_economy_prdct_lag3,
       CASE
         WHEN m_perc_is_economy_prdct_lag12 > 0.01 AND m_perc_is_economy_prdct > 0.01 THEN m_perc_is_economy_prdct / m_perc_is_economy_prdct_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_economy_prdct_lag12,
       CASE
         WHEN m_perc_is_special_prdct_lag1 > 0.01 AND m_perc_is_special_prdct > 0.01 THEN m_perc_is_special_prdct / m_perc_is_special_prdct_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_special_prdct_lag1,
       CASE
         WHEN m_perc_is_special_prdct_lag3 > 0.01 AND m_perc_is_special_prdct > 0.01 THEN m_perc_is_special_prdct / m_perc_is_special_prdct_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_special_prdct_lag3,
       CASE
         WHEN m_perc_is_special_prdct_lag12 > 0.01 AND m_perc_is_special_prdct > 0.01 THEN m_perc_is_special_prdct / m_perc_is_special_prdct_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_special_prdct_lag12,
       CASE
         WHEN m_perc_is_express_tool_lag1 > 0.01 AND m_perc_is_express_tool > 0.01 THEN m_perc_is_express_tool / m_perc_is_express_tool_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_express_tool_lag1,
       CASE
         WHEN m_perc_is_express_tool_lag3 > 0.01 AND m_perc_is_express_tool > 0.01 THEN m_perc_is_express_tool / m_perc_is_express_tool_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_express_tool_lag3,
       CASE
         WHEN m_perc_is_express_tool_lag12 > 0.01 AND m_perc_is_express_tool > 0.01 THEN m_perc_is_express_tool / m_perc_is_express_tool_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_express_tool_lag12,
       CASE
         WHEN m_perc_is_mytnt_tool_lag1 > 0.01 AND m_perc_is_mytnt_tool > 0.01 THEN m_perc_is_mytnt_tool / m_perc_is_mytnt_tool_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_mytnt_tool_lag1,
       CASE
         WHEN m_perc_is_mytnt_tool_lag3 > 0.01 AND m_perc_is_mytnt_tool > 0.01 THEN m_perc_is_mytnt_tool / m_perc_is_mytnt_tool_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_mytnt_tool_lag3,
       CASE
         WHEN m_perc_is_mytnt_tool_lag12 > 0.01 AND m_perc_is_mytnt_tool > 0.01 THEN m_perc_is_mytnt_tool / m_perc_is_mytnt_tool_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_mytnt_tool_lag12,
       CASE
         WHEN m_perc_is_local_tool_lag1 > 0.01 AND m_perc_is_local_tool > 0.01 THEN m_perc_is_local_tool / m_perc_is_local_tool_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_local_tool_lag1,
       CASE
         WHEN m_perc_is_local_tool_lag3 > 0.01 AND m_perc_is_local_tool > 0.01 THEN m_perc_is_local_tool / m_perc_is_local_tool_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_local_tool_lag3,
       CASE
         WHEN m_perc_is_local_tool_lag12 > 0.01 AND m_perc_is_local_tool > 0.01 THEN m_perc_is_local_tool / m_perc_is_local_tool_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_local_tool_lag12,
       CASE
         WHEN m_perc_is_open_tool_lag1 > 0.01 AND m_perc_is_open_tool > 0.01 THEN m_perc_is_open_tool / m_perc_is_open_tool_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_open_tool_lag1,
       CASE
         WHEN m_perc_is_open_tool_lag3 > 0.01 AND m_perc_is_open_tool > 0.01 THEN m_perc_is_open_tool / m_perc_is_open_tool_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_open_tool_lag3,
       CASE
         WHEN m_perc_is_open_tool_lag12 > 0.01 AND m_perc_is_open_tool > 0.01 THEN m_perc_is_open_tool / m_perc_is_open_tool_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_open_tool_lag12,
       CASE
         WHEN m_perc_is_custom_tool_lag1 > 0.01 AND m_perc_is_custom_tool > 0.01 THEN m_perc_is_custom_tool / m_perc_is_custom_tool_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_custom_tool_lag1,
       CASE
         WHEN m_perc_is_custom_tool_lag3 > 0.01 AND m_perc_is_custom_tool > 0.01 THEN m_perc_is_custom_tool / m_perc_is_custom_tool_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_custom_tool_lag3,
       CASE
         WHEN m_perc_is_custom_tool_lag12 > 0.01 AND m_perc_is_custom_tool > 0.01 THEN m_perc_is_custom_tool / m_perc_is_custom_tool_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_custom_tool_lag12,
       CASE
         WHEN m_perc_is_digital_tool_lag1 > 0.01 AND m_perc_is_digital_tool > 0.01 THEN m_perc_is_digital_tool / m_perc_is_digital_tool_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_digital_tool_lag1,
       CASE
         WHEN m_perc_is_digital_tool_lag3 > 0.01 AND m_perc_is_digital_tool > 0.01 THEN m_perc_is_digital_tool / m_perc_is_digital_tool_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_digital_tool_lag3,
       CASE
         WHEN m_perc_is_digital_tool_lag12 > 0.01 AND m_perc_is_digital_tool > 0.01 THEN m_perc_is_digital_tool / m_perc_is_digital_tool_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_digital_tool_lag12,
       CASE
         WHEN m_perc_is_manual_tool_lag1 > 0.01 AND m_perc_is_manual_tool > 0.01 THEN m_perc_is_manual_tool / m_perc_is_manual_tool_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_manual_tool_lag1,
       CASE
         WHEN m_perc_is_manual_tool_lag3 > 0.01 AND m_perc_is_manual_tool > 0.01 THEN m_perc_is_manual_tool / m_perc_is_manual_tool_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_manual_tool_lag3,
       CASE
         WHEN m_perc_is_manual_tool_lag12 > 0.01 AND m_perc_is_manual_tool > 0.01 THEN m_perc_is_manual_tool / m_perc_is_manual_tool_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_m_perc_is_manual_tool_lag12,
       CASE
         WHEN conf_10_interval_95_lag1 > 0 AND conf_10_interval_95 > 0 THEN conf_10_interval_95 / conf_10_interval_95_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_conf_10_interval_95_lag1,
       CASE
         WHEN conf_10_interval_95_lag3 > 0 AND conf_10_interval_95 > 0 THEN conf_10_interval_95 / conf_10_interval_95_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_conf_10_interval_95_lag3,
       CASE
         WHEN conf_10_interval_95_lag12 > 0 AND conf_10_interval_95 > 0 THEN conf_10_interval_95 / conf_10_interval_95_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_conf_10_interval_95_lag12,
       CASE
         WHEN churn_days_between_lag1 > 0 AND churn_days_between > 0 THEN churn_days_between / churn_days_between_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_churn_days_between_lag1,
       CASE
         WHEN churn_days_between_lag3 > 0 AND churn_days_between > 0 THEN churn_days_between / churn_days_between_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_churn_days_between_lag3,
       CASE
         WHEN churn_days_between_lag12 > 0 AND churn_days_between > 0 THEN churn_days_between / churn_days_between_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_churn_days_between_lag12,
       CASE
         WHEN conf_interval_95_lag1 > 0 AND conf_interval_95 > 0 THEN conf_interval_95 / conf_interval_95_lag1::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_conf_interval_95_lag1,
       CASE
         WHEN conf_interval_95_lag3 > 0 AND conf_interval_95 > 0 THEN conf_interval_95 / conf_interval_95_lag3::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_conf_interval_95_lag3,
       CASE
         WHEN conf_interval_95_lag12 > 0 AND conf_interval_95 > 0 THEN conf_interval_95 / conf_interval_95_lag12::DECIMAL(10,3) - 1
         ELSE 0
       END AS perc_chg_conf_interval_95_lag12*/
FROM stg3_downtraders_sample;

DROP table if exists stg3_downtraders_churners_NL_DE_GR_CY_IE;

-- Connect with AWS
CREATE TABLE stg3_downtraders_churners_NL_DE_GR_CY_IE 
AS
SELECT *,
       CASE
         WHEN month_seq_con > 6 and month_seq_revenue > 500 and flag_downtrade_q_o_q = 1 AND flag_downtrade_q_o_q_lastyear = 1 AND flag_churner = 1 THEN 'hard downtrader & red churner'
         WHEN month_seq_con > 6 and month_seq_revenue > 500 and flag_downtrade_q_o_q = 0 AND flag_downtrade_q_o_q_lastyear = 0 AND flag_churner = 1 THEN 'red churner'
--yellow

         WHEN month_seq_con > 6 and month_seq_revenue > 500 and flag_downtrade_q_o_q = 1 AND flag_downtrade_q_o_q_lastyear = 1 AND flag_churner = 0 AND flag_yellow_churner = 1 THEN 'hard downtrader & yellow churner'
         WHEN month_seq_con > 6 and month_seq_revenue > 500 and flag_downtrade_q_o_q = 0 AND flag_downtrade_q_o_q_lastyear = 0 AND flag_churner = 0 AND flag_yellow_churner = 1 THEN 'yellow churner'
         WHEN month_seq_con > 6 and month_seq_revenue > 500 and (flag_downtrade_q_o_q = 1 AND flag_downtrade_q_o_q_lastyear = 1) AND flag_churner = 0 AND flag_yellow_churner = 0 THEN 'hard downtrader'
         WHEN month_seq_con > 6 and month_seq_revenue > 500 and (flag_downtrade_q_o_q = 1 OR flag_downtrade_q_o_q_lastyear = 1) AND flag_churner = 0 AND flag_yellow_churner = 0 THEN 'soft downtrader'
         WHEN month_seq_con > 6 and month_seq_revenue > 500 and ((flag_downtrade_q_o_q = 1 AND flag_downtrade_q_o_q_lastyear = 0) AND flag_churner = 1) OR ((flag_downtrade_q_o_q = 0 AND flag_downtrade_q_o_q_lastyear = 1) AND flag_churner = 1) THEN 'soft downtrader & red churner'
         WHEN month_seq_con > 6 and month_seq_revenue > 500 and ((flag_downtrade_q_o_q = 1 AND flag_downtrade_q_o_q_lastyear = 0) AND flag_churner = 0 AND flag_yellow_churner = 1) OR ((flag_downtrade_q_o_q = 0 AND flag_downtrade_q_o_q_lastyear = 1) AND flag_churner = 0 AND flag_yellow_churner = 1) THEN 'soft downtrader & yellow churner'
         when month_seq_con <= 6 then 'onboarding'
         when month_seq_con > 6 and month_seq_revenue <= 500 then 'low budget'
        ELSE 'active'
       END AS retention_segment
FROM (SELECT *, CASE
               WHEN perc_chg_month_avg_revenue_3_lag3 > 0 THEN NULL
               ELSE perc_chg_month_avg_revenue_3_lag3
             END AS downtrade_q_o_q,
             CASE
               WHEN perc_chg_month_avg_revenue_3_lag12 > 0 THEN NULL
               ELSE perc_chg_month_avg_revenue_3_lag12
             END AS downtrade_q_o_q_lastyear,
             CASE
               WHEN nrmd_churn_dt < CURRENT_DATE- 30 and churn_nrw_dis = 1 THEN 1
               ELSE 0
             END AS flag_churner,
             CASE
               WHEN yellow_nrmd_churn_dt < CURRENT_DATE- 30 THEN 1
               ELSE 0
             END AS flag_yellow_churner,
             CASE
               WHEN perc_chg_month_avg_revenue_3_lag3 < -0.25 THEN 1
               ELSE 0
             END AS flag_downtrade_q_o_q,
             CASE
               WHEN perc_chg_month_avg_revenue_3_lag12 < -0.25 THEN 1
               ELSE 0
             END AS flag_downtrade_q_o_q_lastyear
      FROM stg3_downtraders_sample2);

drop table if exists stg3_list_downtraders_churners_nl_de_gr_cy_ie;
CREATE TABLE stg3_list_downtraders_churners_NL_DE_GR_CY_IE 
AS
SELECT *
FROM stg3_downtraders_churners_NL_DE_GR_CY_IE
WHERE  DATE_TRUNC('month',all_max_date) = DATE_TRUNC('month',max_con_create_dt)
and all_max_date < '2017-05-01'
and retention_segment != 'active'
AND   all_max_date > CURRENT_DATE -365
-- only the customer that are active after 2016
AND   all_days_active > 200
AND   all_sum_revenue >= 1000
AND   all_sum_revenue < 1000000
ORDER BY acc_country,
         all_avg_revenue DESC,
         cus_id;
GRANT SELECT
  ON table stg3_downtraders_churners_NL_DE_GR_CY_IE
  TO public;         

GRANT SELECT
  ON table stg3_list_downtraders_churners_NL_DE_GR_CY_IE
  TO public;
--SELECT COUNT(*), acc_country FROM stg3_list_downtraders_churners_NL_DE_GR_CY_IE group by acc_country;
-- Print the list
DROP TABLE if exists stg3_customer_list;
create table stg3_customer_list as 
select cus_id,
             acc_country,
             cust_sales_territory_cd,
             st_cust_sales_type_desc2,
             all_sum_shipments,
             all_sum_revenue,
             CAST(all_avg_shipments AS INT) AS all_avg_shipments,
             CAST(all_avg_revenue AS INT) AS all_avg_revenue,
             CAST(all_avg_items AS INT) AS all_avg_items,
             CAST(all_avg_weight AS INT) AS all_avg_weight,
             seq_ytd_shipments,
             seq_ytd_revenue,
             seq_ytd_volume,
             seq_ytd_items,
             seq_ytd_weight,
             seq_ytd_shipments_lag12,
             seq_ytd_revenue_lag12,
             seq_ytd_volume_lag12,
             seq_ytd_items_lag12,
             seq_ytd_weight_lag12,
             all_shipments_2014,
             all_shipments_2015,
             all_shipments_2016,
             all_shipments_2017,
             all_revenue_2014,
             all_revenue_2015,
             all_revenue_2016,
             all_revenue_2017,
             all_sum_volume_2014,
             all_sum_volume_2015,
             all_sum_volume_2016,
             all_sum_volume_2017,
             all_sum_weight_2014,
             all_sum_weight_2015,
             all_sum_weight_2016,
             all_sum_weight_2017,
             all_sum_items_2014,
             all_sum_items_2015,
             all_sum_items_2016,
             all_sum_items_2017,
             seq_avg3_days_between,
             seq_avg10_days_between,
             perc_all_is_sender_pays,
             perc_all_is_receiver_pays,
             perc_all_is_international_shipment,
             perc_all_is_dangerous_shipment,
             perc_all_is_express_prdct,
             perc_all_is_economy_prdct,
             perc_all_is_special_prdct,
             perc_all_is_express_tool,
             perc_all_is_mytnt_tool,
             perc_all_is_local_tool,
             perc_all_is_open_tool,
             perc_all_is_custom_tool,
             perc_all_is_digital_tool,
             perc_all_is_manual_tool,
             nrmd_churn_dt,
             yellow_nrmd_churn_dt,
             conf_10_interval_95,
             yellow_conf_10_interval_95,
             conf_interval_95,
             yellow_conf_interval_95,
              all_min_date,
             all_max_date,
             downtrade_q_o_q,
             downtrade_q_o_q_lastyear,
             flag_churner,
            flag_yellow_churner,
             flag_downtrade_q_o_q,
             flag_downtrade_q_o_q_lastyear,
              retention_segment
             from stg3_list_downtraders_churners_NL_DE_GR_CY_IE;
             
GRANT SELECT
  ON table stg3_customer_list
  TO public;
             

drop table if exists stg3_churn_downtrade_DE;
create table stg3_churn_downtrade_DE as 
select * from stg3_list_downtraders_churners_NL_DE_GR_CY_IE 
where st_cust_sales_type_desc2 = 'Territory Sales' and acc_country = 'DE' 
order by random()
limit 1300*0.8;

GRANT SELECT
  ON table stg3_churn_downtrade_DE
  TO public;

drop table if exists stg3_churn_downtrade_NL;
create table stg3_churn_downtrade_NL as 
select * from stg3_list_downtraders_churners_NL_DE_GR_CY_IE 
where st_cust_sales_type_desc2 = 'Territory Sales' and acc_country = 'NL' 
order by random()
limit 2855*0.8;

GRANT SELECT
  ON table stg3_churn_downtrade_NL
  TO public;
  
drop table if exists stg3_churn_downtrade_IE;
create table stg3_churn_downtrade_IE as 
select * from stg3_list_downtraders_churners_NL_DE_GR_CY_IE 
where st_cust_sales_type_desc2 = 'Territory Sales' and acc_country = 'IE' 
order by random()
limit 718*0.8;

GRANT SELECT
  ON table stg3_churn_downtrade_IE
  TO public;
  
drop table if exists stg3_churn_downtrade_CY;
create table stg3_churn_downtrade_CY as 
select * from stg3_list_downtraders_churners_NL_DE_GR_CY_IE 
where st_cust_sales_type_desc2 = 'Territory Sales' and acc_country = 'CY' 
order by random()
limit 440*0.8;

GRANT SELECT
  ON table stg3_churn_downtrade_CY
  TO public;
  
drop table if exists stg3_churn_downtrade_GR;
create table stg3_churn_downtrade_GR as 
select * from stg3_list_downtraders_churners_NL_DE_GR_CY_IE 
where st_cust_sales_type_desc2 = 'Territory Sales' and acc_country = 'GR' 
order by random()
limit 2059*0.8;

GRANT SELECT
  ON table stg3_churn_downtrade_GR
  TO public;
  
drop table if exists stg3_churn_downtrade_BE;
create table stg3_churn_downtrade_BE as 
select * from stg3_list_downtraders_churners_NL_DE_GR_CY_IE 
where st_cust_sales_type_desc2 = 'Territory Sales' and acc_country = 'BE' 
order by random()
limit 2479*0.8;

GRANT SELECT
  ON table stg3_churn_downtrade_BE
  TO public;
  

select count(*), retention_segment, acc_country
from stg3_list_downtraders_churners_NL_DE_GR_CY_IE where st_cust_sales_type_desc2 = 'Territory Sales' group by retention_segment, acc_country order by acc_country,retention_segment ;
--select * from stg3_churn_downtrade_DE;
--select * from stg3_downtraders_churners_NL ORDER BY cus_id,         month_dt LIMIT 1000;
/*
CREATE TABLE stg3_customers_downtraders_churners_NL 
AS
SELECT *
FROM stg3_customers_downtraders_churners_NL_DE_GR_CY_IE
WHERE acc_country = 'NL'
ORDER BY cus_id,
         month_dt LIMIT 10000;

SELECT COUNT(*)
FROM stg3_customers_downtraders_churners_NL_DE_GR_CY_IE;

/*
drop if exists xx_downtraders_sample3;
CREATE TABLE xx_downtraders_sample3 
AS
SELECT *
FROM xx_downtrade_sample2
WHERE all_max_date = max_con_create_dt and 
perc_chg_month_avg_revenue_1_lag1 < -0.2 or perc_chg_month_avg_revenue_1_lag3 < -0.2 or perc_chg_month_avg_revenue_1_lag12< -0.2 or
perc_chg_month_avg_revenue_3_lag3 < -0.2 or perc_chg_month_avg_revenue_3_lag12< -0.2 or
perc_chg_month_avg_revenue_12_lag1 < -0.2 or perc_chg_month_avg_revenue_12_lag3 < -0.2 ;


select *
 from xx_downtrade_sample2  order by cus_id, month_dt limit 200;*/ 
--select * from stg2_downtraders_monthly_seq_full limit 100;

