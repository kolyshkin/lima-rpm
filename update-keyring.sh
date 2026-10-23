#!/bin/sh
# Regenerate lima-keyring.asc: the OpenPGP keys of Lima committers, taken from
# https://github.com/<id>.gpg, keeping only those matching the fingerprints
# published in upstream's governance.md. Keys that do not match are skipped.
set -eu

gov=https://raw.githubusercontent.com/lima-vm/lima/master/website/content/en/docs/community/governance.md

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GNUPGHOME="$tmp/gnupg"
mkdir -m 700 "$GNUPGHOME"

# Table rows look like:
# | Name | Org | Committer | [@id](https://github.com/id) | [C020 EA87 ...](https://github.com/id.gpg) |
curl -fsSL "$gov" | sed -nE 's/.*\[@([A-Za-z0-9-]+)\]\([^)]*\) *\| *\[([0-9A-F ]{40,})\].*/\1 \2/p' |
	while read -r id fpr; do
		fpr=$(echo "$fpr" | tr -d ' ')
		curl -fsSL "https://github.com/$id.gpg" >"$tmp/key"
		gpg -q --import "$tmp/key" 2>/dev/null || true
		if gpg -q --list-keys "$fpr" >/dev/null 2>&1; then
			echo "$fpr" >>"$tmp/ok"
			echo "OK   $id $fpr"
		else
			echo "SKIP $id $fpr (no matching key at https://github.com/$id.gpg)"
		fi
	done

[ -s "$tmp/ok" ] || {
	echo >&2 "no keys found"
	exit 1
}
# shellcheck disable=SC2046 # word splitting is intended
gpg -q --armor --export-options export-minimal --export $(cat "$tmp/ok") >lima-keyring.asc
