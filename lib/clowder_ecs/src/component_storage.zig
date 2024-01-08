const std = @import("std");

const main = @import("main.zig");

const Entity = main.Entity;

pub fn ComponentStorage(comptime T: type) type {
    return std.AutoArrayHashMap(Entity, T);
}
