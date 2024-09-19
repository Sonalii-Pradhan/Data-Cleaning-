#To get an overview of the table
select * from layoffs_tbl;


#Creating a staging table to work on the data 

create table layoff_staging like layoffs_tbl; 

#Inorder to define the each row uniquely
alter table layoff_staging
add rownumber int;

insert  into layoff_staging  select *,row_number() over
(partition by company,industry,total_laid_off,percentage_laid_off,`date`) as rownumber
 from layoffs_tbl;

select * from layoff_staging;

#Removing Duplicate rows

set SQL_SAFE_UPDATES = 0;

delete from layoff_staging
where rownumber > 1;

#converting the data type
# date is stored in text format 

select column_name , Data_type from information_schema.columns where 
table_name = 'layoff_staging';  #to know th data type of diffeent columns

update layoff_staging
set `date` = str_to_date(`date`,'%m/%d/%Y');

select `date` from layoff_staging;
#we have succesfully converted to date format but if we check the datatype hasn't changed yet

alter table layoff_staging
modify column `date` date;


#Lets create one stored procedure
delimiter $$
create procedure All_records()
begin
select * from layoff_staging;
end $$
delimiter ;

#Standardising the data
#removing blank space if any

call All_records();

update layoff_staging
set company = trim(company);

# If we analyse the data will get to know that 'crypto' is also named as crypto_currency in one field then
 #same company is defined in two different industry name thus we will correct the data

select l1.company , l1.industry ,l2.industry from layoff_staging l1 join layoff_staging l2 on  l1.company = l2.company;


select company,industry from layoff_staging where industry like 'crypto%';
select distinct(company) ,industry from layoff_staging;


update layoff_staging
set industry = 'crypto'
where industry like 'crypto%';

update layoff_staging
set industry = 'Retail'
where company = '100 Thieves';

select distinct(country) from layoff_staging;
#United_States is differentiated with United_States.(dot at end) will fix that

Select distinct(country) ,trim(trailing '.' from country) from layoff_staging;

#Handling Null or Blank Spaces

call All_records();

select * from layoff_staging where  industry is null or industry ='';
select company ,industry from layoff_staging where company = 'Airbnb';

#Now will try to fill th blank space as we have similar data

update layoff_staging
set industry = null
where industry = '';

update layoff_staging l1
join layoff_staging l2
on l1.company = l2.company
set l1.industry = l2.industry
where l1.industry is null and l2.industry is not null;

#As Bally's Interactive company is a unique data thus value is not updated

call All_records;

#Now will drop those row which we feel is irrelevant or has data insufficiency
#we have updated all the blank space with null values

select count(*) from layoff_staging where total_laid_off is null and percentage_laid_off is null and funds_raised_millions is null;
#If we have permit or scence that these insufficient data add no value to the insights than these records can be removed 

delete from layoff_staging
where total_laid_off is null 
and percentage_laid_off is null
and funds_raised_millions is null;

alter table layoff_staging
drop column rownumber;


















