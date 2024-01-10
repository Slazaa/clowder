const std = @import("std");

const Storage = @import("storage.zig").Storage;
const Query = @import("query.zig").Query;

const Self = @This();

const StorageAddress = usize;

pub const Error = error{
    ComponentAlreadyRegistered,
    ComponentNotRegistered,
};

pub const Entity = u32;

allocator: std.mem.Allocator,
storages: std.StringArrayHashMap(StorageAddress),
next_entity: Entity,

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .allocator = allocator,
        .storages = std.StringArrayHashMap(StorageAddress).init(allocator),
        .next_entity = 0,
    };
}

pub fn deinit(self: *Self) void {
    var storage_iter = self.storages.iterator();

    while (storage_iter.next()) |entry| {
        const storage = entry.value_ptr.*;

        const storage_ptr = @as(*u1, @ptrFromInt(storage));
        self.allocator.destroy(storage_ptr);
    }

    self.component_storages.deinit();
}

pub fn spawn(self: *Self) Entity {
    const entity = Entity.init(self, self.next_entity_id);
    self.next_entity += 1;

    return entity;
}

pub fn isRegistered(self: *Self, comptime T: type) bool {
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

    const storage_ptr = try self.allocator.create(Storage(T));
    storage_ptr.* = Storage(T).init(self.allocator);

    try self.storages.put(component_id, @intFromPtr(storage_ptr));
}

pub fn getStorage(self: Self, comptime T: type) !*Storage(T) {
    if (!self.isRegistered(T)) {
        return error.ComponentNotRegistered;
    }

    const component_id = idFromComponentType(T);

    return @ptrFromInt(self.storages.get(component_id));
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
