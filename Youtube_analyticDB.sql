create database YouTubeAnalyticsDB
select *from[dbo].[Global YouTube Statistics - Main]

------------------------------------------
-- find the total number of records in the dataset
select
	 count(*) as no_of_rows 
from 
	[dbo].[Global YouTube Statistics - Main]
----------------
--check whether duplictes channel names exist
select *from [dbo].[Global YouTube Statistics - Main]
select
	[Youtuber], 
	 count([Youtuber])  as channel_type
from  
    [dbo].[Global YouTube Statistics - Main]
group by 
   [Youtuber] 
having 
    count([Youtuber]) > 1;
-----------
 --identify all columns containing null values
 select *from[dbo].[Global YouTube Statistics - Main] 

 select
	sum(case when [Youtuber] IS NULL then 1 else 0 end) AS youtuber_null,
    sum(case when[subscribers]  IS NULL then 1 else 0 end) AS subscribers_null,
	sum(case when[video_views] IS NULL then 1 else 0 end) AS video_view_null,
	sum(case when[category] IS NULL then 1 else 0 end) AS category_null,
    sum(case when[Abbreviation] IS NULL then 1 else 0 end) AS Abbreviation_null,
	sum(case when[channel_type_rank] IS NULL then 1 else 0 end) AS channel_null,
	sum(case when[video_views_rank] IS NULL then 1 else 0 end) AS video_views_rank_null
 from
    [dbo].[Global YouTube Statistics - Main]
----------------------------------------
select
	count(*)
from 
	[dbo].[Global YouTube Statistics - Main]
where [Country] is null
----------------
--Replace null value wherever appropriate

--verify and correct the data types of all numeric and date cloumn
--done during the importing the data 
------------------------------------------
--display top 10 youtube channels based on subscribers
select top 10 * 
	from [dbo].[Global YouTube Statistics - Main]
order by
	 [subscribers] desc
-----------------------------------
--find the top 5 countries having the highest total subscribers
select top 5[Country] ,
	sum([subscribers]) as total_subscribers
from 
	[dbo].[Global YouTube Statistics - Main]
group by 
	[Country]
order by total_subscribers desc
-----
alter table [dbo].[Global YouTube Statistics - Main]
alter column [subscribers] bigint
-----
select *from [dbo].[Global YouTube Statistics - Main]
-----
--display the top 10 categories based on total video views
select top 10 [category], 
	sum([video_views]) as total_video_views
from 
	[dbo].[Global YouTube Statistics - Main]
group by 
	[category]
order by total_video_views desc
-----------------------
--find the channel having the highest subscriber gain in the last 30 days
select top 1
	* from [dbo].[Global YouTube Statistics - Main]
order by 
	subscribers_for_last_30_days
------------------------
--calculate the average earing for each youtube category
select [category],
	count(*) as total_channels,
	round(avg([lowest_yearly_earnings]), 2) as avg_lowest_yearly_earning,
	round(avg([highest_yearly_earnings]),2) as avg_highest_yearly_earning,
	round(avg ([lowest_yearly_earnings]+([highest_yearly_earnings])) /2 ,2) as combination_of_earning
from 
	[dbo].[Global YouTube Statistics - Main]
group by 
	[category]
order by 
	combination_of_earning desc
--------------------------------
/**--create a sql view named vw_Channelperformance containg the following
. channel name
.country
.category
.subscribers
.video views
.uploads
.highest yearly earning
**/
create or alter view vw_ChannelPerformance as
select
	[Youtuber] as channel_name,
	[Country],
	[category],
	[subscribers],
	[video_views],
	[uploads],
	[highest_yearly_earnings]
from 
	[dbo].[Global YouTube Statistics - Main]

