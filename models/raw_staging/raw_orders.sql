with final as(

    select * from {{ source('snow', 'orders') }}
    left join {{ source('snow', 'customer') }}
    on o_custkey = c_custkey
)

select * from final