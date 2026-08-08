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
        type filter hook input priority filter; policy drop;

        # loopback
		iif "lo" accept

		ct state established,related accept
        ct state invalid drop

		ip protocol icmp accept
		ip6 nexthdr ipv6-icmp accept

        # LAN-only ports (TCP)
		iifname "enp42s0" ip saddr 192.168.1.0/24 tcp dport { 22, 25565, 5000, 8000-8999, 4000, 11434 } accept
        # LAN-only ports (UDP)
		iifname "enp42s0" ip saddr 192.168.1.0/24 udp dport { 49152, 8000-8999 } accept
        # LAN ICMP
		iifname "enp42s0" ip protocol icmp accept

        # Minecraft for WAN but only IPv6
        meta nfproto ipv6 tcp dport 25565 accept

        log prefix "NFT DROP: " flags all
	}

    chain forward {
        type filter hook forward priority filter; policy drop;
    }

    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```

```default.conf
table inet filter {
    chain input {
        type filter hook input priority filter; policy drop;

        # Local traffic
        iif "lo" accept

        # Allow replies to connections initiated by this host
        ct state established,related accept

        # Drop malformed/invalid connections
        ct state invalid drop

        # Essential ICMP / ICMPv6
        ip protocol icmp accept
        ip6 nexthdr ipv6-icmp accept

        # Log everything else before dropping
        log prefix "NFT DROP: " flags all
    }

    chain forward {
        type filter hook forward priority filter; policy drop;
    }

    chain output {
        type filter hook output priority filter; policy accept;
    }
}
```
