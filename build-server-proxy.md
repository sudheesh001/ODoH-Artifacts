## Building and Running the `odoh-server-go` repository

The `odoh-server-go` repository contains the `ODoH Proxy` and an implementation of the `ODoH Target` written in golang 
and can be built by using `make`.

```shell script
$ make  # Fetches the necessary go modules and runs unit tests
$ make all  # Builds the binary odoh-server
```

One of the main causes of build failure could be memory availability. An AWS `t2.small` equivalent is the minimum
recommended configuration to successfully to run the builds.

Before executing the server, it is necessary to acquire a TLS certificate. `mkcert` is a tool to make development certificates locally
This can be installed by running the following which installs `certutil` and `homebrew` for Linux:

```shell script
sudo apt install libnss3-tools
sudo apt-get install build-essential procps curl file git
mkdir -p ~/.linuxbrew/
mkdir ~/.linuxbrew/bin
git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
eval $(~/.linuxbrew/bin/brew shellenv)
brew install hello  # To test correct installation of homebrew for linux
brew install mkcert  # Install mkcert
```

A one time dependency installation and build script for the server is provided at `scripts/build-odoh-server.sh`

Once `mkcert` is installed, create a new local CA with a certificate valid for `localhost` and `127.0.0.1` by running

```shell script
$ mkcert -key-file key.pem -cert-file cert.pem 127.0.0.1 localhost
```

This will create `key.pem` and `cert.pem` in the same directory with a valid certificate.

The ODoH proxy and target are now ready to run. This command runs the proxy and target services at `PORT=4567` on the machine.

```shell script
CERT=cert.pem KEY=key.pem PORT=4567 ./odoh-server
```