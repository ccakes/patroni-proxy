FROM alpine

ADD https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 /usr/local/bin/jq

ADD pg-check.sh /usr/local/bin/

RUN \
  apk -U --no-cache add curl bind-tools \
  && curl -LO https://github.com/yyyar/gobetween/releases/download/0.6.1/gobetween_0.6.1_linux_amd64.tar.gz \
  && tar xf gobetween_0.6.1_linux_amd64.tar.gz gobetween -C /usr/local/bin \
  && rm -f gobetween_0.6.1_linux_amd64.tar.gz \
  && chmod 755 /usr/local/bin/*

CMD ["gobetween", "-c", "/etc/gobetween.toml"]