-- 1. DATA CLEANING
-- Looking for duplicate data (using row_number > 1)
with duplicate_data as (SELECT `vgsales`.`Rank`,
    `vgsales`.`Name`,
    `vgsales`.`Platform`,
    `vgsales`.`Year`,
    `vgsales`.`Genre`,
    `vgsales`.`Publisher`,
    `vgsales`.`NA_Sales`,
    `vgsales`.`EU_Sales`,
    `vgsales`.`JP_Sales`,
    `vgsales`.`Other_Sales`,
    `vgsales`.`Global_Sales`,
    row_number() over(partition by `vgsales`.`Rank`,
    `vgsales`.`Name`,
    `vgsales`.`Platform`,
    `vgsales`.`Year`,
    `vgsales`.`Genre`,
    `vgsales`.`Publisher`,
    `vgsales`.`NA_Sales`,
    `vgsales`.`EU_Sales`,
    `vgsales`.`JP_Sales`,
    `vgsales`.`Other_Sales`,
    `vgsales`.`Global_Sales`) as rn
FROM `videogamesale`.`vgsales`)
select * from duplicate_data where rn>1;


-- Check for the 'null' values
SELECT 
  COUNT(*) - COUNT(`rank`) AS Null_Rank,
  COUNT(*) - COUNT(Name) AS Null_Name,
  COUNT(*) - COUNT(Platform) AS Null_Platform,
  COUNT(*) - COUNT(Year) AS Null_Year,
  COUNT(*) - COUNT(Genre) AS Null_Genre,
  COUNT(*) - COUNT(Publisher) AS Null_Publisher,
  COUNT(*) - COUNT(NA_Sales) AS Null_NA_Sales,
  COUNT(*) - COUNT(EU_Sales) AS Null_EU_Sales,
  COUNT(*) - COUNT(JP_Sales) AS Null_JP_Sales,
  COUNT(*) - COUNT(Other_Sales) AS Null_Other_Sales,
  COUNT(*) - COUNT(Global_Sales) AS Null_Global_Sales
FROM 
  vgsales;


-- Check for missing values ('N/A')  
SELECT
    SUM(CASE WHEN `Rank` = 'N/A' THEN 1 ELSE 0 END) AS Rank_na_count,
    SUM(CASE WHEN `Name` = 'N/A' THEN 1 ELSE 0 END) AS Name_na_count,
    SUM(CASE WHEN `Platform` = 'N/A' THEN 1 ELSE 0 END) AS Platform_na_count,
    SUM(CASE WHEN `Year` = 'N/A' THEN 1 ELSE 0 END) AS Year_na_count,
    SUM(CASE WHEN `Genre` = 'N/A' THEN 1 ELSE 0 END) AS Genre_na_count,
    SUM(CASE WHEN `Publisher` = 'N/A' THEN 1 ELSE 0 END) AS Publisher_na_count,
    SUM(CASE WHEN `NA_Sales` like 'N/A' OR `NA_Sales` IS NULL THEN 1 ELSE 0 END) AS NA_Sales_na_count,
    SUM(CASE WHEN `EU_Sales` like 'N/A' OR `EU_Sales` IS NULL THEN 1 ELSE 0 END) AS EU_Sales_na_count,
    SUM(CASE WHEN `JP_Sales` like 'N/A' OR `JP_Sales` IS NULL THEN 1 ELSE 0 END) AS JP_Sales_na_count,
    SUM(CASE WHEN `Other_Sales` like 'N/A' OR `Other_Sales` IS NULL THEN 1 ELSE 0 END) AS Other_Sales_na_count,
    SUM(CASE WHEN `Global_Sales` like 'N/A' OR `Global_Sales` IS NULL THEN 1 ELSE 0 END) AS Global_Sales_na_count
FROM
    vgsales;
-- There are 271 and 58 missing values on 'year' and 'publisher' column
-- I will change to 'null' for N/A in 'Year' column
-- In this way, I will not lose actual information and i can convert 'Year' to interger
update vgsales
set `Year` = null
where `Year` = 'N/A';

alter table vgsales modify column `Year` int;

-- In 'Publisher' column, i will change 'N/A' values to 'Unknown'
update vgsales
set Publisher = 'Unknown'
where Publisher = 'N/A';

-- I also found 2 two publishers 'Milestone S.r.l' and 'Milestone S.r.l.'
-- I searched Google and found out that 'Milestone S.r.l.' is the correct Publisher
-- So now I change 'Milestone S.r.l' to 'Milestone S.r.l.'
update vgsales
set Publisher = 'Milestone S.r.l.'
where Publisher = 'Milestone S.r.l';

-- Convert NA_Sales, EU_Sales, JP_Sales, Other_Sales, Global_Sales to Float
alter table vgsales
modify column NA_Sales float,
modify column EU_Sales float,
modify column JP_Sales float,
modify column Other_Sales float,
modify column Global_Sales float;

-- 2. DATA ANALYSIS
-- 2.1 Which platform has the highest sales?
select Platform, round(sum(Global_Sales),2) as Global_sales from vgsales
group by Platform
order by 2 desc limit 1;

-- 2.2 What is the most common platform for the top 10 best-selling games?
SELECT Platform, COUNT(*) AS Count
FROM vgsales
WHERE `Rank` <= 10
GROUP BY Platform
ORDER BY Count DESC
LIMIT 1; 

-- 2.3 What are the top 5 genres by total global sales?
select Genre, round(sum(Global_Sales),2) as Global_sales from vgsales
group by 1
order by 2 desc limit 5;

-- 2.4 How have global sales trends changed over the years?
select `Year`, round(sum(Global_Sales),2) as Global_sales from vgsales
group by 1
order by 1;

-- 2.5 How many games have been released by each publisher?
select Publisher,count(`Name`) as total_games from vgsales
group by Publisher;

-- 2.6 What is the total global sales of game publishers in each genre?
select Publisher, Genre, round(sum(Global_Sales),2) as Global_sales from vgsales
group by 1,2
order by 1 ;

-- 2.7 What is the percentage distribution of sales in each regions for the global sales of video games?
select 
round((sum(NA_Sales) / sum(Global_Sales)) * 100,2) as NA_sales_percent,
round((sum(EU_Sales) / sum(Global_Sales)) * 100,2) as EU_sales_percent,
round((sum(JP_Sales) / sum(Global_Sales)) * 100,2) as JP_sales_percent,
round((sum(Other_Sales) / sum(Global_Sales)) * 100,2) as Other_sales_percent
 from vgsales;
 
-- 2.8 Which game has the highest sales in each region?
select Publisher,`Name`, round(sum(NA_Sales),2) as total_NA_sales
from vgsales
group by 1,2
order by total_NA_sales desc
limit 1;

select Publisher,`Name`, round(sum(EU_Sales),2) as total_EU_sales
from vgsales
group by 1,2
order by total_EU_sales desc
limit 1;

select Publisher,`Name`, round(sum(JP_Sales),2) as total_JP_sales
from vgsales
group by 1,2
order by total_JP_sales desc
limit 1;

select Publisher,`Name`, round(sum(Other_Sales),2) as total_Other_sales
from vgsales
group by 1,2
order by total_Other_sales desc
limit 1;

-- 2.9 Which game title has the highest global sales for each publisher?
with rank_topsale as(
select Publisher,Genre,`Name`,Global_Sales,
dense_rank() over(partition by publisher order by Global_Sales desc) as rank_gs from vgsales)
select Publisher,Genre,`Name`,Global_Sales from rank_topsale where rank_gs = 1 ;
 
-- 2.10 Which genre game is most released in each platform?
with rank_total_game as
(select Platform,Genre, count(`Name`) as total_game_released from vgsales
group by 1,2), rank_top1 as(
select *,
dense_rank() over(partition by Platform order by total_game_released desc) as ranks_total_game from rank_total_game)
select Platform,Genre,total_game_released from rank_top1 where ranks_total_game = 1;