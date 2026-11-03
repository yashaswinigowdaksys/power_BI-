use mobile
create database mobile
--------------------------------------------------------
select *from [dbo].[top 120 best-selling mobile phones]
----------------
--1. Complex Queries:

--Write a query to list the top 5 models with the highest units sold in each year

with ranked_models as (
    select 
        [Rank],
        [Manufacturer],
        [Model],
        [Year], 
        [Units_Sold__million__],
        DENSE_RANK() over (partition by  [Year] order by [Units_Sold__million__] DESC) as sales_rank
    from 
        [dbo].[top 120 best-selling mobile phones]
)
select 
    [Rank],
    [Manufacturer],
    [Model],
    [Year],
    [Units_Sold__million__],
    sales_rank
from 
    ranked_models
where 
    sales_rank <= 5 
order by 
    [Year] desc,
    sales_rank asc;
-------------------------------------------------------
--Use a CTE to rank manufacturers based on their total units sold and display the top 3.
with manufacture_model as(
select
	[Manufacturer],
	sum([Units_Sold__million__]) as total_units_sold,
	dense_rank() over (order by  sum([Units_Sold__million__]) desc) as Manufacturer_Rank 
from 
	[dbo].[top 120 best-selling mobile phones]
group by 
	[Manufacturer]
)
select
	manufacturer_rank,
	[Manufacturer],
	total_units_sold
from 
	manufacture_model
where
	manufacturer_rank<=3
order by 
	manufacturer_rank asc;
------------------
-- Develop a stored function to calculate the average units sold for a given manufacturer.
create function dbo.fn_GetManufacturerAverageSales
(
    @ManufacturerName NVARCHAR(100)
)
return decimal(10,2)
as
begin
    declare @AverageSales decimal(10,2);

    select 
        @AverageSales = avg([Units_Sold__million__])
    from 
        [dbo].[top 120 best-selling mobile phones]
    where 
        lower([Manufacturer]) = lower(@ManufacturerName);
    return isnull(@AverageSales, 0.00);
end;
go

------------------
select distinct
	[Manufacturer],
	dbo.fn_GetManufacturerAverageSales([Manufacturer]) as  avg_units_sold
from
	[dbo].[top 120 best-selling mobile phones]
order by 
		[Manufacturer] desc
--------------------------
--Advanced SQL Functions:
--Use window functions to calculate the moving average of units sold per manufacturer

with sequenced_sale as(
	select 
		[Rank],
		[Manufacturer],
		[Model],
		[Units_Sold__million__],
	 row_number() over (partition by [Manufacturer] order by [Year] asc,[Units_Sold__million__]desc
  ) as released_sequence
from
	[dbo].[top 120 best-selling mobile phones]
	)
select
	[Rank],
	[Manufacturer],
	[Model],
	[Units_Sold__million__],
	avg([Units_Sold__million__]) over (partition by [Manufacturer] order by released_sequence 
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS [Model_Moving_Avg]
from 
   sequenced_sale
order by 
    [Manufacturer] asc, 
    released_sequence asc;
---------------------
--	Create a trigger to log changes in units sold when a model's details are updated.
create table detailed_info
 (
    [Audit_ID] INT IDENTITY(1,1) primary key,
    [Model_Rank] int,
    [Manufacturer] nvarchar(100),
    [Model] nvarchar(100),
    [Old_Units_Sold] decimal(10,2),
    [New_Units_Sold] decimal(10,2),
    [Change_Amount] decimal(10,2),
    [Updated_By] nvarchar(100) DEFAULT system_user,
    [Updated_At] datetime default getdate()
);
---------------------
create trigger dbo.trg_LogUnitsSoldChanges
on [dbo].[top 120 best-selling mobile phones]
after UPDATE
as
begin
    -- Optimisation: Stop execution early if the units column was not modified
    if NOT update([Units_Sold__million__]) return;

    set nocount on;

    insert into [dbo].[detailed_info]
	 (
        [Model_Rank],
        [Manufacturer],
        [Model],
        [Old_Units_Sold],
        [New_Units_Sold],
        [Change_Amount]
    )
    select 
        i.[Rank],
        i.[Manufacturer],
        i.[Model],
        d.[Units_Sold__million__] as [Old_Units_Sold],
        i.[Units_Sold__million__] as [New_Units_Sold],
        (i.[Units_Sold__million__] - d.[Units_Sold__million__]) as [Change_Amount]
    from 
        inserted i
    INNER JOIN 
        deleted d ON i.[Rank] = d.[Rank] -- Matches rows using your unique table ID/Rank
    where 
        d.[Units_Sold__million__] <> i.[Units_Sold__million__]; -- Logs only actual metric value changes
end;
go
---------------------------------
--  Modify a record in your main dataset
update [dbo].[top 120 best-selling mobile phones]
set [Units_Sold__million__] = 255.0
where [Rank] = 1; 


select * from [dbo].[detailed_info] 


    