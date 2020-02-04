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
