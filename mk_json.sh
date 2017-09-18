#!/bin/bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")"
DIR="$(pwd)"

psql < "import3.sql"
psql < "import4.sql"

