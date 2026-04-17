# Giphy Matrix Proxy

A Matrix media proxy server and sticker picker widget for Matrix clients. Based on [maunium/stickerpicker](https://github.com/maunium/stickerpicker/), this project serves Giphy GIFs through Matrix-compatible media endpoints and can also expose local image files from the server.

## Features

- Giphy search and trending endpoints proxied through the backend
- Matrix-compatible `mxc://` media IDs for Giphy and local files
- Built-in web sticker picker UI for Element and other Matrix clients
- Optional local image library from `storage_path`
- MSC3860/MSC3916 media download redirect support
- Docker deployment support
- Coolify deployment support via `docker-compose.coolify.yml`

## Prerequisites

- Docker and Docker Compose
- A domain name with DNS configured
- Giphy API key (get one at https://developers.giphy.com/)

## Installation

1. Clone this repository:

```bash
git clone https://github.com/yourusername/giphytenormatrixproxy.git
cd giphytenormatrixproxy
```

2. Generate a server signing key:

```bash
docker build -t giphytenormatrixproxy giphytenormatrixproxy
docker run --rm giphytenormatrixproxy -generate-key
```

3. Create your configuration file:

```bash
cp example-config.yaml config.yaml
```

4. Edit `config.yaml`.
Required values:
- `server_name`: the Matrix server name this proxy should serve as, for example `giphy.example.com`
- `server_key`: the signing key generated in the previous step
- `giphy_api_key`: your Giphy API key

Optional values:
- `storage_path`: directory for local images
- `locale`: locale used for Giphy API requests
- `gif_path`: path used for serving redirected media
- `index_path`: custom path for the picker UI
- `destination`: alternate media redirect template if you want something other than Giphy WebP URLs

5. Start the service with Docker Compose:

```bash
docker compose up -d
```

## Docker Compose with Reverse Proxy

An example `docker-compose.yml` is included for running behind an external reverse proxy such as Traefik.

Typical setup:
- mount `config.yaml` to `/data/config.yaml`
- mount a storage directory to `/storage` if you want local files
- expose the container internally on port `8008`
- route your public domain to that container through your reverse proxy

The service expects:
```env
MATRIX_MEDIA_DOMAIN=mediaproxy.example.com
NETWORK_NAME=matrix
CONFIG_PATH=./config.yaml
STORAGE_PATH=./storage
```

Then run:
```bash
cp .env.example .env
docker compose up -d
```

## Coolify

This repository includes a dedicated Coolify compose file: [docker-compose.coolify.yml](/home/eelzahar/giphytenormatrixproxy/docker-compose.coolify.yml).

Use it as a Docker Compose application in Coolify and set at least these variables in the Coolify UI:
- `SERVER_NAME`
- `SERVER_KEY`
- `GIPHY_API_KEY`

Optional variables:
- `ALLOW_PROXY` defaults to `false`
- `LOCALE` defaults to `en_US`

What the Coolify setup does:
- builds from `./giphytenormatrixproxy/Dockerfile`
- writes `/data/config.yaml` from `CONFIG_TEMPLATE`
- starts the app through `/usr/local/bin/start.sh`
- persists local files in `./storage` mounted at `/storage`

The app listens on container port `8008`. Keep using Coolify's proxying; you do not need to add host port mappings just for that.

## Example Configuration

See [example-config.yaml](/home/eelzahar/giphytenormatrixproxy/example-config.yaml) for the full config. Minimal example:

```yaml
server_name: giphy.example.com
allow_proxy: false
server_key: YOUR_GENERATED_SERVER_KEY
hostname: 0.0.0.0
port: 8008
giphy_api_key: YOUR_GIPHY_API_KEY
locale: en_US
gif_path: /gif/
index_path: /
storage_path: /storage
```

## Usage

1. Configure your Matrix client to use the proxy:
- Set up `.well-known` delegation for your domain, or
- Directly proxy your domain to this service

2. Access the picker UI at `https://your-domain/`

3. If `storage_path` contains image files, the UI will show a local files tab alongside the Giphy tabs.

## Matrix Client Integration

To integrate the GIF picker into your Element Matrix client:

1. In Element, use the `/devtools` command
2. Select "Explore Account Data"
3. Set the following data for the key `m.widgets`:

```json
{
  "stickerpicker": {
    "content": {
      "type": "m.stickerpicker",
      "url": "https://your.domain.here/?theme=$theme",
      "name": "Stickerpicker",
      "creatorUserId": "@your-user-id:your.domain.here",
      "data": {}
    },
    "sender": "@your-user-id:your.domain.here",
    "state_key": "stickerpicker",
    "type": "m.widget",
    "id": "stickerpicker"
  }
}
```
4. Replace `your.domain.here` with your proxy's domain and `your-user-id` with your Matrix ID
5. After saving, you should now see a GIF button in your message composer

You may need to refresh Element or reload the page for changes to take effect.

## Configuration Options

See [example-config.yaml](/home/eelzahar/giphytenormatrixproxy/example-config.yaml) for all available configuration options and inline comments.

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0). This is a derivative work based on [maunium/stickerpicker](https://github.com/maunium/stickerpicker/), which is also licensed under AGPL-3.0.

For more information, see:
- [LICENSE](LICENSE) file in this repository
- [maunium/stickerpicker](https://github.com/maunium/stickerpicker/) original project
- [GNU AGPL-3.0 License](https://www.gnu.org/licenses/agpl-3.0.en.html)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Make sure to follow the AGPL-3.0 license requirements when contributing.
