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
