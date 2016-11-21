# Outdoor Camera Pi Controller

The Outdoor Camera Pi Controller (OCPIC) is a raspberry Pi project which controls your DSLR for timelapse photography 
and camera sensor trap photography.

This project is the software part of the project. This project enables your smart phone to control you Pi remotely.
You can do the following with this software project:
- control the Pi remotely using your smart phone
- the Pi will act as a wifi hot spot
- read and change settings on your camera
- timelapse photography
- proximity sensor photography
- vibration sensor photography
- view photos on your phone remotely

## Setting up hardware for your Pi

Since we are controlling the Pi remotely, there is no soldering really needed. For my Pi I added a LED and a shutdown 
button, but these are not necessary for this project.

I used a Raspberry Pi 2, I did try with the Raspberry Pi 1 but had stability issues with it. The 2 is much more stable and quicker.

You will need a Wifi Dongle to make your Pi a wifi hotspot. I used a Realtek RTL8188CUS. But any configured correctly should do.

You will need a DSLR and a USB cable to connect your camera to the Raspberry Pi.

If you want your camera to take photos of those critters eating your garbage, you will a proximity sensor and/or a vibration sensor.
I got mine from Amazon, but I dont think it matters which brand or type. The software can help you test the sensors also.

You will also need a power source to power your Pi.

When setting up your Pi you will need a HDMI monitor, keyboard and mouse.

## Setting up software for your Pi

### OS

Setting up the Pi for this project is fairly straight forward. I used the standard Raspian OS for my Pi.

Most of the commands are from terminal. The $ indicates a command to type in the terminal.

### raspi-config
~~~
$ sudo raspi-config
~~~

In Advanced settings:
- Hostname - you may want to choose a hostname for your pi
- SSH - enabled SSH. Its more convenient SSH on your Pi from another machine

To get the IP address for your Pi use:

~~~
$ hostname -I

or

$ ifconfig
~~~

### Installing Ruby

This project uses Ruby and Rails for the web front end. It uses a SQLite database.

#### rbenv

~~~
$ git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
$ echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
$ echo 'eval "$(rbenv init -)"' >> ~/.bashrc
$ git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
~~~

#### Installing Ruby Dependencies

~~~
$ sudo apt-get update
$ sudo apt-get install -y openssl libreadline6-dev git-core zlib1g libssl-dev
$ sudo apt-get install -y libyaml-dev libsqlite3-dev sqlite3
$ sudo apt-get install -y libxml2-dev libxslt-dev
$ sudo apt-get install -y autoconf automake libtool bison
$ sudo apt-get install ruby-dev
~~~

#### Install Ruby

~~~
$ rbenv install -l
$ rbenv install 2.3.0
$ rbenv global 2.3.0
$ rbenv rehash
~~~

#### Rails

~~~
$ sudo apt-get install nodejs
~~~

### DSLR Camera Libraries

~~~
$ sudo apt-get install gphoto2
$ sudo apt-get install imagemagick
~~~

I had some issues with gphoto2 so I followed these steps to fix:

~~~
$ wget https://raw.githubusercontent.com/gonzalo/gphoto2-updater/master/gphoto2-updater.sh && chmod +x gphoto2-updater.sh && sudo ./gphoto2-updater.sh
~~~

### Create SSH keys

~~~
$ ssh-keygen -t rsa -C pi@<hostname>
~~~

### Clone project with Git

~~~
$ mkdir Projects
$ cd Projects
$ git clone https://github.com/RolfLawrenz/ocpic.git

$ gem install bundler
$ bundle install --without development test
~~~

### WIFI module

Edit */etc/network/interfaces* and change file to:

~~~
auto lo
iface lo inet loopback
iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet static
  address 192.168.42.1
  netmask 255.255.255.0
~~~

Edit */etc/dhcpcd.conf* . At end of file add:

~~~
interface wlan0
static ip_address=192.168.1.1/24
static routers=192.168.0.1
static domain_name_servers=8.8.8.8 8.8.4.4
~~~

Edit */etc/default/hostapd*. So the wifi module starts on startup:

~~~
DAEMON_CONF="/etc/hostapd/hostapd.conf"
~~~

Edit */etc/hostapd/hostapd.conf*

~~~
interface=wlan0
driver=rtl871xdrv
ssid=camera_pi
country_code=US
hw_mode=g
channel=6
wmm_enabled=0
wpa=2
wpa_passphrase=raspberry
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
wpa_group_rekey=86400
ieee80211n=1
wme_enabled=1
auth_algs=1
macaddr_acl=0
ignore_broadcast_ssid=0
~~~

### Nginx Passenger module

Install Nginx with Passenger. I install it in the **/opt/nginx** folder

~~~
$ sudo passenger-install-nginx-module
$ cd ~/Projects/ocpic
$ bundle exec gem install passenger
$ sudo apt-get install libcurl4-openssl-dev
$ sudo apt-get update
~~~

To look for errors with nginx installation look at logs at */opt/nginx/logs*

Edit */etc/resolv.conf*

~~~
nameserver 127.0.0.1
~~~

To start nginx:

~~~
$ sudo service nginx start
~~~

To stop nginx:
~~~
$ sudo service nginx stop

Sometimes this does not stop. check if nginx is running:
$ ps -ef | grep nginx

If you see the service running, you will need to kill process:
$ sudo kill <pid number>
~~~

#### Nginx configuration

Edit the */opt/nginx/conf/nginx.conf*

~~~
user  pi;
worker_processes  4;

error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

pid        logs/nginx.pid;


events {
    worker_connections  768;
}


http {
    passenger_root /home/pi/.rbenv/versions/2.3.0/lib/ruby/gems/2.3.0/gems/passenger-5.0.30;
    passenger_ruby /home/pi/.rbenv/versions/2.3.0/bin/ruby;
    passenger_env_var SECRET_KEY_BASE 254a8a58fad8d6581bd37dceec37d2daff49d107080f16de3a4c3525c614c4490ef9a4c7d8$

    include       mime.types;
    default_type  application/octet-stream;

    access_log  logs/access.log;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    server {
        listen       80;
        server_name  localhost;

        #access_log  logs/host.access.log  main;

        #location / {
        #    root   html;
        #    index  index.html index.htm;
        #}

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        #error_page   500 502 503 504  /50x.html;
        #location = /50x.html {
        #    root   html;
        #}

        root /home/pi/Projects/ocpic/public;
        passenger_enabled on;

    }

}
~~~

Useful tool to check status of nginx:

~~~
$ systemctl status nginx.service
~~~

### OCPIC Project

The OCPIC project uses a SQLite database. You will need to create the database:

~~~
$ cd ~/Projects/ocpic
$ RAILS_ENV=production bundle exec rake db:create
$ RAILS_ENV=production bundle exec rake db:migrate
~~~

## Testing the project

Once you have all hardware connected and on. And installed all software you are ready to test.

The Pi has a static address of **192.168.42.1**, but initially you may want to connect the ethernet cable to your Pi.
 
On your pi, check which IP address you have using:
 
~~~
$ hostname -I
192.168.1.89 192.168.42.1 192.168.1.1
~~~

On another machine, you should be able to connect to the Pi using your internal network. This will be the **192.168.1.89**
IP address. In your browser type: **http://192.168.1.89** or whatever your IP address is set to.
You should be able to see the OCPIC project in your browser.

Now you can shutdown the Pi, and remove the ethernet cable.

On your phone go to the wifi settings. Change wifi connection to "camera_pi"

Now open a browser on your phone to **http://192.168.42.1**. Now you should be able to see OCPIC on your phone using the Pi's wifi dongle.

### Trouble shooting

Some places to look for issues:
- nginx logs found in **/opt/nginx/logs**
- project logs found in **~/Project/ocpic/logs**
- Check status of nginx. You may need to kill nginx if it doesnt shutdown properly.
- syslog found in **/var/log/syslog** 

## Using OCPIC
