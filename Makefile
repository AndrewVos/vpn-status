all: vpn-status

vpn-status: VPNStatus.vala
	valac VPNStatus.vala --pkg gtk+-3.0 --pkg gio-2.0 --pkg appindicator3-0.1 --output vpn-status

clean:
	rm vpn-status

install: vpn-status
	cp vpn-status /usr/local/bin
