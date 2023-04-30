{%- set source_model = "v_stg_customer" -%}
{%- set src_pk = "LINK_ORDERS_CUSTOMER_PK" -%}
{%- set src_hashdiff = "CUSTOMER_ORDERS_HASHDIFF" -%}
{%- set src_payload = ["C_NAME","C_ADDRESS","C_PHONE","C_ACCTBAL","C_MKTSEGMENT","R_NAME","N_NAME"] -%}
{%- set src_eff = "EFFECTIVE_FROM" -%}
{%- set src_ldts = "LOAD_DATE" -%}
{%- set src_source = "RECORD_SOURCE" -%}

{{ dbtvault.sat(src_pk=src_pk, src_hashdiff=src_hashdiff, src_payload=src_payload,
 src_eff=src_eff, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}

