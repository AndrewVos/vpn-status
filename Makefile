all: vpn-status

# apt-get install valac gio-2.0
vpn-status: VPNStatus.vala
	valac VPNStatus.vala --pkg gio-2.0 --output vpn-status

clean:
	rm vpn-status
