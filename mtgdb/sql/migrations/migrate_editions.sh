bin/db_shell.sh < sql/editions.sql
bin/db_shell.sh < sql/card_edition_assoc.sql
bin/db_shell.sh < sql/populate/editions.sql
bin/mtgdb.pl utils migrate_editions
bin/db_shell.sh < sql/migrations/20121219205700_cards_drop_column_edition_str.sql
