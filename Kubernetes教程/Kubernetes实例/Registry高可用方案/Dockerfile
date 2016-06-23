#######################################################
# yeepay/registry:2.1
#######################################################

FROM registry:2.1
MAINTAINER dawei.li@yeepay.com

RUN mkdir /certs

ENV REGISTRY_HTTP_TLS_CERTIFICATE=/certs/domain.crt  
ENV REGISTRY_HTTP_TLS_KEY=/certs/domain.key
ENV REGISTRY_STORAGE_DELETE_ENABLED=true 

ADD certs /certs

EXPOSE 5000
