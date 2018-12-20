FROM microsoft/azure-cli:latest

ENV ACME_SERVER https://acme-v02.api.letsencrypt.org/directory

# Upgrade Alpine version - 3.7 has certbot 0.19
# 3.8 needed for certbot 0.25.1-r1 (wildcard support)
RUN sed -i -e 's/v3\.7/v3.8/g' /etc/apk/repositories \
    && apk upgrade --update-cache --available \
    && apk add certbot

WORKDIR /acmeazure

COPY . .
RUN chmod +x ./*.sh

CMD ./acmeazure.sh