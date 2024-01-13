const std = @import("std");

const ecs = @import("clowder_ecs");

const main = @import("root.zig");

const Plugin = main.Plugin;

const Self = @This();

const AllocatorImpl = std.heap.GeneralPurposeAllocator(.{});

pub const Config = struct {
    plugins: []const Plugin = &.{},
};

allocator_impl: AllocatorImpl,
registry: ecs.Registry,

pub fn init(config: Config) !Self {
    var allocator_impl = AllocatorImpl{};
    errdefer _ = allocator_impl.deinit();

    const allocator = allocator_impl.allocator();

    var self = .{
        .allocator_impl = allocator_impl,
        .registry = try ecs.Registry.init(allocator),
    };

    for (config.plugins) |plugin| {
        try plugin(&self);
    }

    return self;
}

pub fn deinit(self: *Self) void {
    self.registry.deinit();
    _ = self.allocator_impl.deinit();
}
