const std = @import("std");

const testing = std.testing;

const registry = @import("registry.zig");
const storage = @import("storage.zig");

pub const Entity = registry.Entity;
pub const RegistryError = registry.Error;
pub const Registry = registry.Registry;

pub const StorageError = storage.Error;
pub const Storage = storage.Storage;

const Component = struct {
    value: u32,
};

const allocator = testing.allocator;

test "component test" {
    var reg = Registry(.{Component}).init(allocator);
    defer reg.deinit();

    const entity = registry.spawn();
    try reg.add(entity, Component{ .value = 10 });

    // const component = registry.get(Component, entity) orelse {
    //     return error.CouldNotGetComponent;
    // };

    // try testing.expectEqual(@as(u32, 10), component.value);
}
