{{ config(materialized='view') }}

with filtered_records as (

    select *
    from {{ ref('query_2') }}

)

select count(*) as total_records
from filtered_records