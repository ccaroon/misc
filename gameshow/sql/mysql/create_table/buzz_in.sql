create table buzz_in
(
    id             bigint       unsigned not null auto_increment unique,
    question_id    bigint       unsigned not null,
    contestant_id  bigint       unsigned not null,
    buzz_in_date   datetime     not null,
    answer         text         not null
) type=myisam;
