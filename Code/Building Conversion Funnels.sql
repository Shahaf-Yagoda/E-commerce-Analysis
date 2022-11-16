CREATE TEMPORARY TABLE sessions_flags
SELECT
	website_session_id,
    max(products_page) AS product_made_it,
    max(mrfuzzy_page) AS mrfuzzy_made_it,
    max(cart_page) AS cart_made_it,
    max(shipping_page) AS shipping_made_it,
    max(billing_page) AS billing_made_it,
    max(thank_you_page) AS thank_you_made_it
FROM
	(SELECT
		website_sessions.website_session_id,
		pageview_url,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
		CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page,
		CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
		CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
		CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
		CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
	FROM 
		website_pageviews 
			LEFT JOIN website_sessions
				ON website_pageviews.website_session_id = website_sessions.website_session_id
	WHERE 
		website_pageviews.created_at BETWEEN '2012-08-05' AND '2012-09-05'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand') AS page_view_level
        
GROUP BY 1;

-- Calculate the number of sessions for each page
SELECT
	count(DISTINCT website_session_id) AS num_of_sessions,
    count(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) AS product_rate,
    count(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_rate,
    count(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_rate,
    count(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_rate,
    count(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_rate,
    count(DISTINCT CASE WHEN thank_you_made_it = 1 THEN website_session_id ELSE NULL END) AS thank_rate
FROM
	sessions_flags;


-- Calculate clicks rate
SELECT 
	count(DISTINCT website_session_id) as num_of_sessions,
    count(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)/count(website_session_id)*100 AS product_rate,
    count(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)/count(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END)*100 AS mrfuzzy_rate,
    count(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)/count(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END)*100 AS cart_rate,
    count(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)/count(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)*100 AS shipping_rate,
    count(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)/count(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)*100 AS billing_rate,
    count(DISTINCT CASE WHEN thank_you_made_it = 1 THEN website_session_id ELSE NULL END)/count(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)*100 AS thank_rate
FROM
	sessions_flags