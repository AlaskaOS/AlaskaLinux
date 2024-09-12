## What is it?

A declarative system configurator. Think NixOS/Guix, but with the ability to opt out after your initial install.

## How do I use it?

```sh
# subject to change
curl -O https://raw.githubusercontent.com/AlaskaOS/Alaska/master/alaska.zig
zig run alaska.zig -- sync # sync system to config.zig specification
```

## Example config

```zig
// config.zig
pub fn configure(c: *@import("alaska.zig").Config) void {
    c.hostname = "myhostname";

    const global_packages = .{
        "busybox",
        "neovim",
        "fish",
    };
    inline for (global_packages) |package|
        c.addPackage(.{ .name = package });
}
```

## Goals

- Be completely transparent to the configured system. Deletable without hassle.
- Be extensible with the full power of Zig.
- Allow multiple hardware configurations in a single config file.
- The following assumptions are currently being made for simplicity:
    - x86_64 Linux kernel
    - Source-based packaging
    - EFISTUB only (no grub, systemd-boot, refind, etc.)

- Big Ideas™ (subject to change)
    - Custom filesystem hierarchy. /{Volumes,Users,Programs}
        - No PATH variable. Store programs in /Programs instead.
        - No random mount points. Use /Volumes.
        - Package manager can link and unlink programs to standard FHS at request.
    - Always removable. Your system can be as clean as a fresh install every day.
    - Version manager: symlink a different version of python whenever you want, etc.
