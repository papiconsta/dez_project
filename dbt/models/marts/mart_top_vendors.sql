{{ config(materialized='table') }}

select
    gen_vendor_normalized,
    count(*)                                  as total_contracts,
    round(sum(gen_effective_total_value), 2)  as total_spend,
    round(avg(gen_effective_total_value), 2)  as avg_contract_value,
    count(distinct owner_acronym)             as num_departments

from {{ ref('query_1') }}

where gen_vendor_normalized is not null
  and gen_effective_total_value is not null

group by gen_vendor_normalized
order by total_spend desc
