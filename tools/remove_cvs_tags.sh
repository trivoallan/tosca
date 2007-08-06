#!/bin/bash


dir=vendor/plugins/tiny_mce/docs/tinymce_api/
for i in `ls $dir/*.html`
do
    file=$i
    sed -i  s/\$Revision.*$// $file
    sed -i  s/\$Date.*$// $file
    cp $file ../lstm-prod/$file
done