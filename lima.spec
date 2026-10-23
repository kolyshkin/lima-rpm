# Binaries are built by the upstream Makefile with -s -w (no symbols, no DWARF),
# so there is nothing to put into a debuginfo package.
%global debug_package %{nil}
%global _missing_build_ids_terminate_build 0

Name:           lima
Version:        2.2.1
Release:        1%{?dist}
Summary:        Linux virtual machines with automatic file sharing and port forwarding

License:        Apache-2.0
URL:            https://lima-vm.io
Source0:        https://github.com/lima-vm/lima/archive/v%{version}/%{name}-%{version}.tar.gz
# Upstream-provided go.mod/go.sum/vendor, so that the build works offline.
Source1:        https://github.com/lima-vm/lima/releases/download/v%{version}/%{name}-%{version}-go-mod-vendor.tar.gz

# Upstream only supports these Linux hosts.
ExclusiveArch:  x86_64 aarch64

BuildRequires:  golang >= 1.26
BuildRequires:  gcc
BuildRequires:  make

Requires:       qemu-img
Requires:       openssh-clients
%ifarch x86_64
Requires:       qemu-system-x86-core
Requires:       edk2-ovmf
%endif
%ifarch aarch64
Requires:       qemu-system-aarch64-core
Requires:       edk2-aarch64
%endif
Recommends:     %{name}-additional-guestagents = %{version}-%{release}

%description
Lima launches Linux virtual machines with automatic file sharing and port
forwarding (similar to WSL2). It is often used for running containerd,
Docker, Podman or Kubernetes, but can also run arbitrary distributions.

%package additional-guestagents
Summary:        Lima guest agents for non-native guest architectures
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description additional-guestagents
Guest agents for running Lima virtual machines of a foreign architecture
(emulated with QEMU TCG), e.g. aarch64 guests on an x86_64 host.

%prep
%autosetup -p1
# Overwrites go.mod and go.sum with the ones matching vendor/.
tar -xzf %{SOURCE1}

%build
export GOFLAGS=-mod=vendor GOTOOLCHAIN=local GOPROXY=off
make VERSION=v%{version} PREFIX=%{_prefix} binaries manpages

%install
make VERSION=v%{version} PREFIX=%{_prefix} DESTDIR=%{buildroot} install

%ifarch x86_64
%global native_ga Linux-x86_64
%endif
%ifarch aarch64
%global native_ga Linux-aarch64
%endif

%check
%{buildroot}%{_bindir}/limactl --version | grep -qx 'limactl version %{version}'

%files
%license LICENSE
%{_bindir}/lima
%{_bindir}/limactl
%{_bindir}/*.lima
%dir %{_libexecdir}/lima
%{_libexecdir}/lima/limactl-*
%dir %{_datadir}/lima
%{_datadir}/lima/lima-guestagent.%{native_ga}.gz
%{_datadir}/lima/templates/
%{_docdir}/lima/
%{_mandir}/man1/lima.1*
%{_mandir}/man1/limactl*.1*

%files additional-guestagents
%{_datadir}/lima/lima-guestagent.Linux-*.gz
%exclude %{_datadir}/lima/lima-guestagent.%{native_ga}.gz

%changelog
* Fri Oct 23 2026 Kir Kolyshkin <kolyshkin@gmail.com> - 2.2.1-1
- Initial package
