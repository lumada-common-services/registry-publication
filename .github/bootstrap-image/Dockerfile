FROM docker.repo.orl.eng.hitachivantara.com/maven:3.8.6-openjdk-11-slim

# Helm
ENV HELM_VERSION=v3.1.2
ENV HELM_FILENAME=helm-${HELM_VERSION}-linux-amd64.tar.gz

RUN curl -L https://get.helm.sh/${HELM_FILENAME} | tar xz && mv linux-amd64/helm /bin/helm && rm -rf linux-amd64

# Docker ce
ENV VERSION=20.10.21
RUN curl -sSL https://get.docker.com | sh

