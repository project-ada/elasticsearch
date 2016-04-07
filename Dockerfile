FROM phusion/baseimage:latest

#RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 46095ACC8548582C1A2699A9D27D666CD88E42B4
RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | apt-key add -

ENV ELASTICSEARCH_VERSION 2.2.2
ENV ELASTICSEARCH_REPO_BASE http://packages.elastic.co/2.x/debian

RUN echo "deb $ELASTICSEARCH_REPO_BASE stable main" > /etc/apt/sources.list.d/elasticsearch.list

RUN \
  sed -i '0,/trusty main/s/restricted//' /etc/apt/sources.list && \
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

RUN plugin -url https://github.com/searchly/elasticsearch-monitoring-riemann-plugin/releases/download/elasticsearch-riemann-plugin-1.7.2/elasticsearch-riemann-plugin-1.7.2.zip -install riemann

COPY config /usr/share/elasticsearch/config
COPY run /etc/service/elasticsearch/run

EXPOSE 9200 9300

