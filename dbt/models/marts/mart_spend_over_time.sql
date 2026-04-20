{{ config(materialized='table') }}

select
    gen_effective_start_year                  as year,
    count(*)                                  as total_contracts,
    round(sum(gen_effective_total_value), 2)  as total_spend,
    round(avg(gen_effective_total_value), 2)  as avg_contract_value,
    count(distinct gen_vendor_normalized)     as unique_vendors,
    count(distinct owner_acronym)             as unique_departments

from {{ ref('query_1') }}

where gen_effective_start_year is not null
  and gen_effective_start_year > 0
  and gen_effective_total_value is not null

group by gen_effective_start_year
order by year
