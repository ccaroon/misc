create table card_deck_assoc (
    card_id     integer     not null,
    deck_id     integer     not null,
    main_copies integer     not null,
    side_copies integer         null
);
