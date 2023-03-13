FROM mcr.microsoft.com/azure-cli:latest

ENV ACME_SERVER https://acme-v02.api.letsencrypt.org/directory

RUN apk upgrade --update-cache --available \
    && apk add certbot

WORKDIR /acmeazure

COPY . .
RUN chmod +x ./*.sh

CMD ./acmeazure.sh