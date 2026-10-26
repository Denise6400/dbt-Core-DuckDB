select
    cast(date_trunc('month', cast(booking_date as date)) as date)
        as booking_month,
    count(*) as passenger_count
from {{ ref('cruise_bookings') }}
group by 1