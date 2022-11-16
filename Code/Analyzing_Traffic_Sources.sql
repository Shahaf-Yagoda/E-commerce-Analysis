use mavenfuzzyfactory;
-- Analyzing Top Traffic Sources
-- Breakdown by UTM source, campign and referring domain
SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY 1 , 2 , 3
ORDER BY 4 DESC;

-- conversion rate analysis 
SELECT 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    (COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id)) * 100 AS session_to_order_conv_rt
FROM
    website_sessions
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-04-14'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand';
   
   
-- Bid Optimization
-- pull gsearch nonbrand trended session volume by week

SELECT 
	-- YEAR(created_at) as year , WEEK(created_at) as week,  
    MIN(DATE(created_at)) AS week_start_date,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    website_sessions.created_at < '2012-05-10'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 
		YEAR(created_at) , WEEK(created_at);


-- Bid Optimization, conversion rate by device type
SELECT 
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    (COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id)) * 100 AS session_to_order_conv_rt
FROM
    website_sessions 
        LEFT JOIN
    orders ON website_sessions.website_session_id = orders.website_session_id
WHERE
    website_sessions.created_at < '2012-05-11'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY 1;

-- Weekly trends for both desktop and mobile
SELECT 
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mobile_sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-04-15' AND '2012-06-09'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), WEEK(created_at)