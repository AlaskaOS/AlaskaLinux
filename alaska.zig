const std = @import("std");

const user_config = @import("config.zig");

pub const Config = struct {
    pub const Prodecure = fn (*@This()) void;
    pub const Package = struct {
        name: []const u8,
        version: ?std.SemanticVersion = null,
    };

    pub fn addPackage(self: *@This(), package: Package) void {
        _ = .{ self, package };
    }

    pub fn registerLayer(self: *@This(), name: []const u8, comptime T: type) void {
        _ = .{ self, name, T };
    }
};

pub fn main() void {
    var c = Config{};
    if (@hasDecl(user_config, "configure")) {
        user_config.configure(&c);
    } else {
        @compileError(@typeName(user_config) ++ ".zig does not contain 'pub fn configure(" ++ @typeName(*Config) ++ ") void'.");
    }
}
