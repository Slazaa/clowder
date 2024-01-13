const std = @import("std");

const testing = std.testing;

const storage = @import("storage.zig");

pub const Registry = @import("Registry.zig");
pub const Entity = Registry.Entity;
pub const RegistryError = Registry.Error;

pub const StorageError = storage.Error;
pub const Storage = storage.Storage;

const A = struct {
    value: u32,
};

const B = struct {
    value: u64,
};

const allocator = testing.allocator;

test "single component" {
    var reg = try Registry.init(allocator);
    defer reg.deinit();

    const entity = reg.spawn();
    try reg.addComponent(entity, A{ .value = 10 });

    const a = reg.getComponent(A, entity) orelse {
        return error.CouldNotGetComponent;
    };

    try testing.expectEqual(@as(u32, 10), a.value);
}

test "multiple components" {
    var reg = try Registry.init(allocator);
    defer reg.deinit();

    const entity = reg.spawn();
    try reg.addComponent(entity, A{ .value = 10 });
    try reg.addComponent(entity, B{ .value = 20 });

    const a = reg.getComponent(A, entity) orelse {
        return error.CouldNotGetComponent;
    };

    const b = reg.getComponentPtr(B, entity) orelse {
        return error.CouldNotGetComponent;
    };

    try testing.expectEqual(@as(u32, 10), a.value);
    try testing.expectEqual(@as(u64, 20), b.value);
}

test "single resource" {
    var reg = try Registry.init(allocator);
    defer reg.deinit();

    try reg.addResource(A{ .value = 10 });

    const a = reg.getResource(A) orelse {
        return error.CouldNotGetResource;
    };

    try testing.expectEqual(@as(u32, 10), a.value);
}

test "multiple resources" {
    var reg = try Registry.init(allocator);
    defer reg.deinit();

    try reg.addResource(A{ .value = 10 });
    try reg.addResource(B{ .value = 20 });

    const a = reg.getResource(A) orelse {
        return error.CouldNotGetResource;
    };

    const b = reg.getResourcePtr(B) orelse {
        return error.CouldNotGetResource;
    };

    try testing.expectEqual(@as(u32, 10), a.value);
    try testing.expectEqual(@as(u64, 20), b.value);
}
