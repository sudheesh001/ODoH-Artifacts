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

### Running Benchmarks

The `golang` client has a `bench` submodule which queries the ODoH targets and proxies with a randomly chosen set of domain names from a list.

The Tranco Million dataset can be obtained using the `scripts/fetch-datasets.sh` which will download, extract and prepare the dataset
in the format necessary for ODoH Client for benchmarking. The dataset will be available at `dataset/tranco-1m.csv`.

To run the `fetch-datasets.sh` script successfully, `awk` and `sed` are necessary tools.

The benchmarks can be run as follows:

```shell script
./odoh-client bench --target odoh.cloudflare-dns.com \
                    --proxy odoh1.surfdomeinen.nl \
                    --pick 200 --numclients 10 --rate 15 \
                    --data dataset/tranco-1m.csv \
                    --out result.json
```

and more details are available in `--help`

```text
NAME:
   Oblivious DNS over HTTPS Client Command Line Interface bench - Performs a benchmark for ODOH Target Resolver

USAGE:
   Oblivious DNS over HTTPS Client Command Line Interface bench [command options] [arguments...]

OPTIONS:
   --data value               (default: "dataset.csv")
   --pick value               (default: 10)
   --numclients value         (default: 10)
   --rate value               (default: 15)
   --logout value             (default: "log.txt")
   --out value                Filename to save serialized JSON response from benchmark execution (eg. output.json). If no filename is provided, or failure to write to file, the default will print to console.
   --target value             Hostname:Port format declaration of the target resolver hostname (default: "localhost:8080")
   --proxy value, -p value    Hostname:Port format declaration of the proxy hostname
   --dnstype value, -t value  (default: "A")
```

The output result will be available at `log.txt` and serialized JSON in `result.json` passed as value to `--out`.