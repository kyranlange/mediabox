# Mediabox

Mediabox is an all Docker Container based media aggregator stack.

Components include:

*   [AudioBookShelf](https://www.audiobookshelf.org)
*   [Deluge torrent client (using VPN)](http://deluge-torrent.org/)
*   [Glances system monitoring](https://nicolargo.github.io/glances/)
*   [Homepage - Server Dashboard](https://github.com/benphelps/homepage)
*   [Jackett Tracker API and Proxy](https://github.com/Jackett/Jackett)
*   [LazyLibrarian Book collection manager](https://lazylibrarian.gitlab.io/)
*   [Lidarr Music collection manager](https://lidarr.audio/)
*   [Kometa](https://kometa.wiki/)
*   [MeTube Web GUI for youtube-dl](https://github.com/alexta69/metube)
*   [Muximux Web based HTPC manager](https://github.com/mescon/Muximux)
*   [NetData System Monitoring](https://github.com/netdata/netdata)
*   [NZBGet Usenet Downloader](https://nzbget.net/)  
*   [Ombi media assistant](http://www.ombi.io/)
*   [Ouroboros Automatic container updater](https://github.com/pyouroboros/ouroboros)
*   [Plex media server](https://www.plex.tv/)
*   [Portainer Docker Container manager](https://portainer.io/)
*   [Radarr movie library manager](https://radarr.video/)
*   [SABnzbd Usenet download tool (using VPN)](https://github.com/sabnzbd/sabnzbd)
*   [Sonarr TV library manager](https://sonarr.tv/)
*   [Speedtest - Tracker](https://github.com/henrywhitaker3/Speedtest-Tracker)
*   [Tautulli Plex Media Server monitor](https://github.com/tautulli/tautulli)

## Prerequisites

*   [Ubuntu 18.04 LTS](https://www.ubuntu.com/)
*   [VPN account from Private internet Access](https://www.privateinternetaccess.com/) (Please see [binhex's Github Repo](https://github.com/binhex/arch-delugevpn) if you want to use a different VPN)
*   [Git](https://git-scm.com/)
*   [Docker](https://www.docker.com/)
*   [Docker-Compose](https://docs.docker.com/compose/)

### **PLEASE NOTE**

For simplicity's sake (eg. automatic dependency management), the method used to install these packages is Ubuntu's default package manager, [APT](https://wiki.debian.org/Apt).  There are several other methods that work just as well, if not better (especially if you don't have superuser access on your system), so use whichever method you prefer.  Continue when you've successfully installed all packages listed.

### Installation

(You'll need superuser access to run these commands successfully)

Start by updating and upgrading our current packages:

`$ sudo apt update && sudo apt full-upgrade`

Install the prerequisite packages:

`$ sudo apt install curl git bridge-utils`

**Note** - Mediabox uses Docker CE as the default Docker version - if you skip this and run with older/other Docker versions you may have issues.

1.  Uninstall old versions - It’s OK if apt and/or snap report that none of these packages are installed.  
    `$ sudo apt remove docker docker-engine docker.io containerd runc`  
    `$ sudo snap remove docker`  

2.  Install Docker CE:  
    `$ curl -fsSL https://get.docker.com -o get-docker.sh`  
    `$ sudo sh get-docker.sh`  

3.  Install Docker-Compose:  

    ```bash
    sudo curl -s https://api.github.com/repos/docker/compose/releases/latest | grep "browser_download_url" | grep -m1 `uname -s`-`uname -m` | cut -d '"' -f4 | xargs sudo curl -L -o /usr/local/bin/docker-compose
    sudo curl -L https://raw.githubusercontent.com/docker/compose/1.24.1/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
    ```

4.  Set the permissions: `$ sudo chmod +x /usr/local/bin/docker-compose`  

5.  Verify the Docker Compose installation: `$ docker-compose --version`  

Add the current user to the docker group:

`$ sudo usermod -aG docker $USER`

Adjustments for the the DelugeVPN container

`$ sudo /sbin/modprobe iptable_mangle`

`$ sudo bash -c "echo iptable_mangle >> /etc/modules"`

Reboot your machine manually, or using the command line:

`$ sudo reboot`

## Using mediabox

Once the prerequisites are all taken care of you can move forward with using mediabox.

1.  Create a user to run mediabox: `$ sudo adduser --no-create-home --shell /bin/false --group --system mediabox`

2.  Add user to the docker group: `$ sudo usermod -aG docker mediabox`

3.  Clone the mediabox repository: `$ git clone git@github.com:kyranlange/mediabox.git`

4.  Move to /opt: `$ sudo mv mediabox /opt/`

5.  Change directory into mediabox: `$ cd /opt/mediabox/`

6.  Add credentials needed for Kometa to `plex-meta-manager/config.yml` - see the [Docker Walkthrough](https://kometa.wiki/en/latest/kometa/install/docker) for more info.

7.  Run the mediabox.sh script: `$ ./mediabox.sh`  (**See below for the script questions**)

8.  To upgrade Mediabox at anytime, re-run the mediabox script: `$ ./mediabox.sh`

### Please be prepared to supply the following details after you run Step 3 above

As the script runs you will be prompted for:

1.  Your Private Internet Access credentials
    *   **username**
    *   **password**

2.  The version of Plex you want to run
    *   **latest**
    *   **public**
    *   **plexpass**

    Note: If you choose plexpass as your version you may optionally specify CLAIM_TOKEN - you can get your claim token by logging in at [plex.tv/claim](https://www.plex.tv/claim)

Upon completion, the script will launch your mediabox containers.

Portainer has been switched to the **CE** branch
* **A Password** will now be required - the password can be set at initial login to Portainer.
* **Initial Username** The initial username for Portainer is **admin**

### **Mediabox has been tested to work on Ubuntu 18.04 LTS / 20.04 LTS - Server**

## Day One Stuff

Once it is up and running, some configuration is required

### Homepage

To enable the widgets to work, some of them require an API key. To supply the API key, edit `homepage/services.yaml`. See https://gethomepage.dev/en/configs/service-widgets/ for information on how to get each of the API keys.

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
