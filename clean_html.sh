#!/bin/bash
# script de nettoyage html : keep dry, even for cleaning

# retour à la ligne : <br />
find app/ -name '*.[^~]*[^~]' -exec sed 's/<br\/>/<br \/>/g' {} \;
