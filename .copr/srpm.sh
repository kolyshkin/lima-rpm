#!/bin/sh
# Make the SRPM: usage: srpm.sh <outdir> <spec>
#
# Source0 is a git archive of the upstream v<version> tag, created only after
# the tag's signature is verified against lima-keyring.asc. The other sources
# are downloaded and are verified in %prep (%gpgverify of SHA256SUMS.asc).
set -eu

outdir=$1
spec=$2
top=$(dirname "$spec")

for cmd in spectool rpmbuild git gpgv; do
	command -v $cmd >/dev/null || {
		dnf -y install rpmdevtools rpm-build git-core gnupg2
		break
	}
done

name=$(rpmspec -q --srpm --qf '%{name}' "$spec")
version=$(rpmspec -q --srpm --qf '%{version}' "$spec")
tag=v$version

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git clone -q --bare --depth 1 --branch "$tag" https://github.com/lima-vm/lima "$tmp/lima.git"
git -C "$tmp/lima.git" cat-file tag "$tag" >"$tmp/tag"
# A signed tag is the payload followed by a detached signature.
sed '/^-----BEGIN PGP SIGNATURE-----$/,$d' "$tmp/tag" >"$tmp/tag.payload"
sed -n '/^-----BEGIN PGP SIGNATURE-----$/,$p' "$tmp/tag" >"$tmp/tag.sig"
gpg --dearmor <"$top/lima-keyring.asc" >"$tmp/keyring.gpg"
gpgv --keyring "$tmp/keyring.gpg" "$tmp/tag.sig" "$tmp/tag.payload"

# Use only what the signature covers.
grep -qx "type commit" "$tmp/tag.payload"
grep -qx "tag $tag" "$tmp/tag.payload"
commit=$(sed -n 's/^object //p' "$tmp/tag.payload")
git -C "$tmp/lima.git" archive --format=tar.gz --prefix="$name-$version/" \
	-o "$outdir/$name-$version.tar.gz" "$commit"

spectool -g -C "$outdir" "$spec"
cp "$top/lima-keyring.asc" "$outdir/"
rpmbuild -bs \
	--define "_sourcedir $outdir" \
	--define "_srcrpmdir $outdir" \
	"$spec"
