{{ config(materialized='table') }}

select
    owner_acronym,
    count(*)                            as total_contracts,
    round(sum(gen_effective_total_value), 2)  as total_spend,
    round(avg(gen_effective_total_value), 2)  as avg_contract_value,
    min(gen_effective_start_year)       as first_year,
    max(gen_effective_start_year)       as last_year

from {{ ref('query_1') }}

where owner_acronym is not null
  and gen_effective_total_value is not null

group by owner_acronym
order by total_spend desc
