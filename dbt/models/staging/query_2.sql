{{ config(materialized='view') }}

select
    id,
    json_id,
    owner_acronym,
    vendor_name,
    gen_vendor_clean,
    gen_vendor_normalized,
    contract_value,
    original_value

from {{ ref('stg_raw_data') }} as raw_table

where
    id is not null
    and vendor_name is not null
    and contract_value is not null
    and original_value = 0
    and gen_contract_id is not null
    and gen_is_error != 1
