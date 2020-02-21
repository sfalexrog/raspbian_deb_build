FROM ubuntu:bionic

RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    ca-certificates \
    git \
    bc \
    bison \
    flex \
    libssl-dev \
    make \
    fakeroot \
    debhelper \
    dpkg-dev \
  && rm -rf /var/lib/apt/lists/*
