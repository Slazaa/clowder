const std = @import("std");

const testing = std.testing;

pub const Registry = @import("Registry.zig");

const Component = struct {
    value: u32,
};

const allocator = testing.allocator;

test "component test" {
    var registry = Registry.init(allocator);
    defer registry.deinit();

    const entity = registry.spawn();
    try registry.add(entity, Component{ .value = 10 });

    // const component = registry.get(Component, entity) orelse {
    //     return error.CouldNotGetComponent;
    // };

    // try testing.expectEqual(@as(u32, 10), component.value);
}
