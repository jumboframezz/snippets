#!/bin/bash

grep -v '^ *#' < test | awk '{print $1}' | while IFS= read -r line
do
  echo "Line: $line"
done

# placehokder
