const std = @import("std");

const testing = std.testing;

pub const Entity = @import("Entity.zig");
pub const World = @import("World.zig");

const Component = struct {
    value: u32,
};

const allocator = testing.allocator;

test "component test" {
    var world = World.init(allocator);
    defer world.deinit();

    const entity = world.spawn();
    try entity.add(Component{ .value = 10 });

    const component = entity.get(Component);

    try testing.expectEqual(@as(u32, 10), component.value);
}
