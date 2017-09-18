#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
DIR="$(pwd)"

# Replace two backslashes in the data by one (to undo
# the escaping added by Postgres in the text output format).
#
# For robustness, use STDOUT rather thatn "program" to avoid problems
# with file writing permissions an backslah madness. 
echo "copy movies_doc to STDOUT encoding 'utf-8';" | psql | sed -e 's/\\\\/\\/g' | gzip > $DIR/movies_doc.json.gz
echo "copy people_doc to STDOUT encoding 'utf-8';" | psql | sed -e 's/\\\\/\\/g' | gzip > $DIR/people_doc.json.gz
