## What is it?

A declarative system configurator. Think NixOS/Guix, but with the ability to opt out after your initial install.

## Example config

```c
// config.c
static void laptops_configure(Config* c) {
    config_add_package(str("acpi"), c);
}

static void framework_configure(Config* c) {
    config_set_hostname(str("fwork"), c);
}

static void configure(Config* c) {
    config_add_package(str("neovim"), c);

    config_register_named_layer(str("laptops"), laptops_configure, c);
    config_register_named_layer(str("framework"), framework_configure, c);
}
```

## How do I use it?

```sh
# create your config.c, then...
curl -O https://raw.githubusercontent.com/AlaskaOS/Alaska/master/alaska.c
cc -o alaska alaska.c
alaska sync laptops framework # or whatever your layer names are beyond 'default'
```

## Goals

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
