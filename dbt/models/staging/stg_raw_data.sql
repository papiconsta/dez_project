{{ config(materialized='view') }}

select
    id,
    json_id,
    owner_acronym,
    vendor_name,
    gen_vendor_clean,
    gen_vendor_normalized,
    contract_value,
    original_value,
    gen_effective_total_value,
    gen_effective_yearly_value,
    gen_original_value,
    reference_number,
    gen_contract_id,
    raw_contract_date,
    raw_delivery_date,
    raw_contract_period_start,
    raw_contract_period_end,
    gen_start_year,
    gen_end_year,
    gen_effective_start_year,
    gen_effective_end_year,
    description,
    source_year,
    source_quarter,
    source_fiscal,
    source_origin,
    source_csv_filename,
    gen_is_duplicate,
    gen_is_amendment,
    gen_is_most_recent_value,
    gen_is_error,
    cast(row_created_at as timestamp) as row_created_at

from {{ source('staging', 'source_with_metadata') }}

where
    id is not null
    and vendor_name is not null
    and contract_value is not null
    and gen_contract_id is not null
    and gen_is_error != 1
