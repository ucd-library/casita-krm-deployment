#! /bin/bash

docker-compose up --scale image-worker=10 controller=2 -d