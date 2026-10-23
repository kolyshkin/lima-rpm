# lima-rpm

[![COPR build status](https://copr.fedorainfracloud.org/coprs/kir/lima/package/lima/status_image/last_build.png)](https://copr.fedorainfracloud.org/coprs/kir/lima/package/lima/)

RPM packaging of [Lima](https://lima-vm.io) for Fedora, built in COPR:
<https://copr.fedorainfracloud.org/coprs/kir/lima/>.

```
sudo dnf copr enable kir/lima
sudo dnf install lima
```

`lima-additional-guestagents` (installed by default as a weak dependency) has
guest agents for running VMs of a foreign architecture.

## How it is updated

A scheduled GitHub Actions workflow checks for a new upstream release, bumps
`lima.spec`, test-builds it, and pushes. Each push triggers a COPR rebuild via
webhook; COPR makes the SRPM with `.copr/Makefile`.

## Source verification

- The source tarball is a `git archive` of the upstream `v<version>` tag,
  made by `.copr/srpm.sh` only after the tag's signature checks out.
- `go-mod-vendor.tar.gz` is checked in `%prep` against upstream's `SHA256SUMS`,
  whose signature (`SHA256SUMS.asc`) is checked with `%gpgverify`.

Both use `lima-keyring.asc`: keys of Lima committers whose fingerprints match
upstream's [governance.md](https://github.com/lima-vm/lima/blob/master/website/content/en/docs/community/governance.md).
Regenerate it with `./update-keyring.sh` when the list of committers changes.
