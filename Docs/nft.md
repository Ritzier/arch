# nft

## Show All Rule

```sh
sudo nft list ruleset
```

## Clear / flush rules

```sh
sudo nft flush ruleset
```

## Configuration

```nftables.conf
table inet filter {
  chain input {
    type filter hook input priority 0;

    # loopback
    iif lo accept

    # allow established connections
    ct state established,related accept

    # ICMP IPv4
    ip protocol icmp accept

    # ICMP IPv6
    ip6 nexthdr icmpv6 accept

    # allow LAN only
    iifname "enp42s0" ip saddr 192.168.1.0/24 tcp dport { 22, 8000-8999 } accept
    iifname "enp42s0" ip saddr 192.168.1.0/24 udp dport 8000-8999 accept

    # ping only from LAN
    iifname "enp42s0" ip protocol icmp accept

    # log everything else
    log prefix "NFT DROP: " flags all

    # drop everything else
    drop
  }

  chain forward {
    type filter hook forward priority 0;
    drop
  }

  chain output {
    type filter hook output priority 0;
    accept
  }
}
```
