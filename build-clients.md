## Building the ODoH Clients

### Building the `golang` Client

Similar to the `odoh-server-go`, the `odoh-client-go` located at `~/artifacts/odoh-client-go` uses `make` to build the necessary binaries.

```shell script
$ make
Cleaning and removing the odoh-client ...
Building the binary for odoh-client ...
Tag: <>
Version: 0.0.1
```

This generates a binary `odoh-client` which can issue the command to the proxy. To instruct the client to agree to custom TLS certificate pass the `--customcert` flag with the path to the `cert.pem`.
We create a symlink of the proxy certificate `cert.pem` and make it available to the client as `proxy-cert.pem`

```shell script
$ ln -s ~/artifacts/odoh-server-go/cert.pem proxy-cert.pem
$ ./odoh-client odoh --proxy localhost:4567 --target odoh.cloudflare-dns.com --domain www.example.com --dnstype AAAA --customcert proxy-cert.pem

Custom Trusted CA Certificates loaded
;; opcode: QUERY, status: NOERROR, id: 3732
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;www.example.com.	IN	 AAAA

;; ANSWER SECTION:
www.example.com.	81422	IN	AAAA	2606:2800:220:1:248:1893:25c8:1946
```

The command uses the ODoH protocol with the ODoH `proxy` server running at `localhost:4567` and the ODoH Target at `odoh.cloudflare-dns.com`.
The ODoH request is a DNS `AAAA` Query for `www.example.com`

The command uses the public `ODoH Target` Resolver operated by cloudflare `odoh.cloudflare-dns.com`. The HPKE public key
served can be fetched as `ObliviousDoHConfigs`

```shell script
$ ./odoh-client odohconfig-fetch --target odoh.cloudflare-dns.com --pretty
```

### Building the `rust` Client

The `odoh-client-rs` is a client instance written in rust and uses `cargo` to fetch the required dependencies.

```shell script
$ cd ~/artifacts/odoh-client-rs
$ cargo build
$ cargo run -- example.com AAAA
Response: [
    Record { 
      name_labels: Name { 
        is_fqdn: true, 
        label_data: [101, 120, 97, 109, 112, 108, 101, 99, 111, 109], 
        label_ends: [7, 10]
      }, 
      rr_type: AAAA, 
      dns_class: IN, 
      ttl: 81996, 
      rdata: AAAA(2606:2800:220:1:248:1893:25c8:1946) 
    }
]
```

The rust client is minimal and is available as a proof of concept of interoperability. The client uses the configuration
file `-c` a default available at `tests/config.toml` with the following configuration:

```yaml
[server]
# proxy can be commented out, however this will defeat the purpose of using ODoH.
proxy = "https://odoh1.surfdomeinen.nl/proxy"
target = "https://odoh.cloudflare-dns.com"
```

Integration tests can be run using `cargo test`.
