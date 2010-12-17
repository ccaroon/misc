create table question
(
    id          bigint       unsigned not null auto_increment unique,
    question    text         not null,
    answer      text         not null,
    used        tinyint      not null default 0
) type=myisam;
