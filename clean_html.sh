#!/bin/bash
# script de nettoyage html : keep dry, even for cleaning

# retour à la ligne : <br />
find app/ -name '*.[^~]*[^~]' -exec sed -i 's/<br\/>/<br \/>/g' {} \;
