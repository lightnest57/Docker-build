FROM ubuntu:focal
LABEL maintainer="I-n-o-k <inok.dr189@gmail.com>"
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /tmp

RUN apt-get -yqq update \
    && apt-get install --no-install-recommends -yqq adb autoconf automake axel bc bison build-essential ccache clang cmake curl expat fastboot flex g++ g++-multilib gawk gcc gcc-multilib git gnupg gperf htop imagemagick locales libncurses5 lib32ncurses5-dev lib32z1-dev libtinfo5 libc6-dev libcap-dev libexpat1-dev libgmp-dev '^liblz4-.*' '^liblzma.*' libmpc-dev libmpfr-dev libncurses5-dev libsdl1.2-dev libssl-dev libtool libxml-simple-perl libxml2 libxml2-utils lsb-core lzip '^lzma.*' lzop maven nano ncftp ncurses-dev openssh-server patch patchelf pkg-config pngcrush pngquant python2.7 python-all-dev python-is-python3 re2c rclone rsync schedtool squashfs-tools subversion sudo tar texinfo tmate tzdata unzip w3m wget xsltproc zip zlib1g-dev zram-config zstd \
    && curl --create-dirs -L -o /usr/local/bin/repo -O -L https://storage.googleapis.com/git-repo-downloads/repo \
    && chmod a+rx /usr/local/bin/repo \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* \
    && echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && /usr/sbin/locale-gen \
    && TZ=Asia/Kolkata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create user and home directory
RUN set -xe \
  && mkdir -p /home/builder \
  && useradd --no-create-home builder \
  && rsync -a /etc/skel/ /home/builder/ \
  && chown -R builder:builder /home/builder \
  && echo "builder ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers

WORKDIR /home

RUN set -xe \
  && mkdir /home/builder/bin \
  && curl -sL https://gerrit.googlesource.com/git-repo/+/refs/heads/stable/repo?format=TEXT | base64 --decode  > /home/builder/bin/repo \
  && curl -s https://api.github.com/repos/tcnksm/ghr/releases/latest \
    | jq -r '.assets[] | select(.browser_download_url | contains("linux_amd64")) | .browser_download_url' | wget -qi - \
  && tar -xzf ghr_*_amd64.tar.gz --wildcards 'ghr*/ghr' --strip-components 1 \
  && mv ./ghr /home/builder/bin/ && rm -rf ghr_*_amd64.tar.gz \
  && chmod a+rx /home/builder/bin/repo \
  && chmod a+x /home/builder/bin/ghr

WORKDIR /home/builder

RUN set -xe \
  && mkdir -p extra && cd extra \
  && wget -q https://ftp.gnu.org/gnu/make/make-4.3.tar.gz \
  && tar xzf make-4.3.tar.gz \
  && cd make-*/ \
  && ./configure && bash ./build.sh 1>/dev/null && install ./make /usr/local/bin/make \
  && cd .. \
  && if [ "${SHORTCODE}" = "bionic" ]; then \
    git clone https://github.com/ninja-build/ninja.git; \
    cd ninja; git checkout -q v1.10.2; \
    ./configure.py --bootstrap; \
    install ./ninja /usr/local/bin/ninja; \
    cd ..; fi \
  && git clone https://github.com/ccache/ccache.git \
  && cd ccache && git checkout -q v4.2 \
  && mkdir build && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. \
  && make -j8 && make install \
  && cd ../../.. \
  && rm -rf extra

RUN if [ "${SHORTCODE}" = "focal" ]; then \
    if [ -e /lib/x86_64-linux-gnu/libncurses.so.6 ] && [ ! -e /usr/lib/x86_64-linux-gnu/libncurses.so.5 ]; then \
      ln -s /lib/x86_64-linux-gnu/libncurses.so.6 /usr/lib/x86_64-linux-gnu/libncurses.so.5; \
    fi; \
  fi

COPY android-env-vars.sh /etc/android-env-vars.sh

RUN chmod a+x /etc/android-env-vars.sh \
  && echo "source /etc/android-env-vars.sh" >> /etc/bash.bashrc

# Set up udev rules for adb
RUN set -xe \
  && curl --create-dirs -sL -o /etc/udev/rules.d/51-android.rules -O -L \
    https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules \
  && chmod 644 /etc/udev/rules.d/51-android.rules \
  && chown root /etc/udev/rules.d/51-android.rules

RUN CCACHE_DIR=/srv/ccache ccache -M 5G \
  && chown builder:builder /tmp/ccache

USER builder

VOLUME ["/home/builder", "/tmp/ccache"]
