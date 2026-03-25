PACKAGE=clamdscan-tools

.PHONY: build package clean lint

build:
	@echo "No build step required for this project."

package:
	dpkg-buildpackage -us -uc -b

clean:
	rm -f ../$(PACKAGE)_*.build \
	      ../$(PACKAGE)_*.buildinfo \
	      ../$(PACKAGE)_*.changes \
	      ../$(PACKAGE)_*.deb \
	      ../$(PACKAGE)_*.dsc \
	      ../$(PACKAGE)_*.tar.xz \
	      debian/debhelper-build-stamp \
	      debian/files \
	      debian/$(PACKAGE).substvars
	rm -rf debian/.debhelper \
	       debian/$(PACKAGE)

lint:
	shellcheck -x bin/clamdscan-progress
	shellcheck -x bin/clamdscan-watch
	shellcheck -x lib/clamdscan-tools.sh
	shellcheck debian/postinst
	shellcheck debian/prerm
	shellcheck debian/postrm
