const std = @import("std");

const ComponentStorage = @import("component_storage.zig").ComponentStorage;

const Self = @This();

const ComponentStorageAddress = usize;

pub const Error = error{
    ComponentAlreadyRegistered,
};

pub const Entity = u32;

allocator: std.mem.Allocator,
component_storages: std.StringArrayHashMap(ComponentStorageAddress),
next_entity_id: u32 = 0,

pub fn init(allocator: std.mem.Allocator) Self {
    return .{
        .allocator = allocator,
        .component_storages = std.StringArrayHashMap(ComponentStorageAddress).init(allocator),
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
    self.next_entity_id += 1;

    return entity;
}

pub fn isRegistered(self: *Self, comptime T: type) bool {
    const component_id = @typeName(T);
    return self.component_storages.contains(component_id);
}

fn register(self: *Self, comptime T: type) !void {
    if (self.isRegistered(T)) {
        return error.ComponentAlreadyRegistered;
    }

    const component_id = @typeName(T);

    const component_storage_ptr = try self.allocator.create(ComponentStorage(T));
    component_storage_ptr.* = ComponentStorage(T).init(self.allocator);

    try self.component_storages.put(component_id, @intFromPtr(component_storage_ptr));
}
