const std = @import("std");

const mem = std.mem;

const Allocator = mem.Allocator;

const StringArrayHashMap = std.StringArrayHashMap;

const ComponentStorage = @import("component_storage.zig").ComponentStorage;
const Entity = @import("Entity.zig");

const Self = @This();

const ComponentStorageAddress = usize;

pub const Error = error{
    ComponentAlreadyRegistered,
};

allocator: Allocator,
component_storages: StringArrayHashMap(ComponentStorageAddress),
next_entity_id: u32 = 0,

pub fn init(allocator: Allocator) Self {
    return .{
        .allocator = allocator,
        .component_storages = StringArrayHashMap(ComponentStorageAddress).init(allocator),
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

pub fn register(self: *Self, comptime T: type) !void {
    if (self.isRegistered(T)) {
        return error.ComponentAlreadyRegistered;
    }

    const component_id = @typeName(T);

    const component_storage_ptr = try self.allocator.create(ComponentStorage(T));
    component_storage_ptr.* = ComponentStorage(T).init(self.allocator);

    try self.component_storages.put(component_id, @intFromPtr(component_storage_ptr));
}

pub fn getComponentStorage(self: *Self, comptime T: type) *ComponentStorage(T) {
    if (!self.isRegistered(T)) {
        @panic("Component '" ++ @typeName(T) ++ "' not registered");
    }

    const component_id = @typeName(T);

    return @as(*ComponentStorage(T), @ptrFromInt(self.component_storages.get(component_id) orelse unreachable));
}

pub fn getComponentStorageOrRegister(self: *Self, comptime T: type) !*ComponentStorage(T) {
    if (!self.isRegistered(T)) {
        try self.register(T);
    }

    return self.getComponentStorage(T);
}
