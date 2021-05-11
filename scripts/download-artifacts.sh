set +eax

echo "Changing directory to ~"
cd ~ || exit

echo "Checking if artifacts directory exists"
DIR="artifacts"
if [ -d "$DIR" ]; then
  echo "Directory exists. Changing Directory and Proceeding to fetch artifacts"
else
  echo "Creating directory artifacts and changing present working directory to artifacts"
  mkdir -p artifacts
fi

cd ~/artifacts || exit
echo "Downloading Artifacts"

echo "1. Fetching ODoH Target Server and Proxy"
git clone https://github.com/cloudflare/odoh-server-go
echo "2. Fetching ODoH Go Lang Client which uses odoh-go library"
git clone https://github.com/cloudflare/odoh-client-go
echo "3. Fetching ODoH Rust Client which uses odoh-rs library"
git clone https://github.com/cloudflare/odoh-client-rs
echo "4. Fetching the Formal Analysis of the ODoH Protocol"
git clone https://github.com/cloudflare/odoh-analysis
