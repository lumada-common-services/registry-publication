FROM docker.repo.orl.eng.hitachivantara.com/python:3.12.0a1-alpine3.16

WORKDIR /registry-publication

LABEL "version"="0.0.1"

## Make sure that the CLI doesn't offer to store credentials
ENV JFROG_CLI_OFFER_CONFIG=false

RUN apk add --no-cache \
  bash \
  curl \
  docker \
  openrc \
  findutils && \
  rm -rf /var/cache/apk/*

# Add docker service start at boot time
RUN rc-update add docker boot
RUN pip install pyyaml

RUN curl -fL https://getcli.jfrog.io | sh
RUN mv jfrog /usr/bin/jfrog && chmod +x /usr/bin/jfrog

COPY entrypoint.py jfrog_actions.py /registry-publication/

ENTRYPOINT ["/registry-publication/entrypoint.py"]
