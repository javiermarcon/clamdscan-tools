PACKAGE=clamdscan-tools
VERSION:=$(shell dpkg-parsechangelog -S Version 2>/dev/null)
RELEASE_VERSION:=$(shell printf '%s\n' "$(VERSION)" | sed 's/[+~].*$$//')
DIST_DIR=dist
LATEST_TAG:=$(shell git describe --tags --abbrev=0 --match 'v*' 2>/dev/null || true)
EXPECTED_TAG=v$(RELEASE_VERSION)
DEB_FULLNAME=Javier Marcon
DEB_EMAIL=javiermarcon@gmail.com

.PHONY: build package clean lint sync-version check-version release-tag changelog ppa-source ppa-upload source-tarball

build:
	$(MAKE) sync-version

sync-version:
	sed -i -E 's#^sudo apt install \./clamdscan-tools_.*_all\.deb$$#sudo apt install ./clamdscan-tools_$(VERSION)_all.deb#' README.md
	sed -i -E 's#^tar -xzf clamdscan-tools-.*\.tar\.gz$$#tar -xzf clamdscan-tools-$(RELEASE_VERSION).tar.gz#' README.md
	sed -i -E 's#^cd clamdscan-tools-.*$$#cd clamdscan-tools-$(RELEASE_VERSION)#' README.md
	sed -i -E 's#^@subtitle Version .*$$#@subtitle Version $(VERSION)#' docs/clamdscan-tools.texi
	sed -i -E 's#^sudo apt install \./clamdscan-tools_.*_all\.deb$$#sudo apt install ./clamdscan-tools_$(VERSION)_all.deb#' docs/clamdscan-tools.texi
	sed -i -E 's#^sudo apt install \./clamdscan-tools_.*_all\.deb$$#sudo apt install ./clamdscan-tools_$(VERSION)_all.deb#' docs-site/install.md
	sed -i -E 's#^tar -xzf clamdscan-tools-.*\.tar\.gz$$#tar -xzf clamdscan-tools-$(RELEASE_VERSION).tar.gz#' docs-site/install.md
	sed -i -E 's#^cd clamdscan-tools-.*$$#cd clamdscan-tools-$(RELEASE_VERSION)#' docs-site/install.md
	sed -i -E '1s#^\.TH CLAMDSCAN-PROGRESS 1 ".*" "clamdscan-tools .*" "User Commands"$$#.TH CLAMDSCAN-PROGRESS 1 "March 2026" "clamdscan-tools $(VERSION)" "User Commands"#' docs/clamdscan-progress.1
	sed -i -E '1s#^\.TH CLAMDSCAN-WATCH 1 ".*" "clamdscan-tools .*" "User Commands"$$#.TH CLAMDSCAN-WATCH 1 "March 2026" "clamdscan-tools $(VERSION)" "User Commands"#' docs/clamdscan-watch.1
	makeinfo --no-split --output=docs/clamdscan-tools.info docs/clamdscan-tools.texi

check-version:
	@if [ -n "$(LATEST_TAG)" ] && [ "$(LATEST_TAG)" != "$(EXPECTED_TAG)" ]; then \
	  echo "ERROR: debian/changelog está en $(VERSION), pero el último tag es $(LATEST_TAG)." >&2; \
	  echo "ERROR: actualizá debian/changelog o creá el tag correcto antes de correr make package." >&2; \
	  exit 1; \
	fi

release-tag:
	@if git rev-parse "$(EXPECTED_TAG)" >/dev/null 2>&1; then \
	  echo "ERROR: el tag $(EXPECTED_TAG) ya existe." >&2; \
	  exit 1; \
	fi
	git tag -a "$(EXPECTED_TAG)" -m "Release $(EXPECTED_TAG)"

changelog:
	@if [ -z "$(NEW_VERSION)" ]; then \
	  echo "ERROR: usá make changelog NEW_VERSION=X.Y.Z MSG='texto del cambio'" >&2; \
	  exit 1; \
	fi
	@DEBFULLNAME="$(DEB_FULLNAME)" DEBEMAIL="$(DEB_EMAIL)" \
	  dch -v "$(NEW_VERSION)" "$(if $(MSG),$(MSG),Update changelog)"

ppa-source:
	@DEBFULLNAME="$(DEB_FULLNAME)" DEBEMAIL="$(DEB_EMAIL)" \
	  bash packaging/launchpad/build-source.sh

ppa-upload:
	@bash packaging/launchpad/upload-source.sh

source-tarball:
	@bash packaging/tarball/build-tarball.sh

package: sync-version check-version
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
