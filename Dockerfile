FROM phusion/baseimage:latest

RUN curl https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

ENV ELASTICSEARCH_VERSION 2.2.2
ENV ELASTICSEARCH_REPO_BASE http://packages.elastic.co/elasticsearch/2.x/debian

RUN echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch-2.x.list

RUN \
  sed -i '0,/trusty main/s/restricted//' /etc/apt/sources.list && \
  add-apt-repository ppa:openjdk-r/ppa && \
  apt-get update && \
  apt-get install -y openjdk-8-jdk

RUN \
	apt-get install -y --no-install-recommends elasticsearch=$ELASTICSEARCH_VERSION \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex \
	&& for path in \
		/data/elasticsearch \
		/usr/share/elasticsearch/logs \
		/usr/share/elasticsearch/config \
		/usr/share/elasticsearch/config/scripts \
	; do \
		mkdir -p "$path"; \
	done
COPY elasticsearch-riemann-plugin-2.1.1-SNAPSHOT.zip /usr/share/elasticsearch/elasticsearch-riemann-plugin-2.1.1-SNAPSHOT.zip
RUN /usr/share/elasticsearch/bin/plugin install file:/usr/share/elasticsearch/elasticsearch-riemann-plugin-2.1.1-SNAPSHOT.zip

COPY config /usr/share/elasticsearch/config
COPY run /etc/service/elasticsearch/run

EXPOSE 9200 9300

