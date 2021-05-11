# Oblivious DNS over HTTPS (ODoH): A Practical Privacy Enhancement to DNS

### Artifacts Available
| # | Artifact Type                   | Link to Artifact                             |
|---|---------------------------------|----------------------------------------------|
| 1 | ODoH Target Server and Proxy    | https://github.com/cloudflare/odoh-server-go |
| 2 | ODoH Go lang Client             | https://github.com/cloudflare/odoh-client-go |
| 3 | ODoH Rust Client                | https://github.com/cloudflare/odoh-client-rs |
| 4 | ODoH Go lang Library            | https://github.com/cloudflare/odoh-go        |
| 5 | ODoH Rust Library               | https://github.com/cloudflare/odoh-rs        |
| 6 | Formal Analysis Model (Tamarin) | https://github.com/cloudflare/odoh-analysis  |
| 7 | Deployed ODoH Target            | https://odoh.cloudflare-dns.com/             |
| 8 | Deployed ODoH Proxy             | https://odoh1.surfdomeinen.nl/               |

### Paper Reference

```bib
@article{singanamalla2021oblivious,
  title={Oblivious DNS over HTTPS (ODoH): A Practical Privacy Enhancement to DNS},
  author={Singanamalla, Sudheesh and Chunhapanya, Suphanat and Hoyland, Jonathan and Vavruša, Marek and Verma, Tanya and Wu, Peter and Fayed, Marwan and Heimerl, Kurtis and Sullivan, Nick and Wood, Christopher},
  journal={Proceedings on Privacy Enhancing Technologies},
  volume={2021},
  number={4},
  pages={TBD--TBD},
  year={2021},
  publisher={Sciendo}
}
```

### Required Build System

The various artifacts require the following packages, tools and compilers to be installed.
The installation commands could change based on the type of machine used. The documentation in this repository
is based on a machine running Ubuntu 20.04. Our tools are built using `golang` and `rust`.

We start with a base Ubuntu 20.04 VM image and run the following:

- Run Update to update the package lists and build the dependency trees.
```shell script
sudo apt update
```

- Install `rustc` the rust compiler and follow the on screen prompts to install the compiler.
- Also install `pkg-config` and `libssl-dev` which are necessary for `odoh-client-rs` builds.

```shell script
sudo apt -y install rustc pkg-config libssl-dev
```

Running the following command will return the version of the compiler installed. We installed `rustc==1.47.0` 
for this artifact evaluation.

```shell script
$ rustc --version
rustc 1.47.0
```

Proceed to install `golang`. For this we use the official go lang `1.16.4` download for Ubuntu Linux `x86-64` with SHA256 checksum `7154e88f5a8047aad4b80ebace58a059e36e7e2e4eb3b383127a28c711b4ff59`
which is available on the [official page](https://golang.org/dl/) at this [direct download link](https://golang.org/dl/go1.16.4.linux-amd64.tar.gz)

The plaintext link for `go==1.16.4` is as follows `https://golang.org/dl/go1.16.4.linux-amd64.tar.gz`

Download the compressed tar file using `wget` and extract it into `/usr/local` using the command below.

```shell script
wget -c https://golang.org/dl/go1.16.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
```

This installs the `go` binary archive at `/usr/local` which can then be added to the `PATH` variable by modifying 
the `~/.profile` and load the new `PATH` environment into the current shell session.

```shell script
export PATH=$PATH:/usr/local/go/bin
source ~/.profile
```

The installation can be verified by running

```shell script
$ go version
go version go1.16.4 linux/amd64
```

We also assume that `git` is already installed. In this artifact we use:

```shell script
$ git --version
git version 2.25.1
```

Install the `build-essential` package which install the necessary packages and build tools like `make`

```shell script
sudo apt install build-essential
```

Verify the `make` installation by running

```shell script
$ make --version
GNU Make 4.2.1
Built for x86_64-pc-linux-gnu
Copyright (C) 1988-2016 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

We provide a shell script `scripts/setup-machine.sh` which installs the necessary build tools.

### Fetching the artifacts and building them

All the artifacts are publicly available and can be downloaded using `git` from `github` hosted repositories.
A shell file `scripts/download-artifacts.sh` is provided to download the artifacts into a directory called `artifacts`
which can be located at `~/artifacts/`. The script can be executed by:

```shell script
$ cd <this repository/scripts/>
$ chmod +x download-artifacts.sh
$ ./download-artifacts.sh
```

Once successfully executed, the following artifacts are available at `~/artifacts/`

```shell script
$ ls -l
total 16
drwxrwxr-x 4 ubuntu ubuntu 4096 <Month> <Time> odoh-analysis/
drwxrwxr-x 6 ubuntu ubuntu 4096 <Month> <Time> odoh-client-go/
drwxrwxr-x 6 ubuntu ubuntu 4096 <Month> <Time> odoh-client-rs/
drwxrwxr-x 4 ubuntu ubuntu 4096 <Month> <Time> odoh-server-go/
```

1. To build and test ODoH Proxies and Targets read [server and proxy build documentation](build-server-proxy.md) in the `build-server-proxy.md` file.
2. To build and test ODoH Clients read [client build documentation](build-clients.md) in the `build-clients.md` file.
3. To deploy the ODoH Server as a Proxy or Target read [server deployment documentation](deploy-server.md) in the `deploy-server.md` file.
