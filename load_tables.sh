#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
DIR="$(pwd)"

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
#   echo "copy miscellaneous             from '$DIR/dbs/miscellaneous.tsv';"
    echo "copy producers                 from '$DIR/dbs/producers.tsv';"
#   echo "copy production_designers      from '$DIR/dbs/production-designers.tsv';"
    echo "copy writers                   from '$DIR/dbs/writers.tsv';"
    echo "copy certificates              from '$DIR/dbs/certificates.tsv'              (format text, encoding 'iso-8859-1');"
#   echo "copy color_info                from '$DIR/dbs/color-info.tsv'                (format text, encoding 'iso-8859-1');"
    echo "copy countries                 from '$DIR/dbs/countries.tsv'                 (format text, encoding 'iso-8859-1');"
#   echo "copy distributors              from '$DIR/dbs/distributors.tsv'              (format text, encoding 'iso-8859-1');"
    echo "copy genres                    from '$DIR/dbs/genres.tsv'                    (format text, encoding 'iso-8859-1');"
    echo "copy keywords                  from '$DIR/dbs/keywords.tsv'                  (format text, encoding 'iso-8859-1');"
    echo "copy language                  from '$DIR/dbs/language.tsv'                  (format text, encoding 'iso-8859-1');"
    echo "copy locations                 from '$DIR/dbs/locations.tsv'                 (format text, encoding 'iso-8859-1');"
#   echo "copy production_companies      from '$DIR/dbs/production-companies.tsv'      (format text, encoding 'iso-8859-1');"
    echo "copy release_dates             from '$DIR/dbs/release-dates.tsv'             (format text, encoding 'iso-8859-1');"
#   echo "copy running_times             from '$DIR/dbs/running-times.tsv'             (format text, encoding 'iso-8859-1');"
#   echo "copy sound_mix                 from '$DIR/dbs/sound-mix.tsv'                 (format text, encoding 'iso-8859-1');"
#   echo "copy special_effects_companies from '$DIR/dbs/special-effects-companies.tsv' (format text, encoding 'iso-8859-1');"
#   echo "copy technical                 from '$DIR/dbs/technical.tsv'                 (format text, encoding 'iso-8859-1');"
) | psql

