FROM docker.repo.orl.eng.hitachivantara.com/alpine:3.16

WORKDIR /registry-publication

LABEL "version"="0.0.1"

## Make sure that the CLI doesn't offer to store credentials
ENV JFROG_CLI_OFFER_CONFIG=false

RUN apk add --no-cache \
  bash \
  curl \
  docker \
  openrc \
  jq \
  findutils && \
  rm -rf /var/cache/apk/*

# Add docker service start at boot time
RUN rc-update add docker boot

RUN curl -fL https://getcli.jfrog.io | sh
RUN mv jfrog /usr/bin/jfrog && chmod +x /usr/bin/jfrog

RUN wget https://github.com/mikefarah/yq/releases/download/v4.27.2/yq_linux_amd64 -O /usr/bin/yq \
    && chmod +x /usr/bin/yq

COPY entrypoint.sh utils.sh /registry-publication/

ENTRYPOINT ["/registry-publication/entrypoint.sh"]
