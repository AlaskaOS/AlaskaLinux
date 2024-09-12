const std = @import("std");

const user_config = @import("config.zig");

pub const Config = struct {
    pub const Package = struct {
        name: []const u8,
        version: ?std.SemanticVersion = null,
    };

    keyboard_layout: []const u8 = "us",
    hostname: []const u8 = "alaska",
    timezone: []const u8 = "America/New_York",

    packages: std.ArrayList(Package),

    pub fn addPackage(self: *@This(), package: Package) void {
        self.packages.append(package) catch unreachable;
    }
};

pub fn main() void {
    var c = Config{
        .packages = std.ArrayList(Config.Package).init(std.heap.page_allocator),
    };
    if (@hasDecl(user_config, "configure")) {
        user_config.configure(&c);
    } else {
        @compileError(@typeName(user_config) ++ ".zig is missing `fn configure(c: *alaska.Config) void`");
    }

    for (c.packages.items) |package| std.debug.print("{s} ", .{package.name});
}
