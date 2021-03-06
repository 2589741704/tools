#!/bin/bash
#
yum -y install epel-release
yum -y install git
yum -y install openssl-devel gettext gcc autoconf libtool automake make asciidoc xmlto c-ares-devel libev-devel autoconf automake libtool gettext pkg-config libmbedtls libsodium libpcre3 libev libc-ares asciidoc xmlto gettext gcc autoconf libtool automake make asciidoc xmlto c-ares-devel libev-devel pcre-devel

git clone https://github.com/shadowsocks/shadowsocks-libev.git
cd shadowsocks-libev
git submodule update --init --recursive

# Installation of Libsodium
export LIBSODIUM_VER=1.0.13
wget https://download.libsodium.org/libsodium/releases/libsodium-$LIBSODIUM_VER.tar.gz
tar xvf libsodium-$LIBSODIUM_VER.tar.gz
pushd libsodium-$LIBSODIUM_VER
./configure --prefix=/usr && make
sudo make install
popd
sudo ldconfig

# Installation of MbedTLS
export MBEDTLS_VER=2.6.0
wget https://tls.mbed.org/download/mbedtls-$MBEDTLS_VER-gpl.tgz
tar xvf mbedtls-$MBEDTLS_VER-gpl.tgz
pushd mbedtls-$MBEDTLS_VER
make SHARED=1 CFLAGS=-fPIC
make DESTDIR=/usr install
popd
ldconfig

# Start building
./autogen.sh && ./configure && make
make install


cat > /etc/shadowsocks.json << EOF
{
    "server":"xxx.xxx.xx.xx",
    "local_address":"127.0.0.1",
    "lcoal_port":1080,
    "port_password": {
	"8080":"password",
    },
    "timeout":60,
    "method":"aes-256-cfb"
}
EOF
useradd shadowsocks

cat > /etc/systemd/system/ss.service << EOF
[Unit]
Description=ShadowSocks libev

[Service]
TimeoutStartSec=0
ExecStart=/usr/local/bin/ss-manager -u --manager-address /tmp/shadowsocks.sock -c /etc/shadowsocks.json -a shadowsocks start

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

systemctl status ss.service

cd ~
rm -fr shadowsocks-libev 

