#!/bin/bash

echo testing some stuff 
echo -----------------------------------------
echo 

cat /dev/stdin | cut -d' ' -f 5,4 | sort
