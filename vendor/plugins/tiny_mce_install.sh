#!/bin/bash
svn export https://secure.near-time.com/svn/plugins/trunk/tiny_mce
cd ../..
rake tiny_mce:scripts:install
