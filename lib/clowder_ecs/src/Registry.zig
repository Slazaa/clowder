const std = @import("std");

const Storage = @import("storage.zig").Storage;
const Query = @import("query.zig").Query;

const Self = @This();

const StorageAddr = usize;

pub const Error = error{
    ComponentAlreadyRegistered,
    ComponentNotRegistered,
};

pub const Entity = u32;

allocator: std.mem.Allocator,
storages: std.StringArrayHashMap(StorageAddr),
next_entity: Entity,

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .allocator = allocator,
        .storages = std.StringArrayHashMap(StorageAddr).init(allocator),
        .next_entity = 0,
    };
}

pub fn deinit(self: *Self) void {
    for (self.storages.values()) |storage_addr| {
        const storage: *Storage(u1) = @ptrFromInt(storage_addr);
        storage.deinit();
    }

    self.storages.deinit();
}

pub fn spawn(self: *Self) Entity {
    const entity = self.next_entity;
    self.next_entity += 1;

    return entity;
}

pub fn isRegistered(self: Self, comptime T: type) bool {
    const component_id = @typeName(T);
    return self.storages.contains(component_id);
}

fn idFromComponentType(comptime T: type) []const u8 {
    return @typeName(T);
}

fn register(self: *Self, comptime T: type) !void {
    if (self.isRegistered(T)) {
        return error.ComponentAlreadyRegistered;
    }

    const component_id = idFromComponentType(T);
    const storage = try Storage(T).init(self.allocator);

    try self.storages.put(component_id, @intFromPtr(storage));
}

pub fn getStorage(self: Self, comptime T: type) !*Storage(T) {
    const component_id = idFromComponentType(T);

    const storage_addr = self.storages.get(component_id) orelse {
        return error.ComponentNotRegistered;
    };

    return @ptrFromInt(storage_addr);
}

pub fn has(self: Self, comptime T: type, entity: Entity) bool {
    const storage = self.getStorage(T) catch {
        return false;
    };

    return storage.contains(entity);
}

pub fn get(self: Self, comptime T: type, entity: Entity) ?T {
    const storage = self.getStorage(T) catch {
        return null;
    };

    return storage.get(entity);
}

pub fn getPtr(self: Self, comptime T: type, entity: Entity) *T {
    const storage = self.getStorage(T) catch {
        return null;
    };

    return storage.getPtr(entity);
}

pub fn query(self: Self, comptime includes: anytype, comptime excludes: anytype) Query {
    return Query(includes, excludes).init(self);
}

pub fn add(self: *Self, entity: Entity, component: anytype) !void {
    const Component = @TypeOf(component);

    if (!self.isRegistered(Component)) {
        try self.register(Component);
    }

    var storage = try self.getStorage(Component);
    try storage.add(entity, component);
}
