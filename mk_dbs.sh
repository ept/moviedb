#!/bin/bash

set -e

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
#etc/mkdb -prodes  # Production Designers
etc/mkdb -costdes # Costume Designers
etc/mkdb -prdcr   # Producers
#etc/mkdb -misc    # Miscellaneous

# Title info (NO_OF_TITLE_INFO_LISTS):
#etc/mkdb -time    # Running Times
etc/mkdb -cert    # Certificates
etc/mkdb -genre   # Genres
etc/mkdb -keyword # Keywords
#etc/mkdb -prodco  # Production Company
#etc/mkdb -dist    # Distributors
#etc/mkdb -color   # Color Information
#etc/mkdb -mix     # Sound Mix
etc/mkdb -cntry   # Country
etc/mkdb -rel     # Release Dates
etc/mkdb -loc     # Locations
#etc/mkdb -tech    # Technical
etc/mkdb -lang    # Languages
#etc/mkdb -sfxco   # Special Effects Company
etc/mkdb -tag     # Tag Lines
#etc/mkdb -crazy   # Crazy Credits

#etc/mkdb -aka     # Aka Titles -- FIXME currently broken
#etc/mkdb -naka    # Aka Names -- FIXME currently broken
#etc/mkdb -plot    # Plot Summaries
#etc/mkdb -bio     # Biographies -- FIXME currently broken
#etc/mkdb -goof    # Goofs
#etc/mkdb -quote   # Quotes
#etc/mkdb -triv    # Trivia
#etc/mkdb -mrr     # Movie Ratings -- FIXME currently broken
#etc/mkdb -lit     # Literature -- FIXME currently broken
#etc/mkdb -link    # Movie Links
#etc/mkdb -castcom # Cast Completion
#etc/mkdb -crewcom # Crew Completion
#etc/mkdb -vers    # Alternate Versions
#etc/mkdb -bus     # Business -- FIXME currently broken
#etc/mkdb -ld      # LaserDisc

etc/mkdb -create

