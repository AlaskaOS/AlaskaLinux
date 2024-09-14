const std = @import("std");

const user_config = @import("config.zig");

pub const Package = struct {
    name: []const u8,
    version: ?std.SemanticVersion = null,
};

pub const Layer = struct {
    procedure: *const fn (*Config) void,
    hostname: ?[]const u8 = null,
};

var default_layer = Layer{
    .procedure = &user_config.configure,
    .hostname = "alaska",
};

pub const Config = struct {
    layers: std.StringHashMap(Layer),
    current_layer: *Layer,

    pub fn addPackage(self: *@This(), package: Package) void {
        _ = .{ self, package };
    }

    pub fn setHostname(self: *@This(), value: []const u8) void {
        self.current_layer.hostname = value;
    }

    pub fn registerLayer(self: *@This(), name: []const u8, comptime T: type) void {
        if (self.current_layer != &default_layer) {
            @panic("registerLayer can only occur in default_layer");
        }
        self.layers.put(name, Layer{ .procedure = &T.configure }) catch @panic("OOM");
    }
};

const FinalConfig = struct {
    hostname: []const u8,
};

pub fn main() void {
    var c = Config{
        .layers = std.StringHashMap(Layer).init(std.heap.page_allocator),
        .current_layer = &default_layer,
    };
    default_layer.procedure(&c);
    var final = FinalConfig{
        .hostname = default_layer.hostname.?,
    };

    var args = std.process.argsWithAllocator(std.heap.page_allocator) catch @panic("OOM");
    _ = args.skip();
    while (args.next()) |layer_name| {
        if (c.layers.getPtr(layer_name)) |layer| {
            c.current_layer = layer;
            layer.procedure(&c);
            if (layer.hostname) |new_hostname| {
                if (!std.mem.eql(u8, final.hostname, default_layer.hostname.?)) {
                    std.debug.print("conflicting hostnames '{s}' and '{s}'\n", .{ final.hostname, new_hostname });
                }
                final.hostname = new_hostname;
            }
        } else {
            std.debug.print("unknown layer of name '{s}'\n", .{layer_name});
        }
    }

    std.debug.print("hostname: {s}", .{final.hostname});
}
