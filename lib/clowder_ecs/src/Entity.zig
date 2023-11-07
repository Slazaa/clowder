const World = @import("World.zig");

const Self = @This();

pub const EntityID = u32;

world: *World,
id: EntityID,

pub fn init(world: *World, id: EntityID) Self {
    return .{
        .world = world,
        .id = id,
    };
}

pub fn has(self: Self, comptime T: type) bool {
    const component_id = @typeName(T);
    const component_storage = self.world.getComponentStorage(T);

    return component_storage.contains(component_id);
}

pub fn tryGet(self: Self, comptime T: type) ?T {
    const component_storage = self.world.getComponentStorage(T);
    return component_storage.get(self.id);
}

pub fn tryGetPtr(self: Self, comptime T: type) ?*T {
    const component_id = @typeName(T);
    const component_storage = self.world.getComponentStorage(T);

    return component_storage.getPtr(component_id);
}

pub fn get(self: Self, comptime T: type) T {
    return self.tryGet(T) orelse @panic("Entity does not have component '" ++ @typeName(T) ++ "'");
}

pub fn getPtr(self: Self, comptime T: type) *T {
    return self.tryGetPtr(T) orelse @panic("Entity does not have component '" ++ @typeName(T) ++ "'");
}

pub fn add(self: Self, component: anytype) !void {
    const T = @TypeOf(component);

    const component_storage = try self.world.getComponentStorageOrRegister(T);
    try component_storage.put(self.id, component);
}

pub fn remove(self: Self, component: anytype) bool {
    const T = @TypeOf(component);

    if (!self.world.isRegistered(T)) {
        return false;
    }

    const component_storage = self.world.getComponentStorage(T);
    return component_storage.swapRemove(self.id);
}
