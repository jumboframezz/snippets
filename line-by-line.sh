#!/bin/bash

grep -v '^ *#' < test | awk '/^https.*/{print $1 " " $2}' | while IFS= read -r line; do
  url=$(echo "$line" | awk '{print $1}')
  ccode=$(echo "$line" | awk '{print $2}')
  echo "$url  from $ccode"
done

# placehokder
