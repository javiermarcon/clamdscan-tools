PACKAGE=clamdscan-tools

.PHONY: build clean lint

build:
	debuild -us -uc

clean:
	debclean || true
	rm -f ../$(PACKAGE)_*.build \
	      ../$(PACKAGE)_*.buildinfo \
	      ../$(PACKAGE)_*.changes \
	      ../$(PACKAGE)_*.deb

lint:
	shellcheck -x bin/clamdscan-progress
	shellcheck -x bin/clamdscan-watch
	shellcheck -x lib/clamdscan-tools.sh
	shellcheck debian/postinst
	shellcheck debian/prerm
	shellcheck debian/postrm
