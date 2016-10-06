FROM aksaramaya/tc

ENV LANG=C.UTF-8 LC_ALL=C
ENV SRC="."
ENV ETC="/etc"
ENV WORK="/tmp"

WORKDIR $WORK
COPY $SRC/redis.conf $ETC
COPY $SRC/entrypoint.sh /entrypoint.sh

RUN tce-load -wic gnupg curl \
    && rm -rf /tmp/tce/optional/*

ENV REDIS_VERSION 3.2.4

RUN tce-load -wic \
        bzip2-dev \
        flex \
        file \
        gcc \
        make \
        linux-4.2.1_api_headers \
        glibc_add_lib \
        glibc_base-dev \
        openssl-dev \
        gdbm-dev \
        ncurses-dev \
        readline-dev \
        sqlite3-dev \
        liblzma-dev \
        zlib_base-dev \
        tk-dev \
        libX11-dev \
        libXss \
        xorg-proto; \
        cd /tmp; \
        curl -SL http://download.redis.io/releases/redis-3.2.4.tar.gz -o redis.tar.gz; \
        tar -vxf redis.tar.gz -C /tmp; \
        pwd; \
        rm redis.tar.gz; \
        cd "/tmp/redis-$REDIS_VERSION"; \
        make; \
        sudo make install; \
        cd /; \
        rm -rf "/tmp/redis-$REDIS_VERSION"; \
        cd /tmp/tce/optional; \
        for PKG in `ls *-dev.tcz`; do \
            echo "Removing $PKG files"; \
            for F in `unsquashfs -l $PKG | grep squashfs-root | sed -e 's/squashfs-root//'`; do \
                [ -f $F -o -L $F ] && sudo rm -f $F; \
            done; \
            INSTALLED=$(echo -n $PKG | sed -e s/.tcz//); \
            sudo rm -f /usr/local/tce.installed/$INSTALLED; \
        done; \
        for PKG in binutils.tcz \
                cloog.tcz \
                flex.tcz \
                file.tcz \
                gcc.tcz \
                gcc_libs.tcz \
                linux-4.2.1_api_headers.tcz \
                make.tcz \
                sqlite3-bin.tcz \
                xz.tcz \
                xorg-proto.tcz; do \
            echo "Removing $PKG files"; \
            for F in `unsquashfs -l $PKG | grep squashfs-root | sed -e 's/squashfs-root//'`; do \
                [ -f $F -o -L $F ] && sudo rm -f $F; \
            done; \
            INSTALLED=$(echo -n $PKG | sed -e s/.tcz//); \
            sudo rm -f /usr/local/tce.installed/$INSTALLED; \
        done; \
        sudo rm -f /usr/bin/file \
        sudo /sbin/ldconfig \
        rm -rf /tmp/tce/optional/* \

WORKDIR $HOME
ENTRYPOINT ["/entrypoint.sh"]
