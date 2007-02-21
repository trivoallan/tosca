#!/bin/bash
find . -name "*.rb" | grep -v "vendor" | xargs ./vendor.rb
