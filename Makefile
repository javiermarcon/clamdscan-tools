PACKAGE=clamdscan-tools
VERSION:=$(shell dpkg-parsechangelog -S Version 2>/dev/null)
DIST_DIR=dist

.PHONY: build package clean lint sync-version

build:
	$(MAKE) sync-version

sync-version:
	sed -i -E 's#^sudo apt install \./clamdscan-tools_.*_all\.deb$$#sudo apt install ./clamdscan-tools_$(VERSION)_all.deb#' README.md
	sed -i -E 's#^@subtitle Version .*$$#@subtitle Version $(VERSION)#' docs/clamdscan-tools.texi
	sed -i -E 's#^sudo apt install \./clamdscan-tools_.*_all\.deb$$#sudo apt install ./clamdscan-tools_$(VERSION)_all.deb#' docs/clamdscan-tools.texi
	sed -i -E '1s#^\.TH CLAMDSCAN-PROGRESS 1 ".*" "clamdscan-tools .*" "User Commands"$$#.TH CLAMDSCAN-PROGRESS 1 "March 2026" "clamdscan-tools $(VERSION)" "User Commands"#' docs/clamdscan-progress.1
	sed -i -E '1s#^\.TH CLAMDSCAN-WATCH 1 ".*" "clamdscan-tools .*" "User Commands"$$#.TH CLAMDSCAN-WATCH 1 "March 2026" "clamdscan-tools $(VERSION)" "User Commands"#' docs/clamdscan-watch.1
	makeinfo --no-split --output=docs/clamdscan-tools.info docs/clamdscan-tools.texi

package: sync-version
	dpkg-buildpackage -us -uc -b
	rm -rf $(DIST_DIR)
	mkdir -p $(DIST_DIR)
	cp -f ../$(PACKAGE)_$(VERSION)_*.deb $(DIST_DIR)/
	cp -f ../$(PACKAGE)_$(VERSION)_*.buildinfo $(DIST_DIR)/
	cp -f ../$(PACKAGE)_$(VERSION)_*.changes $(DIST_DIR)/

clean:
	rm -f ../$(PACKAGE)_*.build \
	      ../$(PACKAGE)_*.buildinfo \
	      ../$(PACKAGE)_*.changes \
	      ../$(PACKAGE)_*.deb \
	      ../$(PACKAGE)_*.dsc \
	      ../$(PACKAGE)_*.tar.xz \
	      $(DIST_DIR)/*.deb \
	      $(DIST_DIR)/*.buildinfo \
	      $(DIST_DIR)/*.changes \
	      debian/debhelper-build-stamp \
	      debian/files \
	      debian/$(PACKAGE).substvars
	rm -rf debian/.debhelper \
	       debian/$(PACKAGE) \
	       $(DIST_DIR)

lint:
	shellcheck -x bin/clamdscan-progress
	shellcheck -x bin/clamdscan-watch
	shellcheck -x lib/clamdscan-tools.sh
	shellcheck debian/postinst
	shellcheck debian/prerm
	shellcheck debian/postrm
