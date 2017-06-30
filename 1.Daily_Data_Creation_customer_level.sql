--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
-- This codes is creating the churn dataset. the churn dataset is used to calcylate metrics, create reports and visuals as well is the initial concentrated dataset that will be
-- used for the creation of the data to train and test our churn models
-- there are 4 main parts in the code:
-- 0. Elligible customers
-- 1. Aggregate teh data in a account level on a daily basis. All teh consignments of an account that are done in teh same day will be constituting one line of this dataset
--    aggregated to resembele the more qualitative characteristics of the consignments
-- 2. Create a Customer level dataset. On this dataset we will create agreegations on a customer level. 
-- 3.  
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- TRIM THE SELECTION TO A RELEVANT PORTION THAT TRADED < 13 WEEKS AGO

-- Create a table that is aggregated on a daily basis 
--select * from stg2_fincon_daily_metrics_customer limit 100;
DROP TABLE IF EXISTS stg2_fincon_daily_metrics_customer;
CREATE TABLE stg2_fincon_daily_metrics_customer AS

SELECT *
	,CASE WHEN seq_days_between > 0
			AND seq_days_between <= 7 THEN 1 ELSE 0 END AS weekly
	,CASE WHEN seq_days_between > 7
			AND seq_days_between <= 14 THEN 1 ELSE 0 END AS biweekly
	,CASE WHEN seq_days_between > 14
			AND seq_days_between <= 30 THEN 1 ELSE 0 END AS monthly
	,CASE WHEN seq_days_between > 30
			AND seq_days_between <= 90 THEN 1 ELSE 0 END AS quarterly
	,CASE WHEN seq_days_between > 90
			AND seq_days_between <= 180 THEN 1 ELSE 0 END AS half_yearly
	,CASE WHEN seq_days_between > 180
			AND seq_days_between THEN 1 ELSE 0 END AS yearly
	,CASE WHEN seq_days_between = 0 THEN 1 ELSE 0 END AS nonactive
	,CASE WHEN seq_days_between > 0
			AND seq_days_between <= 7 THEN 'weekly' WHEN seq_days_between > 7
			AND seq_days_between <= 14 THEN 'biweekly' WHEN seq_days_between > 14
			AND seq_days_between <= 30 THEN 'monthly' WHEN seq_days_between > 30
			AND seq_days_between <= 7 THEN 'quarterly' WHEN seq_days_between > 90
			AND seq_days_between <= 7 THEN 'half_yearly' WHEN seq_days_between > 180 THEN 'yearly' ELSE 'other' END AS frequency
FROM (
	SELECT *
		,CASE WHEN seq_con > 1 THEN ABS(datediff(DAY, con_create_dt, lag_dt)) + 1 END AS seq_days_between
		,CASE WHEN seq_con > 1 THEN AVG(ABS(datediff(DAY, con_create_dt, lag_dt)) + 1) OVER (
						PARTITION BY cus_id ORDER BY con_create_dt ROWS BETWEEN 2 PRECEDING
								AND CURRENT ROW
						) END AS seq_avg3_days_between
		,CASE WHEN seq_con > 1 THEN AVG(ABS(datediff(DAY, con_create_dt, lag_dt)) + 1) OVER (
						PARTITION BY cus_id ORDER BY con_create_dt ROWS BETWEEN 9 PRECEDING
								AND CURRENT ROW
						) END AS seq_avg10_days_between
		,CASE WHEN seq_con > 1 THEN AVG(ABS(datediff(DAY, con_create_dt, lag_dt)) + 1) OVER (
						PARTITION BY cus_id ORDER BY con_create_dt ROWS BETWEEN 29 PRECEDING
								AND CURRENT ROW
						) END AS seq_avg30_days_between
		,CASE WHEN seq_con > 1 THEN AVG(ABS(datediff(DAY, con_create_dt, lag_dt)) + 1) OVER (
						PARTITION BY cus_id ORDER BY con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
								AND CURRENT ROW
						) END AS seq_avg_days_between
		,CASE WHEN seq_con > 1 THEN stddev_pop(ABS(datediff(DAY, con_create_dt, lag_dt)) + 1) OVER (
						PARTITION BY cus_id ORDER BY con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
								AND CURRENT ROW
						) END AS seq_std_days_between
		,CASE WHEN seq_con > 1 THEN stddev_pop(ABS(datediff(DAY, con_create_dt, lag_dt)) + 1) OVER (
						PARTITION BY cus_id ORDER BY con_create_dt ROWS BETWEEN 9 PRECEDING
								AND CURRENT ROW
						) END AS seq_std10_days_between
		,CASE WHEN seq_con > 1 THEN MEDIAN(ABS(datediff(DAY, con_create_dt, lag_dt)) + 1) OVER (PARTITION BY cus_id) END AS seq_median_days_between
	FROM (
		-- at this level we have already aggregated all our data on an account con_create dt
		-- we will create using windowing the necessary consignment and con create date information
		-- on teh next step will create a customer level table
		-- it runs
		SELECT fc2.*
			,ROW_NUMBER() OVER (
				PARTITION BY fc2.cus_id ORDER BY fc2.con_create_dt
				) AS seq_con
/* 			,SUM(fc2.is_sender_pays) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_sender_pays
			,SUM(fc2.count_consignments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_count_consignments
			,SUM(fc2.is_receiver_pays) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_receiver_pays
			,SUM(fc2.is_international_shipment) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_international_shipment
			,SUM(fc2.is_dangerous_shipment) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_dangerous_shipment */
/* 			,MAX(fc2.bul_id_orig) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_bul_id_orig
 			,SUM(fc2.goods_value) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_goods_value*/
			,SUM(fc2.shipments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_shipments
			,SUM(fc2.revenue) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_revenue
/* 			,SUM(fc2.sum_volume) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_volume
			, */
			-- YTD
			,SUM(fc2.shipments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country
				,DATE_PART(YEAR, con_create_dt) ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_ytd_shipments
			,SUM(fc2.revenue) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country
				,DATE_PART(YEAR, con_create_dt) ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_ytd_revenue
/* 			,SUM(fc2.sum_volume) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country
				,DATE_PART(YEAR, con_create_dt) ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_ytd_volume
			,SUM(fc2.sum_items) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country
				,DATE_PART(YEAR, con_create_dt) ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_ytd_items
			,SUM(fc2.sum_weight) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country
				,DATE_PART(YEAR, con_create_dt) ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_ytd_weight */
/* 			,
			-- Digital  
			SUM(fc2.digital_shipments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_digital_shipments
			,SUM(fc2.digital_revenue) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_digital_revenue
			,SUM(fc2.digital_volume) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_digital_volume
			,SUM(fc2.digital_items) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_digital_items
			,SUM(fc2.digital_weight) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_digital_weight
 *//* 			,
			-- my_tnt  
			SUM(fc2.is_mytnt_shipments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_mytnt_shipments
			,SUM(fc2.is_mytnt_revenue) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_mytnt_revenue
			,SUM(fc2.is_mytnt_volume) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_mytnt_volume
			,SUM(fc2.is_mytnt_items) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_mytnt_items
			,SUM(fc2.is_mytnt_weight) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_mytnt_weight
 *//*			,
			-- non digital 
 			SUM(fc2.no_dig_shipments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_no_dig_shipments
			,SUM(fc2.no_dig_revenue) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_no_dig_revenue
			,SUM(fc2.no_dig_volume) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_no_dig_volume
			,SUM(fc2.no_dig_items) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_no_dig_items
			,SUM(fc2.no_dig_weight) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_no_dig_weight
			,SUM(fc2.is_express_prdct) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_express_prdct
			,SUM(fc2.is_economy_prdct) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_economy_prdct
			,SUM(fc2.is_special_prdct) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_special_prdct
			,SUM(fc2.is_express_tool) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_express_tool
			,SUM(fc2.is_mytnt_tool) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_mytnt_tool
			,SUM(fc2.is_local_tool) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_local_tool
			,SUM(fc2.is_open_tool) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_open_tool
			,SUM(fc2.is_custom_tool) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_custom_tool
			,SUM(fc2.is_digital_tool) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_digital_tool
			,SUM(fc2.is_manual_tool) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_is_manual_tool
			,SUM(fc2.prod_is_VA) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_VA
			,SUM(fc2.prod_is_DT) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_DT
			,SUM(fc2.prod_is_XF) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_XF
			,SUM(fc2.prod_is_EF) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_EF
			,SUM(fc2.prod_is_EE) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_EE
			,SUM(fc2.prod_is_SS) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_SS
			,SUM(fc2.prod_is_SE) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_SE
			,SUM(fc2.prod_is_OT) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_OT
			,SUM(fc2.prod_is_FR) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_FR
			,SUM(fc2.prod_is_FR) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_prod_is_EX */
			/* ,AVG(fc2.goods_value) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_avg_goods_value */
			,AVG(fc2.shipments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_avg_shipments
			,AVG(fc2.revenue) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_avg_revenue
/* 			,AVG(fc2.sum_volume) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_avg_volume
			,AVG(fc2.sum_items) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_avg_items
			,AVG(fc2.sum_weight) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_avg_weight
 *//* 			,stddev_pop(fc2.goods_value) OVER (
				PARTITION BY fc2.cus_id
 				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_std_goods_value
*/  			
/* ,stddev_pop(fc2.shipments) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_std_shipments
			,stddev_pop(fc2.revenue) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_std_revenue
			,stddev_pop(fc2.sum_volume) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_std_volume
			,stddev_pop(fc2.sum_items) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_std_items
			,stddev_pop(fc2.sum_weight) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt ROWS BETWEEN UNBOUNDED PRECEDING
						AND CURRENT ROW
				) AS seq_std_weight */
			,LAG(fc2.con_create_dt, 1) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt
				) AS lag_dt
			,LAG(fc2.con_create_dt, 1) OVER (
				PARTITION BY fc2.cus_id
				,fc2.acc_country ORDER BY fc2.con_create_dt DESC
				) AS churn_lag_dt
		FROM (
			SELECT cust.cus_id
				, DT AS con_create_dt
				,acc_country
				,sum_shipments shipments
				,sum_shipments count_consignments
				,sum_revenue revenue
				-- small acceptable error with third party payment
/* 				, sum_shipments - sum_receiver_pays_shipments AS is_sender_pays 
				, sum_receiver_pays_shipments AS is_receiver_pays
				, sum_international_shipments AS is_international_shipment
				,sum_dangerous_shipment AS is_dangerous_shipment
 */				--,MAX(fc.bul_id_orig) AS bul_id_orig
				,(SELECT MAX(DT) FROM stg2_cust_daily_metrics) AS rs_insert_date
				, active_accounts AS count_accounts_under_customer
/* 				,SUM(fc.goods_value) AS goods_value 
				,SUM_shipments AS shipments
				,sum_revenue AS revenue
				,(sum_volume) AS sum_volume
				,(sum_items) AS sum_items
				,(sum_weight) AS sum_weight
				,SUM(CAST(prd.is_express_prdct AS INTEGER)) AS is_express_prdct
				,SUM(CAST(prd.is_economy_prdct AS INTEGER)) AS is_economy_prdct
				,SUM(CAST(prd.is_special_prdct AS INTEGER)) AS is_special_prdct
				,SUM(con.is_express_tool) AS is_express_tool
				,SUM(con.is_mytnt_tool) AS is_mytnt_tool
				,SUM(con.is_local_tool) AS is_local_tool
				,SUM(con.is_open_tool) AS is_open_tool
				,SUM(con.is_custom_tool) AS is_custom_tool
				,SUM(con.is_digital_tool) AS is_digital_tool
				,SUM(con.is_manual_tool) AS is_manual_tool
				,SUM(CASE WHEN prd.product_family_cd = 'VA' THEN 1 ELSE 0 END) AS prod_is_VA
				,SUM(CASE WHEN prd.product_family_cd = 'DT' THEN 1 ELSE 0 END) AS prod_is_DT
				,SUM(CASE WHEN prd.product_family_cd = 'XF' THEN 1 ELSE 0 END) AS prod_is_XF
				,SUM(CASE WHEN prd.product_family_cd = 'EF' THEN 1 ELSE 0 END) AS prod_is_EF
				,SUM(CASE WHEN prd.product_family_cd = 'EE' THEN 1 ELSE 0 END) AS prod_is_EE
				,SUM(CASE WHEN prd.product_family_cd = 'SS' THEN 1 ELSE 0 END) AS prod_is_SS
				,SUM(CASE WHEN prd.product_family_cd = 'SE' THEN 1 ELSE 0 END) AS prod_is_SE
				,SUM(CASE WHEN prd.product_family_cd = 'OT' THEN 1 ELSE 0 END) AS prod_is_OT
				,SUM(CASE WHEN prd.product_family_cd = 'FR' THEN 1 ELSE 0 END) AS prod_is_FR
				,SUM(CASE WHEN prd.product_family_cd = 'EX' THEN 1 ELSE 0 END) AS prod_is_EX
				,
				--create a sum for digital and for non_digital for revenue, volume and shipments
				SUM(CASE WHEN is_digital_tool = 1 THEN revenue END) AS digital_revenue
				,SUM(CASE WHEN is_digital_tool = 1 THEN shipments END) AS digital_shipments
				,SUM(CASE WHEN is_digital_tool = 1 THEN sum_volume END) AS digital_volume
				,SUM(CASE WHEN is_digital_tool = 1 THEN sum_weight END) AS digital_weight
				,SUM(CASE WHEN is_digital_tool = 1 THEN sum_items END) AS digital_items
				,SUM(CASE WHEN is_mytnt_tool = 1 THEN revenue END) AS is_mytnt_revenue
				,SUM(CASE WHEN is_mytnt_tool = 1 THEN shipments END) AS is_mytnt_shipments
				,SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_volume END) AS is_mytnt_volume
				,SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_weight END) AS is_mytnt_weight
				,SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_items END) AS is_mytnt_items
				,SUM(CASE WHEN is_digital_tool != 1 THEN revenue END) AS no_dig_revenue
				,SUM(CASE WHEN is_digital_tool != 1 THEN shipments END) AS no_dig_shipments
				,SUM(CASE WHEN is_digital_tool != 1 THEN sum_volume END) AS no_dig_volume
				,SUM(CASE WHEN is_digital_tool != 1 THEN sum_weight END) AS no_dig_weight
				,SUM(CASE WHEN is_digital_tool != 1 THEN sum_items END) AS no_dig_items
 */			FROM stg2_cust_daily_metrics cust
			INNER JOIN CHURN_ACTIVE_CUSTOMERS churn 
			ON churn.cus_id = cust.cus_id
		) AS fc2
		)
	)
ORDER BY cus_id
	,acc_country
	,con_create_dt;

ANALYZE stg2_fincon_daily_metrics_customer;
---------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------
-- Customer level table
DROP TABLE IF EXISTS stg2_customer_metrics_customer;

CREATE TABLE stg2_customer_metrics_customer AS
SELECT *
	,CASE WHEN max_cons > 0 THEN all_weekly / max_cons ELSE 0 END AS all_perc_weekly
	,CASE WHEN max_cons > 0 THEN all_biweekly / max_cons ELSE 0 END AS all_perc_biweekly
	,CASE WHEN max_cons > 0 THEN all_monthly / max_cons ELSE 0 END AS all_perc_monthly
	,CASE WHEN max_cons > 0 THEN all_half_yearly / max_cons ELSE 0 END AS all_perc_half_yearly
	,CASE WHEN max_cons > 0 THEN all_quarterly / max_cons ELSE 0 END AS all_perc_quarterly
	,CASE WHEN max_cons > 0 THEN all_yearly / max_cons ELSE 0 END AS all_perc_yearly
	,CASE WHEN st_cust_sales_type_desc IS NULL THEN 'other' ELSE st_cust_sales_type_desc END AS st_cust_sales_type_desc2
/* 	,CAST(CAST(all_is_sender_pays AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_sender_pays
	,CAST(CAST(all_is_receiver_pays AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_receiver_pays
	,CAST(CAST(all_is_international_shipment AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_international_shipment
	,CAST(CAST(all_is_dangerous_shipment AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_dangerous_shipment
	,CAST(CAST(all_is_express_prdct AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_express_prdct
	,CAST(CAST(all_is_economy_prdct AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_economy_prdct
	,CAST(CAST(all_is_special_prdct AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_special_prdct
	,CAST(CAST(all_is_express_tool AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_express_tool
	,CAST(CAST(all_is_mytnt_tool AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_mytnt_tool
	,CAST(CAST(all_is_local_tool AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_local_tool
	,CAST(CAST(all_is_open_tool AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_open_tool
	,CAST(CAST(all_is_custom_tool AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_custom_tool
	,CAST(CAST(all_is_digital_tool AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_digital_tool */
/* 	,CAST(CAST(all_is_manual_tool AS FLOAT) / all_count_consignments AS FLOAT) AS perc_all_is_manual_tool 
 */	/*CASE
           WHEN lag_seq_is_digital_tool = min_date THEN 1
           ELSE 0
         END growth_cust,
         CASE
           WHEN lag_seq_is_digital_tool > min_date THEN 1
           ELSE 0
         END shift_cust*/
FROM (
	-- it runs
	SELECT sum(CASE WHEN DATE_PART(year, con_create_dt) = 2014 THEN shipments END) AS all_shipments_2014
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2015 THEN shipments END) AS all_shipments_2015
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2016 THEN shipments END) AS all_shipments_2016
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2017 THEN shipments END) AS all_shipments_2017
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2014 THEN revenue END) AS all_revenue_2014
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2015 THEN revenue END) AS all_revenue_2015
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2016 THEN revenue END) AS all_revenue_2016
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2017 THEN revenue END) AS all_revenue_2017
/* 		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2014 THEN sum_volume END) AS all_sum_volume_2014
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2015 THEN sum_volume END) AS all_sum_volume_2015
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2016 THEN sum_volume END) AS all_sum_volume_2016
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2017 THEN sum_volume END) AS all_sum_volume_2017
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2014 THEN sum_weight END) AS all_sum_weight_2014
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2015 THEN sum_weight END) AS all_sum_weight_2015
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2016 THEN sum_weight END) AS all_sum_weight_2016
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2017 THEN sum_weight END) AS all_sum_weight_2017
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2014 THEN sum_items END) AS all_sum_items_2014
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2015 THEN sum_items END) AS all_sum_items_2015
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2016 THEN sum_items END) AS all_sum_items_2016
		,sum(CASE WHEN DATE_PART(year, con_create_dt) = 2017 THEN sum_items END) AS all_sum_items_2017
 */		,cus_id AS all_cus_id
		,acc_country AS all_country
		,datediff(days, MIN(con_create_dt), MAX(con_create_dt)) AS all_days_active
		,SUM(weekly) AS all_weekly
		,MAX(rs_insert_date) AS all_rs_insert_dt
		,SUM(biweekly) AS all_biweekly
		,SUM(monthly) AS all_monthly
		,SUM(quarterly) AS all_quarterly
		,SUM(half_yearly) AS all_half_yearly
		,SUM(yearly) AS all_yearly
		,AVG(seq_days_between) AS all_avg_days_between
		,stddev_pop(seq_days_between) AS all_std_days_between
		,MAX(seq_con) AS max_cons
		,SUM(count_consignments) AS all_count_consignments
 		,COUNT(*) AS count_seq_con
/*		,SUM(is_sender_pays) AS all_is_sender_pays
		,SUM(is_receiver_pays) AS all_is_receiver_pays
		,
		--- 
		SUM(is_international_shipment) AS all_is_international_shipment
		,SUM(is_dangerous_shipment) AS all_is_dangerous_shipment */
		-- ,MAX(bul_id_orig) AS all_bul_id_orig
		/* ,SUM(goods_value) AS all_sum_goods_value */
		,SUM(shipments) AS all_sum_shipments
		,SUM(revenue) AS all_sum_revenue
/* 		,SUM(sum_volume) AS all_sum_volume
		,SUM(sum_items) AS all_sum_items
		,SUM(sum_weight) AS all_sum_weight
		,SUM(is_express_prdct) AS all_is_express_prdct
		,SUM(is_economy_prdct) AS all_is_economy_prdct
		,SUM(is_special_prdct) AS all_is_special_prdct
		,SUM(is_express_tool) AS all_is_express_tool
		,SUM(is_mytnt_tool) AS all_is_mytnt_tool
		,SUM(is_local_tool) AS all_is_local_tool
		,SUM(is_open_tool) AS all_is_open_tool
		,SUM(is_custom_tool) AS all_is_custom_tool
		,SUM(is_digital_tool) AS all_is_digital_tool
		,SUM(is_manual_tool) AS all_is_manual_tool */
		,MIN(con_create_dt) AS all_min_date
		,MAX(con_create_dt) AS all_max_date
		/* ,AVG(goods_value) AS all_avg_goods_value */
 		,AVG(shipments) AS all_avg_shipments
		,AVG(revenue) AS all_avg_revenue
/*		,AVG(sum_volume) AS all_avg_volume
		,AVG(sum_items) AS all_avg_items
		,AVG(sum_weight) AS all_avg_weight */
		/* ,stddev_pop(goods_value) AS all_std_goods_value */
		,stddev_pop(shipments) AS all_std_shipments
		,stddev_pop(revenue) AS all_std_revenue
/* 		,stddev_pop(sum_volume) AS all_std_volume
		,stddev_pop(sum_items) AS all_std_items
		,stddev_pop(sum_weight) AS all_std_weight
		-- percentage
		--,MIN(CASE WHEN is_digital_tool THEN con_create_dt ELSE CURRENT_DATE END) AS least_digital_dt,
		,SUM(CASE WHEN is_digital_tool = 1 THEN revenue END) AS all_digital_revenue
		,SUM(CASE WHEN is_digital_tool = 1 THEN shipments END) AS all_digital_shipments
		,SUM(CASE WHEN is_digital_tool = 1 THEN sum_volume END) AS all_digital_volume
		,SUM(CASE WHEN is_digital_tool = 1 THEN sum_weight END) AS all_digital_weight
		,SUM(CASE WHEN is_digital_tool = 1 THEN sum_items END) AS all_digital_items
		,SUM(CASE WHEN is_mytnt_tool = 1 THEN revenue END) AS all_is_mytnt_revenue
		,SUM(CASE WHEN is_mytnt_tool = 1 THEN shipments END) AS all_is_mytnt_shipments
		,SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_volume END) AS all_is_mytnt_volume
		,SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_weight END) AS all_is_mytnt_weight
		,SUM(CASE WHEN is_mytnt_tool = 1 THEN sum_items END) AS all_is_mytnt_items
		,SUM(CASE WHEN is_digital_tool != 1 THEN revenue END) AS all_no_dig_revenue
		,SUM(CASE WHEN is_digital_tool != 1 THEN shipments END) AS all_no_dig_shipments
		,SUM(CASE WHEN is_digital_tool != 1 THEN sum_volume END) AS all_no_dig_volume
		,SUM(CASE WHEN is_digital_tool != 1 THEN sum_weight END) AS all_no_dig_weight
		,SUM(CASE WHEN is_digital_tool != 1 THEN sum_items END) AS all_no_dig_items
		,SUM(CASE WHEN seq_con = 1
					AND is_digital_tool = 1 THEN 1 ELSE 0 END) AS growth_cust */
	FROM stg2_fincon_daily_metrics_customer
	GROUP BY cus_id
		,acc_country
	)
	--lac_legacy_cou_cd
	--lac_legacy_acg_cd,
	--lac_legacy_acct_nr,
	--lac_legacy_nad_cd) 
	AS t1
LEFT JOIN (
	SELECT DISTINCT cus_id AS st_cus_id
		,cus_cou_id
		,cust_sales_territory_cd
		,cust_sales_type_desc AS st_cust_sales_type_desc
	FROM stg1_sales_territory
	WHERE cust_sales_type_desc IS NOT NULL
		AND cust_sales_territory_cd IN (
			'02'
			,'20'
			,'18'
			,'16'
			,'19'
			,'04'
			,'01'
			)
	) AS t2 ON t1.all_cus_id = t2.st_cus_id
	AND t1.all_country = t2.cus_cou_id;

--select * from stg2_customer_metrics_customer;
GRANT SELECT
	ON TABLE stg2_customer_metrics_customer
	TO PUBLIC;

ANALYZE stg2_customer_metrics_customer;

DROP TABLE IF EXISTS stg2_customer_daily_metrics_customer;
--select distinct conf_10_interval_95 from stg2_customer_daily_metrics_customer;
CREATE TABLE stg2_customer_daily_metrics_customer AS
SELECT *
	,DATE_PART(year, con_create_dt) AS year
	,DATE_PART(month, con_create_dt) AS month
	,DATE_PART(quarter, con_create_dt) AS quarter
	,DATE_PART(week, con_create_dt) AS week
	,DATE_PART(dow, con_create_dt) AS dayofweek
	,DATE_PART(year, con_create_dt) || DATE_PART(month, con_create_dt) || DATE_PART(week, con_create_dt) AS time_id
	-- Create metrics for reduction of sales and volume
	-- average volume - the current
	-- create the percentages
	--receiver/ payer
	
	,seq_avg_days_between - seq_days_between AS seq_down_days
	,CASE WHEN ( seq_revenue) = 0  THEN 0 ELSE revenue * seq_con * 1.0 / seq_revenue END AS seq_down_revenue
	,CASE WHEN ( seq_shipments) = 0 THEN 0 ELSE shipments * seq_con * 1.0 / seq_shipments END AS seq_down_shipments
/* 	,
	-- swift/ growth
	-- create filetrs with the dummy of digital to add up volume, revenue, shipments, items
	--case when 
	--abs(datediff(days, con_create_dt,lag_dt))<
	seq_is_sender_pays / seq_count_consignments AS perc_seq_is_sender_pays
	,seq_is_receiver_pays / seq_count_consignments AS perc_seq_is_receiver_pays
	,seq_is_international_shipment / seq_count_consignments AS perc_seq_is_international_shipment
	,seq_is_dangerous_shipment / seq_count_consignments AS perc_seq_is_dangerous_shipment
	,seq_is_express_prdct / seq_count_consignments AS perc_seq_is_express_prdct
	,seq_is_economy_prdct / seq_count_consignments AS perc_seq_is_economy_prdct
	,seq_is_special_prdct / seq_count_consignments AS perc_seq_is_special_prdct
	,seq_is_express_tool / seq_count_consignments AS perc_seq_is_express_tool
	,seq_is_mytnt_tool / seq_count_consignments AS perc_seq_is_mytnt_tool
	,seq_is_local_tool / seq_count_consignments AS perc_seq_is_local_tool
	,seq_is_open_tool / seq_count_consignments AS perc_seq_is_open_tool
	,seq_is_custom_tool / seq_count_consignments AS perc_seq_is_custom_tool
	,seq_is_digital_tool / seq_count_consignments AS perc_seq_is_digital_tool
	,seq_is_manual_tool / seq_count_consignments AS perc_seq_is_manual_tool
	,seq_prod_is_va / seq_count_consignments AS perc_seq_prod_is_va
	,seq_prod_is_dt / seq_count_consignments AS perc_seq_prod_is_dt
	,seq_prod_is_xf / seq_count_consignments AS perc_seq_prod_is_xf
	,seq_prod_is_ef / seq_count_consignments AS perc_seq_prod_is_ef
	,seq_prod_is_ee / seq_count_consignments AS perc_seq_prod_is_ee
	,seq_prod_is_ss / seq_count_consignments AS perc_seq_prod_is_ss
	,seq_prod_is_se / seq_count_consignments AS perc_seq_prod_is_se
	,seq_prod_is_ot / seq_count_consignments AS perc_seq_prod_is_ot
	,seq_prod_is_fr / seq_count_consignments AS perc_seq_prod_is_fr
	,seq_prod_is_ex / seq_count_consignments AS perc_seq_prod_is_ex
 */	,
	-- date
	-- churn event
	CAST(conf_interval_95 AS INT) + con_create_dt AS nrmd_churn_dt
	,CAST(yellow_conf_interval_95 AS INT) + con_create_dt AS yellow_nrmd_churn_dt
	,CAST(conf_10_interval_95 AS INT) + con_create_dt AS nrm_10_churn_dt
	,CAST(yellow_conf_10_interval_95 AS INT) + con_create_dt AS yellow_nrm_10_churn_dt
	,CASE WHEN CAST(conf_10_interval_95 AS BIGINT) < churn_days_between + 7
			AND seq_std10_days_between > 0 THEN 1 ELSE 0 END churn_10nrw_dis
	,CASE WHEN CAST(conf_interval_95 AS BIGINT) < churn_days_between + 7
			AND seq_std_days_between > 0 THEN 1 ELSE 0 END churn_nrw_dis
	,CASE WHEN CAST(yellow_conf_interval_95 AS BIGINT) < churn_days_between + 7
			AND seq_std_days_between > 0 THEN 1 ELSE 0 END churn_yellow_nrw_dis
	,
	-- 10 days churn
	CASE WHEN CAST(conf_10_interval_95 AS BIGINT) > 11
			AND seq_std10_days_between > 0 THEN 1 ELSE 0 END churn_nrw_10days
	,
	-- 30 days churn
	CASE WHEN CAST(conf_10_interval_95 AS BIGINT) > 31
			AND seq_std10_days_between > 0 THEN 1 ELSE 0 END churn_nrw_30days
	,
	-- 90 days churn
	CASE WHEN CAST(conf_10_interval_95 AS BIGINT) > 91
			AND seq_std10_days_between > 0 THEN 1 ELSE 0 END churn_nrw_90days
	,
	-- 365 days churn
	CASE WHEN CAST(conf_10_interval_95 AS BIGINT) > 365
			AND seq_std10_days_between > 0 THEN 1 ELSE 0 END churn_nrw_365days
	,
	----------------------------------------
	ABS(datediff(DAY, con_create_dt, all_min_date)) + 1 AS seq_days_active
	,ABS(datediff(DAY, con_create_dt, CURRENT_DATE)) + 1 AS seq_days_from_today
	,CASE WHEN (
				churn_days_between > 0
				AND churn_days_between > 10
				)
			OR (
				churn_days_between IS NULL
				AND con_create_dt < rs_insert_date - 10
				) THEN 1 ELSE 0 END churn_10
	,CASE WHEN churn_days_between > 0
			AND churn_days_between > 30
			OR (
				churn_days_between IS NULL
				AND con_create_dt < rs_insert_date - 30
				) THEN 1 ELSE 0 END churn_30
	,CASE WHEN churn_days_between > 0
			AND churn_days_between > 90
			OR (
				churn_days_between IS NULL
				AND con_create_dt < rs_insert_date - 90
				) THEN 1 ELSE 0 END churn_90
	,CASE WHEN churn_days_between > 0
			AND churn_days_between > 180
			OR (
				churn_days_between IS NULL
				AND con_create_dt < rs_insert_date - 180
				) THEN 1 ELSE 0 END churn_180
	,CASE WHEN churn_days_between > 0
			AND churn_days_between > 365
			OR (
				churn_days_between IS NULL
				AND con_create_dt < rs_insert_date - 365
				) THEN 1 ELSE 0 END churn_365
FROM (
	SELECT *
		,
		-- conf interval 365
		LEAST(364, ROUND(seq_avg10_days_between + 2 * seq_std10_days_between)) AS conf_10_interval_95
		,LEAST(364, ROUND(seq_avg_days_between + 2 * seq_std_days_between)) AS conf_interval_95
		,LEAST(364, ROUND(seq_avg10_days_between + 1 * seq_std10_days_between)) AS yellow_conf_10_interval_95
		,LEAST(364, ROUND(seq_avg_days_between + 1 * seq_std_days_between)) AS yellow_conf_interval_95
		,CASE WHEN coh.seq_con < cust.max_cons THEN ABS(datediff(DAY, coh.con_create_dt, coh.churn_lag_dt)) + 1 WHEN coh.seq_con = cust.max_cons THEN ABS(datediff(DAY, coh.con_create_dt, CURRENT_DATE)) ELSE 0 END AS churn_days_between
	FROM (
		SELECT *
		FROM stg2_fincon_daily_metrics_customer
		) AS coh
	LEFT JOIN stg2_customer_metrics_customer AS cust ON coh.cus_id = cust.all_cus_id
		AND coh.acc_country = cust.all_country
	);

GRANT SELECT ON TABLE stg2_customer_daily_metrics_customer TO PUBLIC;

ANALYZE stg2_customer_daily_metrics_customer;

COMMIT;