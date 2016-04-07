FROM phusion/baseimage:latest

#RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4
RUN curl https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

ENV ELASTICSEARCH_VERSION 2.2.2
ENV ELASTICSEARCH_REPO_BASE http://packages.elastic.co/2.x/debian

RUN echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch-2.x.list

RUN \
  sed -i '0,/trusty main/s/restricted//' /etc/apt/sources.list && \
  add-apt-repository ppa:openjdk-r/ppa && \
  apt-get update && \
  apt-get install -y openjdk-8-jdk

RUN \
	apt-get install -y --no-install-recommends elasticsearch=$ELASTICSEARCH_VERSION \
	&& rm -rf /var/lib/apt/lists/*

ENV PATH /usr/share/elasticsearch/bin:$PATH

RUN set -ex \
	&& for path in \
		/data/elasticsearch \
		/usr/share/elasticsearch/logs \
		/usr/share/elasticsearch/config \
		/usr/share/elasticsearch/config/scripts \
	; do \
		mkdir -p "$path"; \
	done
COPY elasticsearch-riemann-plugin-2.1.0.zip /usr/share/elasticsearch/elasticsearch-riemann-plugin-2.1.0.zip
RUN plugin install file:elasticsearch-riemann-plugin-2.1.0.zip

COPY config /usr/share/elasticsearch/config
COPY run /etc/service/elasticsearch/run

EXPOSE 9200 9300

