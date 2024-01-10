const std = @import("std");

const main = @import("main.zig");

const Entity = main.Entity;

pub fn Storage(comptime T: type) type {
    const empty_struct = @sizeOf(T) == 0;

    const ComponentOrDummy = if (empty_struct) struct { dummy: u1 } else T;

    return struct {
        const Self = @This();

        entities: std.ArrayList(Entity),
        instances: std.ArrayList(ComponentOrDummy),

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .entities = std.ArrayList(Entity).init(allocator),
                .instances = if (!empty_struct) std.ArrayList(ComponentOrDummy).init(allocator) else undefined,
            };
        }

        pub fn deinit(self: Self) void {
            if (!empty_struct) {
                self.instances.deinit();
            }

            self.entities.deinit();
        }
    };
}
