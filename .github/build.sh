#!/bin/sh
# Build ./lima.spec the way COPR does (make_srpm, then a binary rebuild).
# Runs as root in a Fedora container.
set -eu

dnf -y builddep lima.spec
# limactl (run in %check) refuses to run as root.
id builder >/dev/null 2>&1 || useradd -m builder
runuser -u builder -- sh -ec '
	rm -rf "$HOME/srpm"
	make -f "$1/.copr/Makefile" srpm outdir="$HOME/srpm" spec="$1/lima.spec"
	rpmbuild --rebuild "$HOME"/srpm/*.src.rpm
' sh "$PWD"
