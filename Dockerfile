FROM ubuntu:focal

LABEL maintainer="I-n-o-k <inok.dr189@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG=C.UTF-8
WORKDIR /tmp

RUN apt-get -yqq update \    
     && apt-get install -yqq --no-install-recommends sudo git ffmpeg maven nodejs ca-certificates-java python-is-python3 pigz tar rsync rclone aria2 adb autoconf automake axel bc bison build-essential ccache clang cmake curl expat fastboot flex g++ g++-multilib gawk gcc gcc-multilib git gnupg gperf htop imagemagick locales libncurses5 lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev libsdl1.2-dev libssl-dev libtool libxml-simple-perl libxml2 libxml2-utils lsb-core lzip '^lzma.*' lzop maven nano ncftp ncurses-dev openssh-server patch patchelf pkg-config pngcrush pngquant python2.7 python-all-dev python-is-python3 re2c rclone rsync schedtool squashfs-tools subversion sudo tar texinfo tmate tzdata unzip w3m wget xsltproc zip zlib1g-dev zram-config zstd

RUN apt-get -yqq clean \
     && apt-get -yqq autoremove \
     && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
     && echo "Set disable_coredump false" >> /etc/sudo.conf

WORKDIR /tmp
RUN curl -L -o /tmp/gh.deb https://github.com/cli/cli/releases/download/v2.4.0/gh_2.4.0_linux_amd64.deb
RUN apt install /tmp/gh.deb

WORKDIR /tmp
RUN curl -L -o /tmp/go1.17.6.linux-amd64.tar.gz https://go.dev/dl/go1.17.6.linux-amd64.tar.gz
RUN rm -rf /usr/local/go \
     && tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz

ENV PATH=$PATH:/usr/local/go/bin

RUN sudo apt-get -y install tzdata \
     && sudo apt-mark hold tzdata
     
RUN git clone https://github.com/akhilnarang/scripts /tmp/scripts
WORKDIR /tmp/scripts/setup
RUN sudo bash android_build_env.sh \

WORKDIR /tmp
RUN rm -rf /tmp/scripts \
     && echo 'en_GB.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen \
     && ln -snf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime && echo Asia/Jakarta > /etc/timezone

WORKDIR /tmp

VOLUME ["/tmp/rom"] ["/tmp/ccache"]
