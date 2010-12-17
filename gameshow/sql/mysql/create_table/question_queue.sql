create table question_queue
(
    id           bigint       unsigned not null auto_increment unique,
    question_id  bigint       unsigned not null,
    position     int          unsigned not null
) type=myisam;
