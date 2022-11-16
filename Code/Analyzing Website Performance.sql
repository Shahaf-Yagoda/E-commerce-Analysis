use mavenfuzzyfactory;

-- Finding Top Website Pages
SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageview_id) AS sessions
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY 1
ORDER BY 2 DESC;

--  Finding Top Entry Pages
-- STEP 1: find the first pageview for each session
-- STEP 2: find the url the customer saw on that firs pageview

CREATE TEMPORARY TABLE first_pageview
SELECT 
    website_session_id, 
    MIN(website_pageview_id) AS first_pv_id    -- The first pageview id that shows up
FROM
    website_pageviews
WHERE
    created_at < '2012-06-12'
GROUP BY 1;


SELECT 
    website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT first_pageview.website_session_id) AS sessions_hitting_this_lander
FROM
    first_pageview
        LEFT JOIN
    website_pageviews ON first_pageview.first_pv_id = website_pageviews.website_pageview_id
GROUP BY 1;

-- solution 2 (using subquery):
SELECT 
	website_pageviews.pageview_url AS landing_page,
    COUNT(DISTINCT a.website_session_id) AS sessions_hitting_this_lander
FROM 
	(SELECT 
    website_session_id, 
    MIN(website_pageview_id) AS first_pv_id    -- The first pageview id that shows up
	FROM
		website_pageviews
	WHERE
		created_at < '2012-06-12'
	GROUP BY 1) a
LEFT JOIN
    website_pageviews ON a.first_pv_id = website_pageviews.website_pageview_id
GROUP BY 1;