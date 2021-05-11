set +eax

# Update package lists
sudo apt update
# Install rust compiler and pkg-config, libssl-dev needed for rustc compilation of the odoh-client-rs
sudo apt -y install rustc pkg-config libssl-dev
# Install the golang compiler and tools (Installs go 1.16.4)
wget -c https://golang.org/dl/go1.16.4.linux-amd64.tar.gz -O - | sudo tar -xz -C /usr/local
export PATH=$PATH:/usr/local/go/bin
# Install essential build tools
sudo apt -y install build-essential

echo "Successfully installed rustc, go and necessary build tools"
