const std = @import("std");

const ComponentStorage = @import("component_storage.zig").ComponentStorage;
const Query = @import("query.zig").Query;

const Self = @This();

const ComponentStorageAddress = usize;

pub const Error = error{
    ComponentAlreadyRegistered,
    ComponentNotRegistered,
};

pub const Entity = u32;

allocator: std.mem.Allocator,
component_storages: std.StringArrayHashMap(ComponentStorageAddress),
next_entity: Entity,

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .allocator = allocator,
        .component_storages = std.StringArrayHashMap(ComponentStorageAddress).init(allocator),
        .next_entity = 0,
    };
}

pub fn deinit(self: *Self) void {
    var component_storage_iter = self.component_storages.iterator();

    while (component_storage_iter.next()) |entry| {
        const component_storage = entry.value_ptr.*;

        const component_storage_ptr = @as(*u1, @ptrFromInt(component_storage));
        self.allocator.destroy(component_storage_ptr);
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
    return self.component_storages.contains(component_id);
}

fn idFromComponentType(comptime T: type) []const u8 {
    return @typeName(T);
}

fn register(self: *Self, comptime T: type) !void {
    if (self.isRegistered(T)) {
        return error.ComponentAlreadyRegistered;
    }

    const component_id = idFromComponentType(T);

    const component_storage_ptr = try self.allocator.create(ComponentStorage(T));
    component_storage_ptr.* = ComponentStorage(T).init(self.allocator);

    try self.component_storages.put(component_id, @intFromPtr(component_storage_ptr));
}

fn getComponentStorage(self: Self, comptime T: type) !*ComponentStorage(T) {
    if (!self.isRegistered(T)) {
        return error.ComponentNotRegistered;
    }

    const component_id = idFromComponentType(T);

    return @ptrFromInt(self.component_storages.get(component_id));
}

pub fn has(self: Self, comptime T: type, entity: Entity) bool {
    const component_storage = self.getComponentStorage(T) catch {
        return false;
    };

    return component_storage.contains(entity);
}

pub fn get(self: Self, comptime T: type, entity: Entity) ?T {
    const component_storage = self.getComponentStorage(T) catch {
        return null;
    };

    return component_storage.get(entity);
}

pub fn getPtr(self: Self, comptime T: type, entity: Entity) *T {
    const component_storage = self.getComponentStorage(T) catch {
        return null;
    };

    return component_storage.getPtr(entity);
}

pub fn query(self: Self, comptime includes: anytype, comptime excludes: anytype) Query {
    return Query(includes, excludes).init(self);
}
