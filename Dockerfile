FROM ubuntu:focal

LABEL maintainer="I-n-o-k <inok.dr189@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG=C.UTF-8
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
WORKDIR /tmp

RUN apt-get -yqq update \    
     && apt-get install -yqq --no-install-recommends sudo ssh git gh ffmpeg openjdk-8-jdk openjdk-8-jre maven nodejs ca-certificates-java python-is-python3 pigz tar rsync ccache rclone aria2 libncurses5 \
     && apt-get -yqq purge default-jre-headless openjdk-11-jre-headless

RUN apt-get -yqq clean \
     && apt-get -yqq autoremove \
     && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
     && echo "Set disable_coredump false" >> /etc/sudo.conf

RUN sudo apt-get -y install tzdata \
     && sudo apt-mark hold tzdata
     
RUN git config --global user.name I-n-o-k
RUN git config --global user.email inok.dr189@gmail.com

RUN git clone https://github.com/akhilnarang/scripts /tmp/scripts \
     && sudo bash /tmp/scripts/setup/android_build_env.sh \
     && sudo bash /tmp/scripts/setup/ccache.sh \
     && rm -rf /tmp/scripts \
     && echo 'en_GB.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen \
     && TZ=Asia/Jakarta \
     && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /tmp

VOLUME ["/tmp/rom"] ["/tmp/ccache"]
