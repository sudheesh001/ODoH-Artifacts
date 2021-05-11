set +eax

sudo apt install libnss3-tools
sudo apt-get install build-essential procps curl file git
mkdir -p ~/.linuxbrew/
mkdir ~/.linuxbrew/bin
git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew
ln -s ~/.linuxbrew/Homebrew/bin/brew ~/.linuxbrew/bin
eval $(~/.linuxbrew/bin/brew shellenv)
brew install hello  # To test correct installation of homebrew for linux
brew install mkcert

cd ~/artifacts/odoh-server-go || exit
make
make all
