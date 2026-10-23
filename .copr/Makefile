# Used by COPR's "make_srpm" SCM method:
#   make -f .copr/Makefile srpm outdir=<dir> spec=<spec>
# It runs as root in a network-enabled mock chroot.

outdir ?= $(CURDIR)
spec ?= $(CURDIR)/lima.spec

.PHONY: srpm
srpm:
	dnf -y install rpmdevtools rpm-build
	spectool -g -C $(outdir) $(spec)
	rpmbuild -bs \
		--define "_sourcedir $(outdir)" \
		--define "_srcrpmdir $(outdir)" \
		$(spec)
