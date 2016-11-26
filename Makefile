all: vpn-status

vpn-status: VPNStatus.vala
	valac VPNStatus.vala --pkg gtk+-3.0 --pkg gio-2.0 --pkg appindicator3-0.1 --output vpn-status

clean:
	rm vpn-status

install: vpn-status
	cp vpn-status /usr/local/bin

package: vpn-status
	fpm -s dir -t deb -n vpn-status -v 0.0.1 \
		./vpn-status=/usr/bin/vpn-status \
		./vpn-encrypted.svg=/usr/share/icons/vpn-status/vpn-encrypted.svg \
		./vpn-unencrypted.svg=/usr/share/icons/vpn-status/vpn-unencrypted.svg
