create table card_deck_assoc (
    card_id integer     not null,
    deck_id integer     not null,
    copies_main integer not null,
    copies_side integer     null
);
