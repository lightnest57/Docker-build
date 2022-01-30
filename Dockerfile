FROM ubuntu:focal

LABEL maintainer="I-n-o-k <inok.dr189@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG=C.UTF-8
ENV JAVA_OPTS=" -Xmx7G "
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
WORKDIR /tmp

RUN apt-get -yqq update \    
     && apt-get install -yqq --no-install-recommends sudo curl ssh git ffmpeg openjdk-8-jdk openjdk-8-jre maven nodejs ca-certificates-java python-is-python3 pigz tar rsync ccache rclone aria2 libncurses5 \
     && apt-get -yqq purge default-jre-headless openjdk-11-jre-headless

RUN apt-get -yqq clean \
     && apt-get -yqq autoremove \
     && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
     && echo "Set disable_coredump false" >> /etc/sudo.conf

WORKDIR /tmp
RUN wget https://go.dev/dl/go1.17.6.linux-amd64.tar.gz
RUN rm -rf /usr/local/go \
     && tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz

RUN sudo apt-get -y install tzdata \
     && sudo apt-mark hold tzdata
     
RUN git config --global user.name I-n-o-k
RUN git config --global user.email inok.dr189@gmail.com

RUN git clone https://github.com/I-n-o-k/scripts /tmp/scripts
WORKDIR /tmp/scripts/setup
RUN make install

RUN sudo bash android_build_env.sh \

RUN git clone https://github.com/cli/cli.git /tmp/gh-cli
WORKDIR /tmp/gh-cli


WORKDIR /tmp
RUN rm -rf /tmp/scripts \
     && echo 'en_GB.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen \
     && TZ=Asia/Jakarta \
     && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /tmp

VOLUME ["/tmp/rom"] ["/tmp/ccache"]
