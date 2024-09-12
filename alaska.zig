const std = @import("std");

pub const Config = struct {
    pub const Pkg = struct {
        name: []const u8,
        version: ?std.SemanticVersion = null,
    };

    keyboard_layout: []const u8 = "us",
    hostname: []const u8 = "alaska",
    packages: std.ArrayList(Pkg),
    overlays: std.ArrayList(*const fn (c: *Config) void),

    pub fn addPackage(self: *@This(), package: Pkg) void {
        self.packages.append(package) catch unreachable;
    }

    pub fn addOverlay(self: *@This(), comptime T: type) void {
        self.overlays.append(&T.configure) catch unreachable;
    }
};

pub fn main() !void {
    var c = Config{
        .packages = std.ArrayList(Config.Pkg).init(std.heap.page_allocator),
        .overlays = std.ArrayList(*const fn (c: *Config) void).init(std.heap.page_allocator),
    };
    @import("config.zig").configure(&c);

    if (c.keyboard_layout.len == 0)
        std.log.err("keyboard_layout was not specified.", .{});
    std.log.info("keyboard_layout: {s}", .{c.keyboard_layout});

    if (c.hostname.len == 0)
        std.log.err("hostname was not specified.", .{});
    if (c.hostname.len > 16)
        std.log.err("hostname '{s}' was too long.", .{c.hostname});
    for (c.hostname) |ch| {
        if (!std.ascii.isPrint(ch)) {
            std.log.err("hostname '{s}' contains invalid characters.", .{c.hostname});
            break;
        }
    }
    std.log.info("hostname: {s}", .{c.hostname});

    std.log.info("packages:", .{});
    for (c.packages.items) |package| {
        std.log.info("  {s}", .{package.name});
        // todo(dfra): check against package repos for availability
        if (!std.mem.eql(u8, package.name, "neovim")) {
            std.log.err("package '{s}' not found.", .{package.name});
        }
    }
}
