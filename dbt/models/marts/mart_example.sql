{{ config(materialized='table') }}

select *
from {{ ref('stg_raw_data') }}
