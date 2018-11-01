FROM microsoft/azure-cli:latest

RUN apk update && apk add certbot

ENV ACME_SERVER https://acme-v01.api.letsencrypt.org/directory

COPY . /acmeazure
RUN chmod +x /acmeazure/*.sh

CMD /acmeazure/acmeazure.sh