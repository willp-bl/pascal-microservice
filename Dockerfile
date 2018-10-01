FROM ubuntu:latest

RUN apt-get update && apt-get install -y fpc

RUN apt-get install -y git

WORKDIR /pascal-microservice

CMD bash

