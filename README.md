# Tailscale Installer for Mobile Linux

A minimal shell script to install [Tailscale](https://tailscale.com) on mobile Linux distributions based on Debian Trixie.

**Supported systems:**

| OS | Base | Package manager |
|----|------|----------------|
| [Mobian](https://mobian-project.org) | Debian Trixie | apt |
| [Droidian](https://droidian.org) | Debian Trixie | apt |
| [SirrOS](https://sirros.github.io) | Debian Trixie | apt |
---

## Usage

**Basic install:**
```sh
sh install.sh
```

**Pin a specific version:**
```sh
TAILSCALE_VERSION=1.88.4 sh install.sh
```

**Use the unstable track:**
```sh
TRACK=unstable sh install.sh
```

The script requires root privileges. It will automatically use `sudo` or `doas` if available, or run directly as root.

---

## What the script does

1. Reads `/etc/os-release` to identify the distro.
2. Adds the Tailscale GPG keyring to `/usr/share/keyrings/`.
3. Adds the Tailscale apt repository to `/etc/apt/sources.list.d/`.
4. Installs `tailscale` and `tailscale-archive-keyring` via apt.

---

## After installation

Start and authenticate your device:

```sh
sudo tailscale up
```

Then check your connection:

```sh
tailscale status
```

---

## Credits

Based on the official [Tailscale install script](https://tailscale.com/install.sh), licensed under BSD-3-Clause.
