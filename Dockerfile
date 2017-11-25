FROM       ubuntu:14.04
MAINTAINER Jarrar Jaffari (jarrar.jaffari@gmail.com)

ADD requirements.txt /requirements.txt
COPY uwsgi.ini /etc/uwsgi.ini

RUN apt-get update && apt-get install -y curl git openssh-server sqlite3
RUN apt-get install -y python-pip python2.7-dev vim
ADD entrypoint.sh /entrypoint.sh
# requirements.txt has all the pip packages that needs to installed.
RUN pip install -r /requirements.txt

RUN mkdir /webapp

ADD webapp/ /webapp
ENV HOME /root
COPY sqliterc /root/.sqliterc

WORKDIR /webapp
ENTRYPOINT ["/entrypoint.sh"]
