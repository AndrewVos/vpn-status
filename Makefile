all: vpn-status

# Dependencies:
# valac
# gio-2.0
# libappindicator3-dev
# libgtk-3-dev
vpn-status: VPNStatus.vala
	valac VPNStatus.vala --pkg gtk+-3.0 --pkg gio-2.0 --pkg appindicator3-0.1 --output vpn-status

clean:
	rm vpn-status
