DNSIP=$1
apt-get update
apt-get install -y bind9 bind9utils bind9-doc
 
cat <<EOF >/etc/bind/named.conf.options
acl "allowed" {
   192.168.1.0/24;
};

options {
    directory "/var/cache/bind";
    dnssec-validation auto;

    listen-on-v6 { any; };
    forwarders { 1.1.1.1;  1.0.0.1;  };
};
EOF

cat <<EOF >/etc/bind/named.conf.local
zone "ZONA.COM" {
        type master;
        file "/var/lib/bind/ZONA.COM";
        };
zone "1.168.192.in-addr.arpa" {
        type master;
        file "/var/lib/bind/192.168.1.rev";
        };
EOF

cat <<EOF >/var/lib/bind/ZONA.COM
$TTL 3600
ZONA.COM.     IN      SOA     ns.ZONA.COM. santi.ZONA.COM. (
                3            ; serial
                7200         ; refresh after 2 hours
                3600         ; retry after 1 hour
                604800       ; expire after 1 week
                86400 )      ; minimum TTL of 1 day

ZONA.COM.          IN      NS      ns.ZONA.COM.
ns.ZONA.COM.       IN      A       ZONA.COM.
santi.ZONA.COM.    IN      A       192.168.1.8
apache             IN      A       192.168.1.11
apache.ZONA.COM.   IN      A       192.168.1.9

; aqui pones los hosts
EOF

cat <<EOF >/var/lib/bind/192.168.1.rev
$ttl 3600
100..1.168.192.in-addr.arpa.  IN      SOA     ns.ZONA.COM. santi.ZONA.COM. (
                3            ; serial
                7200         ; refresh after 2 hours
                3600         ; retry after 1 hour
                604800       ; expire after 1 week
                86400 )      ; minimum ttl of 1 day
100..1.168.192.in-addr.arpa.  IN      NS      ns.ZONA.COM.
apache2.                      IN      PTR     apache.
; aqui pones los hosts inversos

EOF

cp /etc/resolv.conf{,.bak}
cat <<EOF >/etc/resolv.conf
nameserver 8.8.8.8
domain ZONA.COM
EOF

named-checkconf
named-checkconf /etc/bind/named.conf.options
named-checkzone ZONA.COM /var/lib/bind/ZONA.COM
named-checkzone XXX.YYY.ZZZ.in-addr.arpa /var/lib/bind/XXX.XXX.XXX.rev
sudo systemctl restart bind9