#!/bin/bash

script_dir=$(dirname $0)
pushd "$script_dir/../" > /dev/null
project_dir=$(pwd -P)
popd > /dev/null
local_lib="$project_dir/local"

function ensure_we_have_cpanm_ll() {
    attempt=$1
    if [ "$attempt" == "2" ]; then
        echo "Install failed!"
        exit 1
    fi
    echo 'ensuring we have local::lib and cpanminus'
    try_load_local_lib=`perl -I"$local_lib/lib/perl5" -Mlocal::lib="$local_lib" 2>/dev/null`
    if [ $? -eq 0 ]; then
        eval $try_load_local_lib
    else
        curl -L https://cpanmin.us | perl - -l "$local_lib" "App::cpanminus" "local::lib"
        let "attempt++"
        ensure_we_have_cpanm_ll $attempt
    fi
}

function install_dependencies() {
    echo 'installing dependencies'
    # local lib variables already exported at this point, so it installs to
    # $local_lib
    cpanm --installdeps $project_dir
}

function install_database() {
    echo 'installing database'
    dbicadmin -Ilib --deploy --connect-info dsn="dbi:SQLite:dbname=$project_dir/db.sqlite"\
        --schema-class PearlBee::Model::Schema --sql-type SQLite
    # TODO: Run inserts
}

ensure_we_have_cpanm_ll;
install_dependencies;
install_database;
