{%- set yaml_metadata -%}
source_model: 'raw_orders'
derived_columns:
  ORDERS_KEY: 'O_ORDERKEY'
  CUSTOMER_KEY: 'O_CUSTKEY'
  RECORD_SOURCE: '!SNOW-ORDERS'
hashed_columns:
  ORDERS_PK: 'ORDERS_KEY'
  CUSTOMER_PK: 'CUSTOMER_KEY'
 
  LINK_ORDERS_CUSTOMER_PK:
   - 'ORDERS_KEY'
   - 'CUSTOMER_KEY'

  ORDERS_CUSTOMER_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ORDERS_KEY'
      - 'CUSTOMER_KEY'
      - 'O_ORDERSTATUS'
      - 'O_TOTALPRICE'
      - 'O_ORDERDATE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{% set source_model = metadata_dict['source_model'] %}

{% set derived_columns = metadata_dict['derived_columns'] %}

{% set hashed_columns = metadata_dict['hashed_columns'] %}

WITH staging AS (
{{ dbtvault.stage(include_source_columns=true,
                  source_model=source_model,
                  derived_columns=derived_columns,
                  hashed_columns=hashed_columns,
                  ranked_columns=none) }}
)

SELECT *,
       current_timestamp() AS LOAD_DATE
FROM staging