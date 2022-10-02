Create schema pj02
Select * from sale

-- Đổi kiểu dữ liệu thời gian 
ALter table sale 
Drop column new_date 

Alter table sale
Add new_date date;
SET SQL_SAFE_UPDATES = 0;
UPDATE sale
Set new_date = STR_TO_DATE (date,'%m/%d/%Y')

-- Kiểm tra duplicate value 
With checktable as 
(select *, row_number() over (partition by branch, customer_type, gender, product_line, unit_price, quantity, new_date, payment, rating order by ID) as rownum
from sale)

select * 
from checktable 
where rownum > 1

-- Tách dữ liệu năm 
Alter table sale
Add year_added year;
SET SQL_SAFE_UPDATES = 0;
UPDATE sale
Set year_added  =  Year (new_date) ;

-- Doanh thu, lợi nhuận theo thời gian của từng chi nhánh 
Select branch, new_date, total as revenue, gross_income
from sale
order by branch, new_date

-- Loại hàng hóa và số lượng hàng hóa được mua bởi nam và nữ 
select gender, product_line, sum(quantity) as total_quantity 
from sale 
group by gender, product_line

-- Tác động của loại khách hàng và số lượng hàng mua đến rating 
select customer_type, round(avg(rating),2) as rating , sum(quantity) as total_quantity
from sale 
group by customer_type 

-- Phương tiện thanh toán của mỗi chi nhánh 
select branch, payment, sum(quantity) as total_quantity
from sale 
group by branch, payment

-- Tính tổng doanh thu cộng dồn cho đến ngày bất kì 
with rollingtotal as (
select branch, new_date, sum(total) over ( partition by branch order by new_date) as rolling_revenue
from sale 
order by branch, new_date )

select branch, new_date, rolling_revenue
from rollingtotal 
group by branch, new_date

-- Tính bình quân trượt của thu nhập của chi nhánh A

with rollingtotal as (
select branch, new_date, round(sum(total) over ( partition by branch, new_date ),2) as revenue
from sale 
order by branch, new_date )

select branch, new_date , revenue , round(avg(revenue) over (partition by branch order by new_date rows between 7 preceding and 7 following) ,2) as moving_average_of_15_days
from rollingtotal 
where branch = "A"
group by branch, new_date
order by branch, new_date 































