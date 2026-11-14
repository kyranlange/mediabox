# Mediabox

Mediabox is an all Docker Container based media aggregator stack.

Components include:

*   [AudioBookShelf](https://www.audiobookshelf.org)
*   [Deluge torrent client (using VPN)](http://deluge-torrent.org/)
*   [Docker Socket Proxy](https://github.com/Tecnativa/docker-socket-proxy)
*   [Flaresolverr proxy server to bypass Cloudflare protection (Used with Jackett)](https://github.com/FlareSolverr/FlareSolverr)
*   [Glances system monitoring](https://nicolargo.github.io/glances/)
*   [Homepage - Server Dashboard](https://github.com/benphelps/homepage)
*   [Jackett Tracker API and Proxy](https://github.com/Jackett/Jackett)
*   [Jellyfin Free Software Media System](https://github.com/jellyfin/jellyfin)
*   [LazyLibrarian Book collection manager](https://lazylibrarian.gitlab.io/)
*   [Lidarr Music collection manager](https://lidarr.audio/)
*   [Kometa](https://kometa.wiki/)
*   [Kometa Quickstart](https://kometa.wiki/en/latest/kometa/scripts/quickstart/)
*   [MeTube Web GUI for youtube-dl](https://github.com/alexta69/metube)
*   [NetData System Monitoring](https://github.com/netdata/netdata)
*   [Ombi media assistant](http://www.ombi.io/)
*   [WUD - What's Up Docker](https://getwud.app/)
*   [Plex media server](https://www.plex.tv/)
*   [Portainer Docker Container manager](https://portainer.io/)
*   [Radarr movie library manager](https://radarr.video/)
*   [SABnzbd Usenet download tool (using VPN)](https://github.com/sabnzbd/sabnzbd)
*   [Sonarr TV library manager](https://sonarr.tv/)
*   [Speedtest - Tracker](https://github.com/henrywhitaker3/Speedtest-Tracker)
*   [Tautulli Plex Media Server monitor](https://github.com/tautulli/tautulli)

## Prerequisites

*   [Ubuntu Server](https://ubuntu.com/download/server) on a release supported by Docker Engine
*   [VPN account from Private internet Access](https://www.privateinternetaccess.com/) (Please see [binhex's Github Repo](https://github.com/binhex/arch-delugevpn) if you want to use a different VPN)
*   [Git](https://git-scm.com/)
*   [Docker Engine](https://docs.docker.com/engine/install/ubuntu/)
*   [Docker Compose plugin](https://docs.docker.com/compose/install/linux/)

### **PLEASE NOTE**

`mediabox.sh` uses the modern `docker compose` command and requires the Docker Compose plugin. The script does not install or update Docker components; update Docker Engine and Compose through the system package manager.

### Installation

Follow Docker's official instructions to install [Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/) and the [Docker Compose plugin](https://docs.docker.com/compose/install/linux/). If Docker is already installed, follow Docker's instructions for resolving conflicting packages instead of removing packages blindly.

Install Git, curl, and OpenSSL, then verify the Compose plugin:

```bash
sudo apt update
sudo apt install curl git openssl
docker compose version
```

The DelugeVPN container may require the `iptable_mangle` kernel module:

`$ sudo /sbin/modprobe iptable_mangle`

`$ sudo bash -c "echo iptable_mangle >> /etc/modules"`

Reboot your machine manually, or using the command line:

`$ sudo reboot`

## Using Mediabox

Once the prerequisites are all taken care of you can move forward with using mediabox.

1.  Create the `mediabox` system account used as the container UID/GID: `$ sudo adduser --no-create-home --shell /bin/false --group --system mediabox`

2.  Add the `mediabox` account and the account you will use to run the setup script to the Docker group:

    ```bash
    sudo usermod -aG docker mediabox
    sudo usermod -aG docker "$USER"
    ```

    Log out and back in so the new group membership takes effect. Membership in the Docker group grants root-equivalent access to the host.

3.  Clone the repository and move it to `/opt`:

    ```bash
    git clone https://github.com/kyranlange/mediabox.git
    sudo mv mediabox /opt/
    cd /opt/mediabox/
    ```

4.  Configure Kometa in `plex-meta-manager/config.yml`, or use Kometa Quickstart at `http://<IP_ADDRESS>:7171`. See the [Kometa Quickstart guide](https://kometa.wiki/en/latest/kometa/scripts/quickstart/) for setup details.

5.  Run `mediabox.sh` as the non-root account that owns the checkout and has Docker access. Do not run it with `sudo`; the script exits if run as root. The script uses the `mediabox` account's UID/GID for containers.

6.  To upgrade Mediabox, run `./mediabox.sh` again as the same non-root account.

### Setup prompts

On first setup, the script prompts for:

1.  Your Private Internet Access credentials
    *   **username**
    *   **password**

2.  The version of Plex you want to run
    *   **latest**
    *   **public**
    *   **plexpass**

    Note: If you choose plexpass as your version you may optionally specify CLAIM_TOKEN - you can get your claim token by logging in at [plex.tv/claim](https://www.plex.tv/claim)

3.  Paths for downloads, TV, miscellaneous files, movies, music, books, and podcasts. Press Enter to use directories created under the repository.

4.  A PIA server that supports port forwarding.

5.  A username and password for the Deluge daemon.

During upgrades, the script asks whether to keep the configured media paths, Plex release, and PIA credentials.

Upon completion, the script launches the Mediabox containers.

Portainer CE is included. Set an administrator password on first login.

## Day One Stuff

Once it is up and running, some configuration is required

### Homepage

Some Homepage widgets require API keys. Add them to `prep/services.yaml`; the setup script copies this template to `homepage/services.yaml` each time it runs. See the [Homepage widget documentation](https://gethomepage.dev/widgets/) for details.

### WUD

WUD checks container images every six hours and automatically updates Compose-managed containers. It backs up changes to `docker-compose.yml.back` and removes unused old images after successful updates. Open the dashboard at `http://<IP_ADDRESS>:3000`; the initial username is `admin`, and the generated password is stored in `wud/.env`. Keep the dashboard on a trusted network.

### Kometa Quickstart

Kometa Quickstart is available at `http://<IP_ADDRESS>:7171`. Its application data is stored in `kometa-quickstart/`; the existing Kometa configuration is mounted at `/kometa-config`. To work with the configuration used by the Kometa container, choose Quickstart's external/containerized config mode and set its config path to `/kometa-config`. Kometa continues to run in its separate container. Keep port 7171 on a trusted network; do not expose it directly to the internet.

## Thanks

**Thanks go out to:**

[@tom472](https://github.com/tom472/mediabox) - Started and continues to improve this project - the majority of this is from them.

[binhex](https://github.com/binhex)

[LinuxServer.io](https://github.com/linuxserver)

[Docker](https://github.com/docker)


---

If you enjoy the project -- Fuel it with some caffeine :)

[![Donate](https://img.shields.io/badge/Donate-SquareCash-brightgreen.svg)](https://cash.me/$TomMorgan)

---

## Disclaimer

THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## License

MIT License

Copyright (c) 2017 Tom Morgan

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
