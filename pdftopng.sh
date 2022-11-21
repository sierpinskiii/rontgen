#!/bin/bash

mkdir ./slides/$1.d
convert -density 300 $1 -resize 25% ./slides/$1.d/slide.png
