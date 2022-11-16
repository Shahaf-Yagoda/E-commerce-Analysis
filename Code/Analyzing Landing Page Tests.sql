-- find out when the page (/lander-1) launched
SELECT 
    created_at AS first_created_at,
    website_pageview_id AS first_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1'
ORDER BY created_at
LIMIT 1; 


CREATE TEMPORARY TABLE first_test_pageviews
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
        JOIN
    website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
        AND website_sessions.created_at BETWEEN '2012-06-19' AND '2012-07-28'
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1;


-- Bring in the landing page to each session
CREATE TEMPORARY TABLE sessions_w_landing_page_demo
SELECT 
    first_test_pageviews.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_test_pageviews
        LEFT JOIN
    website_pageviews ON first_test_pageviews.min_pageview_id = website_pageviews.website_pageview_id
						-- webstie pageview is the landing page view
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1');


-- create a table to include a count of pageviews per session
CREATE TEMPORARY TABLE nonbrand_bounced_sessions_only 
SELECT 
    sessions_w_landing_page_demo.website_session_id,
    sessions_w_landing_page_demo.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS count_of_pages_views
FROM
    sessions_w_landing_page_demo
        LEFT JOIN
    website_pageviews ON sessions_w_landing_page_demo.website_session_id = website_pageviews.website_session_id
GROUP BY 1 , 2
HAVING 
	COUNT(website_pageviews.website_pageview_id) = 1;
    
    
SELECT 
    sessions_w_landing_page_demo.landing_page,
    COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id) AS sessions,
    COUNT(DISTINCT nonbrand_bounced_sessions_only.website_session_id) AS bounced_session, 
    COUNT(DISTINCT nonbrand_bounced_sessions_only.website_session_id)/ COUNT(DISTINCT sessions_w_landing_page_demo.website_session_id)*100 AS bounce_rate
FROM
    sessions_w_landing_page_demo
        LEFT JOIN
    nonbrand_bounced_sessions_only ON sessions_w_landing_page_demo.website_session_id = nonbrand_bounced_sessions_only.website_session_id
GROUP BY 1
ORDER BY 2


