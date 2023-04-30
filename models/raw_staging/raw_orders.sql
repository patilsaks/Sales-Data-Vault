with final as(

    select * from {{ source('snow', 'orders') }}
    left join {{ source('snow', 'customer') }}
    on o_custkey = c_custkey
    left join {{ source('snow', 'nation') }}
    on c_nationkey = n_nationkey
    left join {{ source('snow', 'region') }}
    on n_regionkey = r_regionkey

)

select * from final