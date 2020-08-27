#! /bin/bash

docker-compose up --scale image-worker=10 --scale controller=2 -d