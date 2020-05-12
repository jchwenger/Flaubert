#!/bin/bash
# Copyright 2020 Jérémie Wenger
# jeremie.wenger@gmail.com

# Downloading all publicly available French corpora for FlauBERT one after the other
# (going from smallest to largest)

set -e

# Check number of arguments
if [ $# -ge 1 ]
then
    echo "-------------------------------------"
    echo "Downloading all publicly available French corpora for FlauBERT one after the other"
    echo "(The raw versions, going from smallest to largest.)"
    echo "see Table 10 here: https://arxiv.org/pdf/1912.05372.pdf"
    echo "see references for the Opus api used in this script here:"
    echo "http://opus.nlpl.eu/opusapi"
    echo "-------------------------------------"
else
    echo ""
    echo "Usage:"
    echo "------"
    echo "        ./download_all.sh <data_dir>"
    echo ""
    echo "The script targets the most recent wiki dumps, see here:"
    echo "https://dumps.wikimedia.org/other/cirrussearch/current/"
    echo ""
    echo "Please refer to download.sh for details."
    echo ""
    exit 1
fi

DATA_DIR=$1
# curl the "current" page silently, extract the date
DUMP_DATE=$(curl -s https://dumps.wikimedia.org/other/cirrussearch/current/ | grep -Po "(?<=-)[0-9]{8}(?=-)" | uniq)

# utils
#------

echo_sep() {
  echo ""
  echo "--------------------------------------------------------------------------"
}

get_length() {
  local l=$(expr length "$*")
  echo $l
}

underline() {
  local i=0
  local s=""
  while [ $i -lt $1 ]
  do
    s="${s}-"
    i=$(($i+1))
  done
  echo $s
}

echo_underlined() {
  local msg=$1
  echo $1
  underline $(get_length $msg)
}

# note on json
#-------------
# The "mono" versions of the api yield the tokenized version of the text in
# position 0 of the array and the plain text in position 1.
# Using jq to deal with json api information, try this to see it:
# curl "http://opus.nlpl.eu/opusapi/?corpus=GlobalVoices&source=fr&preprocessing=mono&version=latest"
# {
#   "corpora": [
#   {
#     ... the tokenized version
#   }
#   {
#     ... the raw version ...
#     "url": "https://..."
#   },
#   ]
# }


# download
#---------

echo_sep
echo_underlined "Downloading the EU Constitution"

corpus="EUconst"
curl "http://opus.nlpl.eu/opusapi/?corpus=$corpus&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ${corpus,,} fr ''

echo_sep
echo_underlined "Downloading Wikivoyage"

./download.sh $DATA_DIR wikivoyage fr $DUMP_DATE cirrus

echo_sep
echo_underlined "Downloading Wikiquote"

./download.sh $DATA_DIR wikiquote fr $DUMP_DATE cirrus

echo_sep
echo_underlined "Downloading Wikibooks"

./download.sh $DATA_DIR wikibooks fr $DUMP_DATE cirrus

echo_sep
echo_underlined "Downloading Wikiversity"

./download.sh $DATA_DIR wikiversity fr $DUMP_DATE cirrus

echo_sep
echo_underlined "Downloading TED subtitles"

curl "http://opus.nlpl.eu/opusapi/?corpus=TED2013&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ted fr ''

echo_sep
echo_underlined "Downloading Wikinews"

./download.sh $DATA_DIR wikinews fr $DUMP_DATE cirrus

echo_sep
echo_underlined "Downloading Global Voices"

corpus="GlobalVoices"
curl "http://opus.nlpl.eu/opusapi/?corpus=$corpus&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ${corpus,,} fr ''

echo_sep
echo_underlined "Downloading the Wiktionary"

./download.sh $DATA_DIR wiktionary fr $DUMP_DATE cirrus

echo_sep
echo_underlined "Downloading News Commentary"

./download.sh $DATA_DIR news_commentary fr

echo_sep
echo_underlined "(Skipping EnronSent (only in English))"

echo_sep
echo_underlined "Downloading EuroParl"

./download.sh $DATA_DIR europarl fr

echo_sep
echo_underlined "(Skipping Le Monde (not in open access))"

echo_sep
echo_underlined "Downloading DGT"

corpus="DGT"
curl "http://opus.nlpl.eu/opusapi/?corpus=$corpus&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ${corpus,,} fr ''

echo_sep
echo_underlined "Downloading OpenSubtitles"

corpus="OpenSubtitles"
curl "http://opus.nlpl.eu/opusapi/?corpus=$corpus&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ${corpus,,} fr ''

echo_sep
echo_underlined "Downloading Project Gutenberg"

./download.sh $DATA_DIR gutenberg fr

echo_sep
echo_underlined "(Skipping PCT (not in open access))"

echo_sep
echo_underlined "Downloading GIGA"

corpus="giga-fren"
curl "http://opus.nlpl.eu/opusapi/?corpus=$corpus&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ${corpus,,} fr ''

echo_sep
echo_underlined "Downloading MultiUN"

corpus="MultiUN"
curl "http://opus.nlpl.eu/opusapi/?corpus=$corpus&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ${corpus,,} fr ''

echo_sep
echo_underlined "Downloading the EU Bookshop"

corpus="EUbookshop"
curl "http://opus.nlpl.eu/opusapi/?corpus=$corpus&source=fr&preprocessing=mono&version=latest" \
  | jq '.corpora[1].url' \
  | xargs ./download.sh $DATA_DIR ${corpus,,} fr ''

echo_sep
echo_underlined "Downloading Wikisource"

./download.sh $DATA_DIR wikisource fr $DUMP_DATE cirrus

echo_sep
echo_underlined "Downloading Wikipedia"

./download.sh $DATA_DIR wiki fr 'latest'

echo_sep
echo_underlined "Downloading NewsCrawl"

./download.sh $DATA_DIR news_crawl fr

echo_sep
echo_underlined "Downloading Common Crawl"
echo "***Beware, this is big (50+Gb), it may take hours.***"

./download.sh $DATA_DIR common_crawl fr

echo_sep
echo_underlined "The bulk of the FlauBERT corpus has been downloaded in $DATA_DIR."
