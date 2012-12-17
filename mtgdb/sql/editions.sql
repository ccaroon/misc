create table editions (
    id           integer         null PRIMARY KEY,
    name         varchar(64) not null,
    code_name    varchar(8)  not null,
    online_code  varchar(32)     null,
    release_date varchar(32) not null,
    card_count   integer     not null
);
