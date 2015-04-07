#!/usr/bin/env bash

export LC_ALL=C

geonames_dir=`dirname "$0"`
places_path=download.geonames.org/export/dump
postal_path=download.geonames.org/export/zip

cd $geonames_dir
pwd
mkdir -p orig rawd

cd $geonames_dir/orig
echo "Fetching places data"
wget -nv -N  -np -r -l2 --reject '??.zip' http://download.geonames.org/export/dump/
wget -nv -nc -np -x http://download.geonames.org/export/dump/US.zip
echo "Fetching postal code data"
wget -nv -N -np -r -l2 --reject '??.zip,GB_full.csv.zip' http://download.geonames.org/export/zip/

cd ../rawd
echo "Unzipping places into raw data directory"
for file in allCountries.zip US.zip alternateNames.zip cities15000.zip hierarchy.zip shapes_simplified_low.json.zip userTags.zip ; do
  path="../orig/$places_path/$file"
  echo "unzipping $path"
  yes | unzip -u "$path"
done

gsplit -C 50001000 --numeric-suffixes --additional-suffix=.tsv US.txt             places-us-
gsplit -C 50002000 --numeric-suffixes --additional-suffix=.tsv allCountries.txt   places-all-
gsplit -C 50001000 --numeric-suffixes --additional-suffix=.tsv alternateNames.txt alternate_names-
rm US.txt alternateNames.txt allCountries.txt geonames_places-us.tsv

echo "Unzipping postal codes into raw data directory"
yes | unzip -u ../orig/$postal_path/allCountries.zip

echo "Copying small files into raw data directory"
cp ../orig/$places_path/*.txt ./
cp ../orig/$postal_path/*.txt ./
cp ../orig/$places_path/index.html ./
cp ../orig/$postal_path/index.html ./

gsplit -C 50001000 --numeric-suffixes --additional-suffix=.tsv allCountries.txt postal-all-
rm allCountries.txt 

ls -lh
