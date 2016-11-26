# vpn-status

Gtk Application for elementary OS that shows a red status icon when your VPN gets disconnected

![https://github.com/AndrewVos/vpn-status/blob/master/screenshot.png](https://github.com/AndrewVos/vpn-status/blob/master/screenshot.png)

# Install

```
sudo apt-get install valac gio-2.0 libappindicator3-dev libgtk-3-dev libgranite-dev
# only required to build package
gem install fpm

git clone https://github.com/AndrewVos/vpn-status
cd vpn-status
make package
sudo dpkg -i *.deb
```
