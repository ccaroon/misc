create table contestant
(
    id          bigint       unsigned not null auto_increment unique,
    name        varchar(255) not null unique,
    score       int          not null default 0
) type=myisam;
