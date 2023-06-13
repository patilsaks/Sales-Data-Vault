# Data Vault Modeling for Online Retail
This project aims to develop a data vault for online retail database with 2 hubs, 2 satellites and one link using snowflake and dbtvault.

### Data Vault Diagram
<img width="578" alt="Screenshot 2023-06-13 at 1 34 42 AM" src="https://github.com/patilsaks/Sales-Data-Vault/assets/116474692/64d5e88b-c16a-492f-9394-bcd00150a773">

### dbt Project Dag
<img width="1153" alt="Screenshot 2023-06-12 at 11 54 46 PM" src="https://github.com/patilsaks/Sales-Data-Vault/assets/116474692/f8831b8c-c02b-4c95-b643-7350db8a01a1">



### Data Vault Staging Table: v_stg_customer 
```
{%- set yaml_metadata -%}
source_model: 'raw_orders'
derived_columns:
  ORDERS_KEY: 'O_ORDERKEY'
  CUSTOMER_KEY: 'O_CUSTKEY'
  EFFECTIVE_FROM: 'O_ORDERDATE'
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
      - 'O_ORDERPRIORITY'
      - 'O_CLERK'
      - 'O_SHIPPRIORITY'

  CUSTOMER_ORDERS_HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUSTOMER_KEY'
      - 'ORDERS_KEY'
      - 'C_NAME'
      - 'C_ADDRESS'
      - 'C_PHONE'
      - 'C_ACCTBAL'
      - 'C_MKTSEGMENT'
      - 'R_NAME'
      - 'N_NAME'

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
```


### link_orders_customer 
```
{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "LINK_ORDERS_CUSTOMER_PK" -%}
{%- set src_fk = ["ORDERS_PK","CUSTOMER_PK"] -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ dbtvault.link(src_pk=src_pk, src_fk=src_fk, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}
```

### hub_customer
```
{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "CUSTOMER_PK" -%}
{%- set src_nk = "CUSTOMER_KEY" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ dbtvault.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}
```

### sat_customer
```
{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "LINK_ORDERS_CUSTOMER_PK" -%}
{%- set src_hashdiff = "CUSTOMER_ORDERS_HASHDIFF" -%}
{%- set src_payload = ["C_NAME","C_ADDRESS","C_PHONE","C_ACCTBAL","C_MKTSEGMENT","R_NAME","N_NAME"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ dbtvault.sat(src_pk=src_pk, src_hashdiff=src_hashdiff, src_payload=src_payload,
 src_eff=src_eff, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}
 ```

### hub_orders
```
{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "ORDERS_PK" -%}
{%- set src_nk = "ORDERS_KEY" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ dbtvault.hub(src_pk=src_pk, src_nk=src_nk, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}
```

### sat_orders
```
{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "LINK_ORDERS_CUSTOMER_PK" -%}
{%- set src_hashdiff = "ORDERS_CUSTOMER_HASHDIFF" -%}
{%- set src_payload = ["O_ORDERSTATUS","O_TOTALPRICE","O_ORDERDATE","O_ORDERPRIORITY","O_CLERK","O_SHIPPRIORITY"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ dbtvault.sat(src_pk=src_pk, src_hashdiff=src_hashdiff, src_payload=src_payload,
 src_eff=src_eff, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}
 ```


