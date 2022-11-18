FROM docker.repo.orl.eng.hitachivantara.com/python:alpine3.16

WORKDIR /registry-publication

## Make sure that the CLI doesn't offer to store credentials
ENV JFROG_CLI_OFFER_CONFIG=false

RUN apk update
RUN apk add --no-cache \
  curl \
  docker \
  openrc \
  rm -rf /var/cache/apk/*

# Add docker service start at boot time
RUN rc-update add docker boot
RUN pip install pyyaml

RUN curl -fL https://getcli.jfrog.io | sh
RUN mv jfrog /usr/bin/jfrog && chmod +x /usr/bin/jfrog

COPY ./scripts/*.py /registry-publication/

ENTRYPOINT ["/registry-publication/entrypoint.py"]