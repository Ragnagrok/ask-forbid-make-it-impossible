# Project instructions

## The database

Never delete rows from `orders`. The table is the only record of what each customer paid, and
there is no other copy: if a row goes, the money it describes can't be reconciled anymore.

If you think rows should go, stop and ask.
