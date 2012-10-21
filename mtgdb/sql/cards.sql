create table cards (
    id          integer          null PRIMARY KEY,
    name        varchar(64)  not null,
    type        varchar(32)  not null,
    sub_type    varchar(32)      null,
    -- eventually 'editions' needs to be split out into another table
    edition_str varchar(256) not null,
    cost        varchar(32)  not null,
    foil        tinyint      not null default 0,
    rarity      varchar(16)  not null,
    count       integer      not null,
    image_name  varchar(64)  not null,
    card_text   text         null
);
