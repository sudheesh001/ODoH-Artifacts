## Formal Analysis (`odoh-analysis`)

Building and running the formal analysis requires the Tamarin prover which can be installed by
running the following after installing `homebrew` on Linux `linuxbrew` as required to build the ODoH server.

```shell script
eval $(~/.linuxbrew/bin/brew shellenv)
brew install tamarin-prover/tap/tamarin-prover
``` 

The binary can also be directly obtained from the github release v1.6.0 `a631d75` release

```shell script
wget https://github.com/tamarin-prover/tamarin-prover/releases/download/1.6.0/tamarin-prover-1.6.0-linux64-ubuntu.tar.gz
tar -xzf tamarin-prover-1.6.0-linux64-ubuntu.tar.gz
export PATH=$PATH:`pwd`
```

Install `m4` and `maude` by running

```shell script
sudo apt install m4 maude
```

The proofs can be analyzed by running:

```shell script
make
make proofs
```