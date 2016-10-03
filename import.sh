#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
DIR="$(pwd)"

make all
rm -f dbs/*.*
etc/mkdb -movie   # Movies

# Filmographies (NO_OF_FILMOGRAPHY_LISTS):
etc/mkdb -acr     # Actors
etc/mkdb -acs     # Actresses
etc/mkdb -cine    # Cinematographers
etc/mkdb -comp    # Composers
etc/mkdb -dir     # Directors
etc/mkdb -write   # Writers
etc/mkdb -edit    # Editors
etc/mkdb -prodes  # Production Designers
etc/mkdb -costdes # Costume Designers
etc/mkdb -prdcr   # Producers
etc/mkdb -misc    # Miscellaneous

# Title info (NO_OF_TITLE_INFO_LISTS):
etc/mkdb -time    # Running Times
etc/mkdb -cert    # Certificates
etc/mkdb -genre   # Genres
etc/mkdb -keyword # Keywords
etc/mkdb -prodco  # Production Company
etc/mkdb -dist    # Distributors
etc/mkdb -color   # Color Information
etc/mkdb -mix     # Sound Mix
etc/mkdb -cntry   # Country
etc/mkdb -rel     # Release Dates
etc/mkdb -loc     # Locations
etc/mkdb -tech    # Technical
etc/mkdb -lang    # Languages
etc/mkdb -sfxco   # Special Effects Company

#etc/mkdb -aka     # Aka Titles -- FIXME currently broken
#etc/mkdb -naka    # Aka Names -- FIXME currently broken
#etc/mkdb -plot    # Plot Summaries
#etc/mkdb -bio     # Biographies -- FIXME currently broken
#etc/mkdb -crazy   # Crazy Credits
#etc/mkdb -goof    # Goofs
#etc/mkdb -quote   # Quotes
#etc/mkdb -triv    # Trivia
#etc/mkdb -mrr     # Movie Ratings -- FIXME currently broken
#etc/mkdb -lit     # Literature -- FIXME currently broken
#etc/mkdb -link    # Movie Links
#etc/mkdb -tag     # Tag Lines
#etc/mkdb -castcom # Cast Completion
#etc/mkdb -crewcom # Crew Completion
#etc/mkdb -vers    # Alternate Versions
#etc/mkdb -bus     # Business -- FIXME currently broken
#etc/mkdb -ld      # LaserDisc

etc/mkdb -create

psql < "import1.sql"

(
    echo "copy top_titles (title)            from '$DIR/top_titles.txt'     (format text, encoding 'utf-8');"
    echo "copy titles     (title, hexid)     from '$DIR/dbs/titles.key'     (format text, delimiter '|', encoding 'iso-8859-1');"
    echo "copy names      (name, hexid)      from '$DIR/dbs/names.key'      (format text, delimiter '|', encoding 'iso-8859-1');"
    echo "copy attributes (attribute, hexid) from '$DIR/dbs/attributes.key' (format text, delimiter '|', encoding 'iso-8859-1');"
    echo "copy movies_raw (id, year_from, year_to, attr_id) from '$DIR/dbs/movies.tsv';"
    echo "copy actors                    from '$DIR/dbs/actors.tsv'    (format text, encoding 'iso-8859-1');"
    echo "copy actresses                 from '$DIR/dbs/actresses.tsv' (format text, encoding 'iso-8859-1');"
    echo "copy cinematographers          from '$DIR/dbs/cinematographers.tsv';"
    echo "copy composers                 from '$DIR/dbs/composers.tsv';"
    echo "copy costume_designers         from '$DIR/dbs/costume-designers.tsv';"
    echo "copy directors                 from '$DIR/dbs/directors.tsv';"
    echo "copy editors                   from '$DIR/dbs/editors.tsv';"
    echo "copy miscellaneous             from '$DIR/dbs/miscellaneous.tsv';"
    echo "copy producers                 from '$DIR/dbs/producers.tsv';"
    echo "copy production_designers      from '$DIR/dbs/production-designers.tsv';"
    echo "copy writers                   from '$DIR/dbs/writers.tsv';"
    echo "copy certificates              from '$DIR/dbs/certificates.tsv'              (format text, encoding 'iso-8859-1');"
    echo "copy color_info                from '$DIR/dbs/color-info.tsv'                (format text, encoding 'iso-8859-1');"
    echo "copy countries                 from '$DIR/dbs/countries.tsv'                 (format text, encoding 'iso-8859-1');"
    echo "copy distributors              from '$DIR/dbs/distributors.tsv'              (format text, encoding 'iso-8859-1');"
    echo "copy genres                    from '$DIR/dbs/genres.tsv'                    (format text, encoding 'iso-8859-1');"
    echo "copy keywords                  from '$DIR/dbs/keywords.tsv'                  (format text, encoding 'iso-8859-1');"
    echo "copy language                  from '$DIR/dbs/language.tsv'                  (format text, encoding 'iso-8859-1');"
    echo "copy locations                 from '$DIR/dbs/locations.tsv'                 (format text, encoding 'iso-8859-1');"
    echo "copy production_companies      from '$DIR/dbs/production-companies.tsv'      (format text, encoding 'iso-8859-1');"
    echo "copy release_dates             from '$DIR/dbs/release-dates.tsv'             (format text, encoding 'iso-8859-1');"
    echo "copy running_times             from '$DIR/dbs/running-times.tsv'             (format text, encoding 'iso-8859-1');"
    echo "copy sound_mix                 from '$DIR/dbs/sound-mix.tsv'                 (format text, encoding 'iso-8859-1');"
    echo "copy special_effects_companies from '$DIR/dbs/special-effects-companies.tsv' (format text, encoding 'iso-8859-1');"
    echo "copy technical                 from '$DIR/dbs/technical.tsv'                 (format text, encoding 'iso-8859-1');"
) | psql

psql < "import2.sql"
psql < "import3.sql"
psql < "import4.sql"

# The backslash madness simply replaces two backslashes in the data by one (to undo
# the escaping added by Postgres in the text output format). Here we have to write
# eight backslashes because the command goes through three levels of un-escaping:
# 1. in the shell running this script,
# 2. in the psql command interpreter,
# 3. in the shell invoked by Postgres to execute the output command.
echo "copy movies_doc to program 'sed -e "s/\\\\\\\\\\\\\\\\/\\\\\\\\/g" | gzip > $DIR/movies_doc.json.gz' encoding 'utf-8';" | psql
echo "copy people_doc to program 'sed -e "s/\\\\\\\\\\\\\\\\/\\\\\\\\/g" | gzip > $DIR/people_doc.json.gz' encoding 'utf-8';" | psql
echo "copy movies_doc_small to program 'sed -e "s/\\\\\\\\\\\\\\\\/\\\\\\\\/g" | gzip > $DIR/movies_doc_small.json.gz' encoding 'utf-8';" | psql
echo "copy people_doc_small to program 'sed -e "s/\\\\\\\\\\\\\\\\/\\\\\\\\/g" | gzip > $DIR/people_doc_small.json.gz' encoding 'utf-8';" | psql
