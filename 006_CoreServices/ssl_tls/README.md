# SSL TLS

Wolgang's Channel - youtube [Quick and Easy Local SSL Certificates for Your Homelab!](https://www.youtube.com/watch?v=qlcVx-k-02E)

## SSL TLS - Materials

+ [Where on earth do I start with SSL in a homelab?](https://www.reddit.com/r/selfhosted/comments/16cuxxu/where_on_earth_do_i_start_with_ssl_in_a_homelab/)
+ (<https://www.thesslstore.com/blog/cipher-suites-algorithms-security-settings/>)
+ youtube - [Cloudflare + Let's encrypt](https://www.youtube.com/results?search_query=cloudflare+letsencrypt)
+ [How to Create Self-Signed Certificates using OpenSSL](https://devopscube.com/create-self-signed-certificates-openssl/)

## OpenSSL

+ [Using EasyRSA Version 3.x to Generate Certificates for OpenVPN Tunnels](https://support.redlion.net/hc/en-us/articles/4403307638797-Using-EasyRSA-Version-3-x-to-Generate-Certificates-for-OpenVPN-Tunnels)

## Rocky - install openSSL from sources

2023.12.28 - po installacji

1. https://github.com/openssl/openssl/issues/13761
2. https://www.openssl.org/source/

```code
yum install \
    perl-FindBin \
    perl-Module-Load-Conditional \
    perl-Test-Harness \
    perl-CPAN

yum install wget
wget https://www.openssl.org/source/openssl-3.2.0.tar.gz
yum install tar
tar -xf openssl-3.2.0.tar.gz
cd openssl-3.2.0
ls
yum install -y perl-FindBin perl-Module-Load-Conditional perl-Test-Harness perl-CPAN
./config --prefix=/usr/local/openssl --openssldir=/usr/local/openssl
make -j $(nproc)
sudo make install
sudo ldconfig
sudo tee /etc/profile.d/openssl.sh<<EOF
export PATH=/usr/local/openssl/bin:\$PATH
export LD_LIBRARY_PATH=/usr/local/openssl/lib:/usr/local/openssl/lib64:\$LD_LIBRARY_PATH
EOF
source /etc/profile.d/openssl.sh
openssl version
yum install policycoreutils-python-utils
```
