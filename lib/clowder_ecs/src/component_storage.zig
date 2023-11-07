const std = @import("std");

const AutoArrayHashMap = std.AutoArrayHashMap;

const Entity = @import("Entity.zig");
const EntityID = Entity.EntityID;

pub fn ComponentStorage(comptime T: type) type {
    return AutoArrayHashMap(EntityID, T);
}
