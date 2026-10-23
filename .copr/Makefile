# Used by COPR's "make_srpm" SCM method:
#   make -f .copr/Makefile srpm outdir=<dir> spec=<spec>
# It runs as root in a network-enabled mock chroot.

COPR_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
outdir ?= $(CURDIR)
spec ?= $(CURDIR)
# COPR passes the checkout directory as spec unless the package sets one.
SPEC := $(if $(filter %.spec,$(spec)),$(spec),$(spec)/lima.spec)

.PHONY: srpm
srpm:
	sh $(COPR_DIR)srpm.sh "$(outdir)" "$(SPEC)"
