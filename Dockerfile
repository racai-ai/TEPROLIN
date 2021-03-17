FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
LABEL maintainer="radu@racai.ro"
LABEL version="1.1"
LABEL description="The Docker Image containing the TEPROLIN text processing platform, \
    developed in the ReTeRom project."
# 1. Install the NER web service
RUN apt update && \
    apt install -y wget curl make automake autoconf gcc g++ flex bison
RUN mkdir /ner
RUN wget http://relate.racai.ro/resources/ner/ner.tar.bz2 -O /ner.tar.bz2 && \
    tar -jxf ner.tar.bz2 && rm -f /ner.tar.bz2
RUN wget http://relate.racai.ro/resources/ner/COROLA.vectors.gz \
    -O /ner/COROLA.vectors.gz && \
    gunzip /ner/COROLA.vectors.gz
RUN wget http://relate.racai.ro/resources/ner/COROLA.words.gz \
    -O /ner/COROLA.words.gz && \
    gunzip /ner/COROLA.words.gz
RUN wget http://relate.racai.ro/resources/ner/combined_ctag.clean.PERLOCORG.4.ser.gz \
    -O /ner/combined_ctag.clean.PERLOCORG.4.ser.gz
RUN wget http://relate.racai.ro/resources/ner/stanford-ner-2018-10-16-mod.tar.bz2 \
    -O /ner/stanford-ner-2018-10-16-mod.tar.bz2 && \
    tar -C /ner -jxf /ner/stanford-ner-2018-10-16-mod.tar.bz2 && \
    rm -f /ner/stanford-ner-2018-10-16-mod.tar.bz2
RUN wget http://relate.racai.ro/resources/ner/web.tar.bz2 \
    -O /ner/web.tar.bz2 && tar -C /ner -jxf /ner/web.tar.bz2 && rm -f /ner/web.tar.bz2
RUN wget http://relate.racai.ro/resources/ner/fasttext-0.1.0-mod.tar.bz2 \
    -O /ner/fasttext-0.1.0-mod.tar.bz2 && \
    tar -C /ner -jxf /ner/fasttext-0.1.0-mod.tar.bz2 && rm -f /ner/fasttext-0.1.0-mod.tar.bz2
RUN cd /ner/fastText-0.1.0-mod && make fasttext
RUN wget http://relate.racai.ro/resources/ner/corola.300.20.5.bin -O /ner/corola.300.20.5.bin
# ner_server.sh runs with Java 15 now
COPY docker/ner_server.sh /ner/
RUN chmod a+x /ner/ner_server.sh
# Install Java 15
RUN wget http://relate.racai.ro/resources/teprolin/openjdk-15.0.2_linux-x64_bin.tar.gz && \
    tar -xzvf openjdk-15.0.2_linux-x64_bin.tar.gz && \
    rm -fv openjdk-15.0.2_linux-x64_bin.tar.gz
ENV JAVA_HOME=/jdk-15.0.2
# Install Perl CPAN packages for TEPROLIN
# Install Perl5 only if it's not installed (it usually is)
RUN command -v perl >/dev/null || apt install -y perl
# Needed by BerkeleyDB Perl module (development)
RUN apt install -y libdb5.3++-dev libdb5.3-dev zip unzip gpg makepatch
RUN cpan -i Unicode::String
RUN cpan -i Algorithm::Diff
RUN cpan -i BerkeleyDB
RUN cpan -i File::Which
RUN cpan -i File::HomeDir

RUN apt install -y zip unzip apache2 php7.4 libapache2-mod-php7.4 php7.4-mbstring php7.4-curl locales
RUN locale-gen en_US.UTF-8
RUN mkdir -p /var/www/site && a2enmod php7.4 && a2enmod rewrite
RUN cp -rv /ner/web/word_embeddings/ /var/www/site/
COPY docker/ner_php/ner/ /var/www/site/ner/
COPY docker/ner_php/php_text_lib/ /var/www/site/php_text_lib/
# Stuff for TEPROLIN platform (run-time): Python 3
RUN apt install -y python3.8 python3-pip dos2unix
# These are the TEPROLIN Python 3 dependencies
RUN mkdir /teprolin
COPY requirements.txt /teprolin/
RUN cd /teprolin && pip3 install -r requirements.txt
RUN pip3 install uwsgi
# Copy local Python 3 source files to the image
COPY bioner/ /teprolin/bioner/
COPY cubenlp/ /teprolin/cubenlp/
COPY diac/ /teprolin/diac/
COPY ner/ /teprolin/ner/
COPY tests/ /teprolin/tests/
COPY tnorm/ /teprolin/tnorm/
COPY ttl/ /teprolin/ttl/
COPY ttsops/ /teprolin/ttsops/
COPY udpipe/ /teprolin/udpipe/
COPY images/ /teprolin/images/
COPY *.sh /teprolin/
COPY *.py /teprolin/
COPY teprolin-stats.txt /teprolin/
COPY TeproTTL.pl /teprolin/
COPY ttl-port.txt /teprolin/
COPY mlpla-port.txt /teprolin/
COPY favicon.ico /teprolin/
COPY index.html /teprolin/
RUN cd /teprolin && dos2unix -v *.txt *.pl *.py *.sh *.html
# Write NLP-Cube and TEPROLIN resources to the container
COPY docker/install-resources.py /teprolin/
RUN python3 /teprolin/install-resources.py
RUN rm -fv /teprolin/install-resources.py
# End resource loading
RUN cd /teprolin && chmod a+rx *.sh && chmod a-x *.txt *.html *.ico *.py *.pl
# These should PASS, othewise the build has to fail
RUN cd /teprolin && perl -c TeproTTL.pl
# End stuff for TEPROLIN platform

RUN sed -i "s/error_reporting = .*$/error_reporting = E_ERROR | E_WARNING | E_PARSE/" /etc/php/7.4/apache2/php.ini

ENV APACHE_RUN_USER=www-data
ENV APACHE_RUN_GROUP=www-data
ENV APACHE_LOG_DIR=/var/log/apache2
ENV APACHE_LOCK_DIR=/var/lock/apache2
ENV APACHE_PID_FILE=/var/run/apache2/apache2.pid

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en

ENV TEPROLIN_DOCKER=Yes

COPY docker/apache-config.conf /etc/apache2/sites-enabled/000-default.conf

COPY docker/entrypoint.sh /
RUN chmod a+rx /entrypoint.sh

EXPOSE 5000

CMD ["/entrypoint.sh"]
# After this point, execute a shell into this container and test TEPROLIN:
#cd /teprolin && pytest -s -v tests
#CMD tail -f /dev/null
