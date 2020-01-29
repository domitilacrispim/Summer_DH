Mês a Mês searchs top 10/9 bairros SP e RJ:

CREATE TEMP FUNCTION CLEANING(field STRING) as 
--tirando acentos das strings
(
  case
    WHEN REGEXP_CONTAINS(trim(lower(field)), r'[àáâãäåæçèéêëìíîïòóôöøùúûüÿœ]') THEN
        REGEXP_REPLACE(
          REGEXP_REPLACE(
            REGEXP_REPLACE(
              REGEXP_REPLACE(
                REGEXP_REPLACE(
                  REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(trim(lower(field)), 'œ', 'ce'), 'ÿ', 'y'), 'ç', 'c'), 'æ', 'ae'),'ñ','n'),"'"," "),"-d"," d"),"'o","o"),"•",""),
                r'[ùúûü]', 'u'),
              r'[òóôöø]', 'o'),
            r'[ìíîï]', 'i'),
          r'[èéêë]', 'e'),
        r'[àáâäåã]', 'a')   
    ELSE
      trim(lower(field))
    end
);
with top_rj  as (
select neighborhood,
count(distinct client_user_id)
from business_layer.bookings
where city = "rio de janeiro"
and first_message_at between "2019-01-01" and "2019-11-30"
and booking_status <> "pre_requested"
group by 1
order  by 2 desc
limit 10),
rj as 
(select geom , nm_bairro
from  strelka.ibge.geojson_bairros
where  lower(nm_distrit) = 'rio de janeiro' 
and cleaning(lower(nm_bairro))  in (select  neighborhood from top_rj)
),

top_sp as(select 
cleaning(neighborhood) as neighborhood,
count(distinct client_user_id)
from business_layer.bookings
where city = "sao paulo"
and booking_status <> "pre_requested"
and first_message_at between "2019-01-01" and "2019-11-30"
group by 1
order  by 2 desc
limit 10
),

intermedio as 
(select geom , 
case when cleaning(lower(NM_distrit)) LIKE "consola%" then "consolacao" 
else cleaning(NM_distrit)
end as NM_distrit
from  strelka.ibge.geojson_bairros
where  lower(nm_municip) = 'são paulo'),
sp as( select * from intermedio
where cleaning(lower(NM_distrit)) in (select lower(neighborhood) from top_sp)
)


select extract ( month from first_page_search_date) as mes, 
count(distinct visitor_id) as searchers,
case when lower(s.nm_distrit) in (select cleaning(neighborhood) from top_sp) then "SP" end as city,
  lower(s.nm_distrit) as bairro
from `business_layer.searches` , sp s
where first_page_search_date between '2019-01-01' and "2019-11-30"
and checkin_date < '2019-12-20' 
and  ST_COVEREDBY(st_geogpoint(longitude_search,latitude_search), s.geom) is true 
group by 1, 3, 4
having city is not null
UNION ALL
select extract ( month from first_page_search_date) as mes, 
count(distinct visitor_id) as searchers,
case when cleaning(lower(r.nm_bairro)) in (select neighborhood from top_rj) then "RJ" end as city,
  lower(r.nm_bairro) as bairro
from `business_layer.searches` ,  rj r
where first_page_search_date between '2019-01-01' and "2019-11-30"
and checkin_date < '2019-12-20' 
and  ST_COVEREDBY(st_geogpoint(longitude_search,latitude_search), r.geom) is true 
group by 1, 3, 4
having city is not null
order by 1 asc

