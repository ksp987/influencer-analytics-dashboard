
-- View 1: Influencer Engagement Summary
-- Purpose: Shows average engagement rate per influencer
CREATE VIEW vw_influencer_engagement_summary AS
SELECT
	ip.influencer_id,
	ip.name,
	ip.platform,
	ip.category,
	ip.location,
	COUNT(cp.performance_id) AS total_posts,
	SUM(cp.impressions) AS total_impressions,
	SUM(cp.likes + cp.comments + cp.shares) AS total_engagements,
	ROUND(SUM(cp.likes + cp.comments + cp.shares)*1.0 / NULLIF(SUM(cp.impressions),0) * 100, 2) AS avg_engagement_rate
FROM
	campaign_performance cp
JOIN
	influencer_profiles ip ON cp.influencer_id = ip.influencer_id
GROUP BY
	ip.influencer_id;
	
-- View 2: Campaign ROI
-- Purpose: Calculate campaign Return on Investment (assume $50 per conversion)
CREATE VIEW vw_campaign_roi AS
SELECT
	c.campaign_id,
	c.campaign_name,
	c.brand_name,
	c.start_date,
	c.end_date,
	c.budget,
	SUM(cp.conversions) AS total_conversions,
	ROUND(SUM(cp.conversions) * 50.0, 2) AS est_revenue,
	ROUND((SUM(cp.conversions) * 50.0)/NULLIF(c.budget, 0), 2) AS roi_ratio
FROM
	campaign_performance cp
JOIN
	campaigns c ON cp.campaign_id = c.campaign_id
GROUP BY
	c.campaign_id;
	
-- View 3: Region Campaign Summary
-- Purpose: Regional reach and campaign volume by influencer region
CREATE VIEW vw_region_campaign_summary AS
SELECT
	ip.location AS region,
	COUNT(DISTINCT cp.campaign_id) AS campaigns_run,
	SUM(cp.impressions) AS total_impressions,
	SUM(cp.conversions) AS total_conversions
FROM
	campaign_performance cp
JOIN
	influencer_profiles ip ON cp.influencer_id = ip.influencer_id
GROUP BY 
	ip.location;

-- View 4: Influencers with most conversions per 1000 impressions
-- Purpose: Help business prioritize performance over polularity (Which influencers are truly converting users efficiently)
CREATE VIEW vw_best_influencer_per_1000 AS
SELECT
	ip.influencer_id,
	ip.name,
	ip.platform,
	ip.category,
	SUM(cp.impressions) AS total_reach,
	SUM(cp.conversions) AS total_conversions,
	ROUND(AVG(cp.impressions), 2) AS avg_impressions_per_post,
	ROUND((SUM(cp.conversions)*1.0/NULLIF(SUM(cp.impressions),2))*1000, 2 ) AS conversions_per_1000
FROM
	campaign_performance cp
JOIN
	influencer_profiles ip ON cp.influencer_id = ip.influencer_id
GROUP BY
	ip.influencer_id;