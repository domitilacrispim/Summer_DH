OKR 1: 2460

with jan_2020 as
(SELECT client_user_id as cliente, min(finished_at) as data 
FROM `belka-dh.business_layer.walks`
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(finished_at) as data
from business_layer.daycare
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
FROM business_layer.pet_sitting
where status in ( "confirmed", "finished") 
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
from business_layer.bookings
where has_converted 
and country="bra"
group by 1 
), 
min_data as(
select cliente, min(data) as data
from jan_2020
group by cliente
)
select count(distinct cliente) as qty_new_client
from min_data
where data >="2020-01-01" 

OKR 2: 1598

with jan_2020 as
(SELECT client_user_id as cliente, min(finished_at) as data 
FROM `belka-dh.business_layer.walks`
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(finished_at) as data
from business_layer.daycare
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
FROM business_layer.pet_sitting
where status in ( "confirmed", "finished") 
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
from business_layer.bookings
where has_converted 
and country="bra"
group by 1 
), 
min_data as(
select cliente, min(data) as data
from jan_2020
group by cliente
), 
m0 as(
 select cliente, data
 from min_data
 inner join business_layer.users u on cliente=u.user_id
 where date_diff( date(data), date(u.sign_up_at), Day)<=30 
 and data>="2020-01-01"

)
 select count(distinct cliente) as qty_new_client
 from m0

OKR 3: 862
with jan_2020 as
(SELECT client_user_id as cliente, min(finished_at) as data 
FROM `belka-dh.business_layer.walks`
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(finished_at) as data
from business_layer.daycare
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
FROM business_layer.pet_sitting
where status in ( "confirmed", "finished") 
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
from business_layer.bookings
where has_converted 
and country="bra"
group by 1 
), 
min_data as(
select cliente, min(data) as data
from jan_2020
group by cliente
), 
m1mais as(
 select cliente, data
 from min_data
 inner join business_layer.users u on cliente=u.user_id
 where date_diff( date(data), date(u.sign_up_at), Day)>30
 and data>="2020-01-01"

)
 select count(distinct cliente) as qty_new_client
 from m1mais

OKR 4: 189

with jan_2020 as
(SELECT client_user_id as cliente, min(finished_at) as data 
FROM `belka-dh.business_layer.walks`
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(finished_at) as data
from business_layer.daycare
where status = "finished"
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
FROM business_layer.pet_sitting
where status in ( "confirmed", "finished") 
group by 1
UNION ALL
SELECT client_user_id as cliente, min(payment_verified_at) as data
from business_layer.bookings
where has_converted 
and country="bra"
group by 1 
)
select count(distinct j2.cliente) as servico_2 from jan_2020 j2
join jan_2020 j1 on j1.cliente=j2.cliente
where j1.data>="2020-01-01" and j2.data<j1.data

OKR 6: 3.58%

with base as (
  select
    visitor_id,
    user_id,
    list_id,
    date(event_at) as date,
    format_date('%Y-%W', date(event_at)) as s_date,
    event_at,
    event_name,
    case when event_name in ('search', 'view_search') then 'search'
         when event_name in ('view_list', 'view_hero_list') then 'view'
         when event_name in ('click_through_rate_sort') then 'ctr'
    end as event_type,
    ST_GEOGPOINT(longitude_search, latitude_search) as my_point
  from `belka-dh.int_layer.events_info`
  where 
    event_name in ('search', 'view_search', 'view_list', 'view_hero_list', 'click_through_rate_sort')
    and date(event_at) between '2018-06-01' and current_date()
),
searches_base as (
  select
    sb.*,
    nb.NAME_1 as state,
    nb.NAME_2 as city,
    nb.NAME_3 as neighborhood,
    nb.geom
  from
    base sb, `strelka.diva_gis.neighborhoods_bra` nb
  where
    ST_DWITHIN(sb.my_point, ST_GeogFromGeoJSON(nb.geom), 0)
    and event_type = 'search'
),
searches as (
  select *
  from searches_base
  where event_type = 'search'
),
clicks as (
  select *
  from base
  where event_type = 'ctr'
),
views as (
  select *
  from base
  where event_type = 'view'
),
bookings as (
  select
    client_user_id a s user_id,
    list_id,
    first_message_at,
    booking_status,
    has_converted,
    date(first_message_at) as date
  from `belka-dh.business_layer.bookings` 
),
pet_sittings as (
  select
    client_user_id as user_id,
    list_id,
    created_at,
    order_status,
    status,
    date(created_at) as date
  from
    `belka-dh.business_layer.pet_sitting` 
),
daycares as (
  select
    d.client_user_id as user_id,
    l.id as list_id,
    first_message_at,
    date(first_message_at) as date,
    d.status,
    case when d.status in ('started', 'finished', 'confirmed') then true else false end as has_converted
  from
    `belka-dh.business_layer.daycare` d
  left join
    `strelka.petstay.list` l on l.user_id = d.host_user_id
), 
counts as (
  select
    --    count(*) as qty_searches,
    count(distinct s.visitor_id) as qty_searchers,
    count(distinct s.user_id) as qty_logged_searchers,
    count(distinct v.visitor_id) as qty_views,
    count(distinct c.visitor_id) as qty_clicks,
    count(distinct case when b.booking_status != 'pre_requested' then b.user_id end) as qty_messages_b,
    count(distinct case when ps.status != 'pre_requested' then ps.user_id end) as qty_messages_ps,
    count(distinct d.user_id) as qty_messages_d,
    count(distinct case when b.booking_status != 'pre_requested' or ps.status != 'pre_requested' or d.user_id is not null then s.user_id end) as qty_messages,
    count(distinct case when ps.status in ('finished', 'confirmed', 'started') then ps.user_id end) as qty_pet_sittings,
    count(distinct case when d.has_converted is true then d.user_id end) as qty_daycares,
    count(distinct case when b.has_converted is true then b.user_id end) as qty_reservations,
    count(distinct case when b.has_converted is true or ps.status in ('finished', 'confirmed', 'started') or d.has_converted is true then s.user_id end) as qty_bookings,
    s.date,
--     s.city,
--     s.state,
    row_number() over(order by s.date) as rown
  from 
    searches s
  left join 
    clicks c on c.visitor_id = s.visitor_id and c.event_at between s.event_at and timestamp_add(s.event_at, interval 1 hour)
  left join 
    views v on v.visitor_id = c.visitor_id and v.event_at between c.event_at and timestamp_add(c.event_at, interval 10 minute)
  left join 
    bookings b on b.user_id = v.user_id and b.list_id = v.list_id and b.first_message_at between v.event_at and timestamp_add(v.event_at, interval 5 day) 
  left join 
    pet_sittings ps on ps.user_id = v.user_id and ps.list_id = v.list_id and ps.created_at between v.event_at and timestamp_add(v.event_at, interval 5 day) 
  left join
    daycares d on d.user_id = v.user_id and d.list_id = v.list_id and d.first_message_at between v.event_at and timestamp_add(v.event_at, interval 5 day)
  where 
    (s.state = 'São Paulo' and s.city = 'São Paulo')
    or (s.state = 'Rio de Janeiro' and s.city = 'Rio de Janeiro')
  group by date -- , city, state
)
select
  c.qty_searchers,
  c.qty_logged_searchers,
  c.qty_clicks,
  c.qty_views,
  c.qty_messages_b,
  c.qty_messages_d,
  c.qty_messages_ps,
  c.qty_messages,
  c.qty_bookings,
  c.qty_reservations,
  c.qty_pet_sittings,
  c.qty_daycares,
  c.qty_bookings/c.qty_searchers as search2book,
  c.qty_messages/c.qty_searchers as search2message,
  c.qty_views/c.qty_searchers as search2view,
  c.qty_clicks/c.qty_searchers as search2click,
  c.date,
  d.year_week
--   c.city,
--   c.state
from counts c
left join `belka-dh.support.dates` d using(date)
where c.date>="2020-01-01"
order by c.date desc

OKR 7: 0.5247

select count(distinct case when status_CS="finished" then walk_id end)/count(distinct walk_id) as CS
from business_layer.walks
where is_valid_for_CS_analysis is true and 
scheduled_at between "2020-01-01" and "2020-01-21"
and city in ( "sao paulo" , "rio de janeiro")

OKR 8: 0.4073

select count(distinct case when status_CS="finished" then walk_id end)/count(distinct walk_id) as CS
from business_layer.walks
where is_valid_for_CS_analysis is true and 
scheduled_at between "2020-01-01" and "2020-01-21"
and city not in ( "sao paulo" , "rio de janeiro")
