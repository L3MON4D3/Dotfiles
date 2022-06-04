#!/bin/sh
echo "print --pdf '/tmp/$QUTE_TITLE.pdf'" > "$QUTE_FIFO"

export RMAPI_HOST=http://sljk.ddns.net:3000
rmapi put /tmp/"$QUTE_TITLE".pdf /web
