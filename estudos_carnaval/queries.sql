with customers as (
select client_user_id 
from business_layer.bookings
where client_user_id in (
      select client_user_id 
      from business_layer.walks
      where status="finished") 
or qty_previous_bookings_from_client>0)
select case 
      when first_message_at between "2020-01-27" and "2020-01-29" then "1 email"
      when first_message_at between "2020-01-30" and "2020-02-02" then "2 email"
      when first_message_at>"2020-02-02" then "3 email"
      else "without email" end as wave,
      count(distinct case when has_converted then client_user_id end)/count(distinct client_user_id) as conversion, 
      count(distinct client_user_id) as interessados
from business_layer.bookings
where checkin_date < "2020-02-25" 
      and checkout_date > "2020-02-21"
      and client_user_id in ( 
          select client_user_id from customers
          )
group  by 1
order by 1

###### conversao por período

with customers as (
select client_user_id 
from business_layer.bookings
where client_user_id in (
      select client_user_id 
      from business_layer.walks
      where status="finished") 
or qty_previous_bookings_from_client>0)
select date(first_message_at) as wave,
      count(distinct case when has_converted then client_user_id end)/count(distinct client_user_id) as conversion, 
      count(distinct client_user_id) as interessados
from business_layer.bookings
where checkin_date < "2020-02-25" 
      and checkout_date > "2020-02-21"
      and client_user_id in ( 
          select client_user_id from customers
          )
      and first_message_at>="2019-11-01"
group  by 1
order by 1

## dia a dia


##################-----------MUERTOS---------------################################################ 

with customers as (
select client_user_id 
from business_layer.bookings
where client_user_id in (
      select client_user_id 
      from business_layer.walks
      where status="finished") 
or qty_previous_bookings_from_client>0),
m1 as(
  select user_id 
  from business_layer.users 
  where sign_up_at<= "2019-12-14"
)
select case 
      when first_message_at between "2020-01-27" and "2020-01-29" then "1 email"
      when first_message_at between "2020-01-30" and "2020-02-02" then "2 email"
      when first_message_at>"2020-02-02" then "3 email"
      when first_message_at between "2019-11-01" and "2020-01-26" then "without email" end as wave,
      count(distinct case when has_converted then client_user_id end)/count(distinct client_user_id) as conversion, 
      count(distinct client_user_id) as interessados,
      count(distinct booking_id) as msg
from business_layer.bookings
where checkin_date < "2020-02-25" 
      and checkout_date > "2020-02-21"
      and client_user_id not in ( select client_user_id from customers )
      and client_user_id in ( select user_id from m1)
      and mod(client_user_id,10)>1
group  by 1
having wave is not null
order by 1

## conversão por período agrupado
with customers as (
select client_user_id 
from business_layer.bookings
where client_user_id in (
      select client_user_id 
      from business_layer.walks
      where status="finished") 
or qty_previous_bookings_from_client>0),
m1 as(
  select user_id 
  from business_layer.users 
  where sign_up_at<= "2019-12-14"
)
select case 
      when first_message_at between "2020-01-27" and "2020-01-29" then "1 email"
      when first_message_at between "2020-01-30" and "2020-02-02" then "2 email"
      when first_message_at>"2020-02-02" then "3 email"
      when first_message_at between "2019-11-01" and "2020-01-26" then "without email" end as wave,
      count(distinct case when has_converted then client_user_id end)/count(distinct client_user_id) as conversion, 
      count(distinct client_user_id) as interessados,
      count(distinct booking_id) as msg
from business_layer.bookings
where checkin_date < "2020-02-25" 
      and checkout_date > "2020-02-21"
      and client_user_id not in ( select client_user_id from customers )
      and client_user_id in ( select user_id from m1)
      and mod(client_user_id,10)>1
group  by 1
having wave is not null
order by 1

## searches

with customers as (
select client_user_id 
from business_layer.bookings
where client_user_id in (
      select client_user_id 
      from business_layer.walks
      where status="finished") 
or qty_previous_bookings_from_client>0),
m1 as(
  select user_id 
  from business_layer.users 
  where sign_up_at<= "2019-12-14"
)
select date( first_page_search_at ) as wave,
count(distinct user_id)
from business_layer.searches
where checkin_date < "2020-02-25" 
      and checkout_date > "2020-02-21"
      and user_id not in ( select client_user_id from customers )
      and user_id in ( select user_id from m1)
      and mod(user_id,10)>1
      and first_page_search_at >="2019-11-01"
      group  by 1
having wave is not null
order by 1
