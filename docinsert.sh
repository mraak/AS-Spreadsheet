#!/bin/bash

for f in `find src -name "*.as"`
do
   echo $f
   cat $f > /tmp/tempFile
   cat paste > $f 
   cat /tmp/tempFile >> $f
done

for f in `find src -name "*.mxml"`
do
   echo $f
   cat $f > /tmp/tempFile
   cat pastemxml > $f
   cat /tmp/tempFile >> $f
done
