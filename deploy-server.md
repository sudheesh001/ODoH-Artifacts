# Deploying Own Targets/Proxies

For a deployment, the `odoh-server-go` needs to be provisioned with a valid certificate and could be run behind a proxy or a web server.
In this document, we detail out the procedure to deploy the `odoh-server-go` repository after successful [build and run](build-server-proxy.md).

## Infrastructure as a Service (IaaS) Deployments

### Installing the required tools and server

We present various webserver based deployments when setting up the proxies or targets.

### NGINX based Deployment

Use the following command to install `nginx` which we use as a reverse proxy.

```shell script
sudo apt install nginx
```

Validate the installtion of `nginx` by running:
```shell script
$ systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2021-05-11 16:45:55 UTC; 14s ago
       Docs: man:nginx(8)
   Main PID: 21026 (nginx)
      Tasks: 2 (limit: 2368)
     Memory: 6.5M
     CGroup: /system.slice/nginx.service
             ├─21026 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             └─21027 nginx: worker process

<Month Day> <HH:MM:SS> <machine> systemd[1]: Starting A high performance web server and a reverse proxy server...
<Month Day> <HH:MM:SS> <machine> systemd[1]: Started A high performance web server and a reverse proxy server.
```

After correctly configuring any firewalls and exposing ports `80` and `443` navigate using the browser to the server.
On successful configuration, the default nginx server will respond with the content:

```text
Welcome to nginx!
If you see this page, the nginx web server is successfully installed and working. Further configuration is required.

For online documentation and support please refer to nginx.org.
Commercial support is available at nginx.com.

Thank you for using nginx.
```

Now modify the `server` block in `default` configuration file for `nginx` available at `/etc/nginx/sites-available/` 

```nginx
location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        # try_files $uri $uri/ =404;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_pass https://127.0.0.1:4567;  # Port bound to the target service
}
```

This configures the root `/` of the webserver and proxies the requests to `https://127.0.01:4567` where the ODoH target
and proxy services are running as described in [build and run instructions](build-server-proxy.md).

Save the changes in the `default` configuration and restart `nginx` and ensure that the servers are running correctly.

```shell script
$ sudo systemctl restart nginx
$ systemctl status nginx
```

If successfully configured, navigating to the public IP/hostname of the machine would show a page served over `http` with the contents:

```text
ODOH service
----------------
Proxy endpoint: https://<server-hostname-or-ip-address>/proxy{?targethost,targetpath}
Target endpoint: https://<server-hostname-or-ip-address>/dns-query{?dns}
----------------
```

Once the reverse proxy through nginx are configured correctly, it becomes important to set up valid `https` certificates
to be served by the web server. The easiest way to request a certificate would be using EFF's `certbot` which provisions a
`Let's Encrypt` issued certificate.

The installation of `certbot` relies on `snapd`. The following script ensures that `snapd` is upto date before installing
the `certbot` tools.

```shell script
$ sudo snap install core; sudo snap refresh core
$ sudo snap install --classic certbot
$ sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

Once installed and with the default `nginx` configurations. `certbot` makes it easy to get and install certificates:

```shell script
sudo certbot --nginx
```

Follow the installer and enter a valid `email` followed by accepting the terms and conditions and additionally providing
consent to EFF to send promotional emails if necessary.

The installer then requests valid domain name(s) (space separated) and configures a TLS certificate enabling the `https` endpoints.


| :warning:  | Note: Let's Encrypt prevents certificate issuance to `*.compute.amazonaws.com`. |
|------------|---------------------------------------------------------------------------------|
|            | A possible option is to:                                                        |
|            | - configure a self-signed certificate for `nginx` and proxy it through a CDN service by setting up DNS record pointing to the machine                        |
|            | -Set up a DNS name to the VM and obtain the let's encrypt certificate from let's encrypt for the subdomain.                                                  |


```text
DNS Record Configuration
Type        : A
Name        : <yourchoice> eg. odohproxy
IPv4 Address: <IP Address>


$ sudo certbot --nginx 
hostname: odohproxy.yourdomain.com   # if Name: odohproxy
 ``` 

Once setup correctly, you can issue the `odoh-client` commands without the `--customcert` flags.

```shell script
$ ./odoh-client odoh --domain www.example.com. --dnstype AAAA --proxy odohproxy.yourdomain.com --target odoh.cloudflare-dns.com
```

### Caddy Based Deployment

Caddy is another popularly used web server which simplifies `https` based deployments. Fetch the required caddy services
by first adding the GPG Key to key ring.

```shell script
$ sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
$ curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo apt-key add -
$ curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
$ sudo apt update
$ sudo apt install caddy
```

This installs caddy with the necessary modules and runs the caddy server on port 80. Use the `reverse-proxy` module by running:

```shell script
$ systemctl status caddy
● caddy.service - Caddy
     Loaded: loaded (/lib/systemd/system/caddy.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2021-05-11 18:22:48 UTC; 4min 29s ago
       Docs: https://caddyserver.com/docs/
   Main PID: 23313 (caddy)
      Tasks: 6 (limit: 2368)
     Memory: 9.6M
     CGroup: /system.slice/caddy.service
             └─23313 /usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
```

Modify the default configuration file at `/etc/caddy/Caddyfile` to look as follows:

```caddy
# odohproxy is the subdomain configured to point to the server on yourdomain.com.
# Modify as necessary. Caddy automatically retrieves a certificate and enables automatic https.
odohproxy.yourdomain.com:443 {
        # Set this path to your site's directory.
        root * /usr/share/caddy

        # Enable/Disable the static file server.
        file_server

        # Set up a reverse proxy to proxy requests to the odoh-server proxy and target
        # services running at 127.0.0.1:4567. The tls_insecure_skip_verify is needed
        # to allow https --> https proxying since the local requests from caddy proxy
        # to the odoh-server are https but use a custom CA certificate.
        reverse_proxy 127.0.0.1:4567 {
                transport http {
                        tls
                        tls_insecure_skip_verify
                }
        }

        # Or serve a PHP site through php-fpm:
        # php_fastcgi localhost:9000
}
```


## Platform as a Service (PaaS) Deployments

### Google App Engine (GAE)

The `odoh-server` can be installed on GAE using `make deploy-proxy` or `make deploy-target` after the correct `gcloud` configurations locally. An example deployment is available at: https://odoh-proxy-dot-odoh-target.wm.r.appspot.com/ which can be used as a `proxy`

### Heroku and Scalingo Deployments

Heroku and Scalingo allow the usage of easy deploy buttons and can also be deployed by browsing to:

```text
https://www.heroku.com/deploy/?template=https://github.com/cloudflare/odoh-server-go
https://my.scalingo.com/deploy?source=https://github.com/cloudflare/odoh-server-go
```

or by clicking the buttons below.

| Heroku Deployment | Scalingo Deployment |
| ------------------|---------------------|
| [![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://www.heroku.com/deploy/?template=https://github.com/cloudflare/odoh-server-go) | [![Deploy](https://cdn.scalingo.com/deploy/button.svg)](https://my.scalingo.com/deploy?source=https://github.com/cloudflare/odoh-server-go) |
