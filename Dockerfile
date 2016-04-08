FROM phusion/baseimage:latest

RUN gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN arch="$(dpkg --print-architecture)" \
       && set -x \
       && curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$arch" \
       && curl -o /usr/local/bin/gosu.asc -fSL "https://github.com/tianon/gosu/releases/download/1.3/gosu-$arch.asc" \
       && gpg --verify /usr/local/bin/gosu.asc \
       && rm /usr/local/bin/gosu.asc \
       && chmod +x /usr/local/bin/gosu

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
		chown -R elasticsearch:elasticsearch "$path"; \
	done
COPY elasticsearch-riemann-plugin-2.1.1-SNAPSHOT.zip /usr/share/elasticsearch/elasticsearch-riemann-plugin-2.1.1-SNAPSHOT.zip
RUN /usr/share/elasticsearch/bin/plugin install file:/usr/share/elasticsearch/elasticsearch-riemann-plugin-2.1.1-SNAPSHOT.zip

COPY config/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
COPY run /etc/service/elasticsearch/run

EXPOSE 9200 9300

