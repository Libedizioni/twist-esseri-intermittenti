#!/bin/bash

# measure script timing
time_start() {
  START=$(date +%s%3N)
}
time_end() {
  END=$(( $(date +%s%3N) - $START ))
}

# setup script variables
EPUB_SRC="$BUILD/epub/$BOOKNAME.epub"
EPUB="$BUILD/mobi/$BOOKNAME.epub"
ZIP="$BUILD/mobi/$BOOKNAME.zip"
MOBI="$BUILD/mobi/$BOOKNAME.mobi"

# remove previous build version
clean() {
  rm -f "$MOBI"
}


# build mobi with Kindlegen cli
build_mobi_kindlegen() {
  echo "[+] now building mobi..."
  # create mobi dir if it does not exist
  mkdir -p "$BUILD/mobi"

  cp "$EPUB_SRC" "$EPUB"
  mv "$EPUB" "$ZIP"
  unzip -d "$BUILD/mobi/$BOOKNAME" "$ZIP"
  if [ ! -z $ISBN_MOBI ]; then
    sed -i "s/$ISBN_EPUB/$ISBN_MOBI/g" "$BUILD/mobi/$BOOKNAME/ch002.xhtml"
    sed -i "s/$ISBN_EPUB/$ISBN_MOBI/g" "$BUILD/mobi/$BOOKNAME/content.opf"
    sed -i "s/$ISBN_EPUB/$ISBN_MOBI/g" "$BUILD/mobi/$BOOKNAME/toc.ncx"
  else
    sed -i "s/ISBN $ISBN_EPUB//g" "$BUILD/mobi/$BOOKNAME/ch002.xhtml"
    sed -i "s/ISBN $ISBN_EPUB//g" "$BUILD/mobi/$BOOKNAME/content.opf"
    sed -i "s/ISBN $ISBN_EPUB//g" "$BUILD/mobi/$BOOKNAME/toc.ncx"
  fi
  rm "$ZIP"
  cd "$BUILD/mobi/$BOOKNAME"
  zip -r "../$BOOKNAME.zip" *
  cd ../../..
  mv "$ZIP" "$EPUB" && \
  rm -rf "$BUILD/mobi/$BOOKNAME"

  # change dir to mobi folder
  cd "$BUILD/mobi" && \
  # convert the epub to mobi with kindlegen
  kindlegen "$BOOKNAME.epub" -c1 -verbose -locale it -o "$BOOKNAME.mobi" && \
  echo "Mobi file generated correctly" && \
  # remove the epub source used
  rm -f "$BOOKNAME.epub" && \
  echo "Removing epub source file..."
  # change dir to project root
  cd ../..
}

# report script info and execution time
report() {
  sec_diff=$(($END / 1000))
  ms_hrs=$(printf "%02d" $(($sec_diff / 3600)))
  ms_min=$(printf "%02d" $((($sec_diff / 60) % 60)))
  ms_sec=$(printf "%02d" $(($sec_diff % 60)))
  ms_msec=$(printf "%03d" $(($END % 1000)))
  TOT_TIME="$ms_hrs:$ms_min:$ms_sec:$ms_msec"

  echo "Script $( basename $0 ) execution time: " "$TOT_TIME"
}

# get it done!
time_start
clean
build_mobi_kindlegen
time_end
report
