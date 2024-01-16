const std = @import("std");

const Storage = @import("storage.zig").Storage;
const Query = @import("query.zig").Query;

const StorageAddr = usize;

pub const Error = error{
    ComponentAlreadyRegistered,
    ComponentNotRegistered,
    ResourceAlreadyPresent,
};

pub const Entity = u32;

const Self = @This();

allocator: std.mem.Allocator,
storages: std.StringArrayHashMapUnmanaged(StorageAddr),
next_entity: Entity,

/// Initializes a new `Registry`.
/// Deinitiliaze it with `deinit`.
pub fn init(allocator: std.mem.Allocator) !Self {
    return .{
        .allocator = allocator,
        .storages = std.StringArrayHashMapUnmanaged(StorageAddr){},
        .next_entity = 0,
    };
}

/// Deinitializes the `Registry`.
pub fn deinit(self: *Self) void {
    for (self.storages.values()) |storage_addr| {
        const storage: *Storage(u1) = @ptrFromInt(storage_addr);
        storage.deinit();
    }

    self.storages.deinit(self.allocator);
}

/// Spawns a new `Entity` and return it.
pub fn spawn(self: *Self) Entity {
    const entity = self.next_entity;
    self.next_entity += 1;

    return entity;
}

fn getComponentId(comptime Component: type) []const u8 {
    return @typeName(Component);
}

pub fn isComponentRegistered(self: Self, comptime T: type) bool {
    return self.storages.contains(getComponentId(T));
}

fn registerComponent(self: *Self, comptime Component: type) !void {
    if (self.isComponentRegistered(Component)) {
        return Error.ComponentAlreadyRegistered;
    }

    const storage = try Storage(Component).init(self.allocator);
    try self.storages.put(self.allocator, getComponentId(Component), @intFromPtr(storage));
}

pub fn getStorage(self: Self, comptime T: type) Error!*Storage(T) {
    const component_id = getComponentId(T);

    const storage_addr = self.storages.get(component_id) orelse {
        return Error.ComponentNotRegistered;
    };

    return @ptrFromInt(storage_addr);
}

pub fn hasComponent(self: Self, comptime T: type, entity: Entity) bool {
    const storage = self.getStorage(T) catch {
        return false;
    };

    return storage.contains(entity);
}

pub fn getComponent(self: Self, comptime T: type, entity: Entity) ?T {
    const storage = self.getStorage(T) catch {
        return null;
    };

    return storage.get(entity);
}

pub fn getComponentPtr(self: Self, comptime T: type, entity: Entity) ?*T {
    const storage = self.getStorage(T) catch {
        return null;
    };

    return storage.getPtr(entity);
}

pub fn addComponent(self: *Self, entity: Entity, component: anytype) !void {
    const Component = @TypeOf(component);

    if (!self.isComponentRegistered(Component)) {
        try self.registerComponent(Component);
    }

    var storage = try self.getStorage(Component);
    try storage.add(entity, component);
}

pub fn query(self: Self, comptime includes: anytype, comptime excludes: anytype) Query {
    return Query(includes, excludes).init(self);
}
