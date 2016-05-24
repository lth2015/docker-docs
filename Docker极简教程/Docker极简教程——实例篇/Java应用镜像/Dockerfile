FROM ubuntu-jdk7:v1
MAINTAINER dawei.li@yeepay.com

ADD tomcat7-40-tomcat-push-portal/ /apps/product/tomcat7
RUN mkdir -p /apps/log/tomcat-access/
RUN mkdir -p /apps/log/tomcat-nohup/
RUN chown -Rf app:app /apps
# RUN chown -Rf app:app /apps/product/tomcat7
ADD dbconfig/  /apps/dbconfig/

USER app

ENTRYPOINT [ "/apps/product/tomcat7/bin/catalina.sh", "run" ]
