#!/bin/bash

BASE_URL="http://yann.lecun.com/exdb/mnist"

FILES=("train-images-idx3-ubyte.gz" "train-labels-idx1-ubyte.gz" "t10k-images-idx3-ubyte.gz" "t10k-labels-idx1-ubyte.gz")

for f in "${FILES[@]}"; do
    wget $BASE_URL/$f
    gunzip -dk $f
done
