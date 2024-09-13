## What is it?

A declarative system configurator. Think NixOS/Guix, but with the ability to opt out after your initial install.

## Example config

```zig
// config.zig
const alaska = @import("alaska.zig");

const Laptops = struct {
    pub fn configure(c: *alaska.Config) void {
        c.addPackage(.{ .name = "acpi" });
    }
};

const Framework = struct {
    pub fn configure(c: *alaska.Config) void {
        c.hostname = "fwork";
    }
};

pub fn configure(c: *alaska.Config) void {
    c.addPackage(.{ .name = "busybox" });
    c.addPackage(.{ .name = "neovim" });

    c.registerLayer("laptops", Laptops);
    c.registerLayer("framework", Framework);
}
```

## How do I use it?

```sh
# create your config.zig, then...
curl -O https://raw.githubusercontent.com/AlaskaOS/AlaskaLinux/master/alaska.zig
zig run alaska.zig -- show laptops framework
# if everything looks correct, then...
zig run alaska.zig -- sync laptops framework
```

## Goals

- Be less than 1000 SLOC.
- Be completely transparent to the configured system. Deletable without hassle.
- Be extensible with the full power of a turing-complete language.
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
