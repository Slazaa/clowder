const std = @import("std");

const Storage = @import("storage.zig").Storage;
const Query = @import("query.zig").Query;

const StorageAddr = usize;

pub const Entity = u32;

pub const Error = error{
    ComponentAlreadyRegisted,
    ComponentNotRegistered,
};

const Self = @This();

allocator: std.mem.Allocator,
storages: std.StringArrayHashMapUnmanaged(StorageAddr) = std.StringArrayHashMapUnmanaged(StorageAddr){},
next_entity: Entity,

/// Initializes a new `Registry`.
/// Deinitiliaze it with `deinit`.
pub fn init(allocator: std.mem.Allocator) !Self {
    return .{
        .allocator = allocator,
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

fn getComponentId(comptime Component: type) []const u8 {
    return @typeName(Component);
}

fn register(self: *Self, comptime Component: type) !void {
    if (@typeInfo(Component) == .ErrorUnion) {
        @compileError("Found error union, check that you handle the errors when initializing components");
    }

    if (self.isRegistered(Component)) {
        return Error.ComponentAlreadyRegisted;
    }

    const storage = try Storage(Component).init(self.allocator);
    try self.storages.put(self.allocator, getComponentId(Component), @intFromPtr(storage));
}

pub fn getStorage(self: Self, comptime Component: type) !*Storage(Component) {
    const component_id = getComponentId(Component);

    const storage_addr = self.storages.get(component_id) orelse {
        return Error.ComponentNotRegistered;
    };

    return @ptrFromInt(storage_addr);
}

/// Spawns a new `Entity` and return it.
pub fn spawn(self: *Self) Entity {
    const entity = self.next_entity;
    self.next_entity += 1;

    return entity;
}

/// Despawns `entity`.
pub fn despawn(self: Self, entity: Entity) void {
    for (self.storages.values()) |storage_addr| {
        const storage: *Storage(u1) = @ptrFromInt(storage_addr);
        _ = storage.remove(entity);
    }
}

/// Returns `true` if `Component` is registered.
/// Else returns `false`.
pub fn isRegistered(self: Self, comptime Component: type) bool {
    return self.storages.contains(getComponentId(Component));
}

/// Returns `true` if `entity` has `Component`.
/// Else returns `false`.
pub fn hasComponent(self: Self, entity: Entity, comptime Component: type) bool {
    const storage = self.getStorage(Component) catch {
        return false;
    };

    return storage.contains(entity);
}

/// Returns the `Component` of `entity`.
pub fn getComponent(self: Self, entity: Entity, comptime Component: type) ?Component {
    const storage = self.getStorage(Component) catch {
        return null;
    };

    return storage.get(entity);
}

/// Returns a pointer to the `Component` of `entity`.
pub fn getComponentPtr(self: Self, entity: Entity, comptime Component: type) ?*Component {
    const storage = self.getStorage(Component) catch {
        return null;
    };

    return storage.getPtr(entity);
}

/// Adds `component` to `entity`.
pub fn addComponent(self: *Self, entity: Entity, component: anytype) !void {
    const Component = @TypeOf(component);

    if (!self.isRegistered(Component)) {
        try self.register(Component);
    }

    var storage = try self.getStorage(Component);
    try storage.add(entity, component);
}

/// Returns a `Query` that filters entities depending on the components
/// they have or not.
pub fn query(self: Self, comptime includes: anytype, comptime excludes: anytype) Query(includes, excludes) {
    return Query(includes, excludes).init(self);
}
