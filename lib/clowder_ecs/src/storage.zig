const std = @import("std");

const Registry = @import("Registry.zig");

const Entity = Registry.Entity;

pub const Error = error{
    EntityAlreadyAdded,
    InvalidEntity,
};

pub fn Storage(comptime Component: type) type {
    const empty_struct = @sizeOf(Component) == 0;

    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        log2_align: std.mem.Allocator.Log2Align,
        entities: std.ArrayList(Entity),
        instances: std.ArrayList(Component),

        pub fn init(allocator: std.mem.Allocator) !*Self {
            const self = try allocator.create(Self);
            self.* = .{
                .allocator = allocator,
                .log2_align = std.math.log2(@alignOf(Component)),
                .entities = std.ArrayList(Entity).init(allocator),
                .instances = if (!empty_struct) std.ArrayList(Component).init(allocator) else undefined,
            };

            return self;
        }

        pub fn deinit(self: *Self) void {
            if (!empty_struct) {
                const alignment = std.math.pow(u32, 2, self.log2_align);

                var bytes: []u8 = undefined;
                bytes.ptr = @ptrCast(self.instances.items.ptr);
                bytes.len = self.instances.capacity * alignment;

                self.allocator.rawFree(bytes, self.log2_align, @returnAddress());
            }

            self.entities.deinit();

            self.allocator.destroy(self);
        }

        pub fn has(self: Self, entity: Entity) bool {
            return std.mem.containsAtLeast(Entity, self.entities.items, 1, &.{entity});
        }

        pub fn getEntityIndex(self: Self, entity: Entity) !usize {
            for (self.entities.items, 0..) |e, i| {
                if (entity == e) return i;
            }

            return Error.InvalidEntity;
        }

        pub fn add(self: *Self, entity: Entity, component: Component) !void {
            if (self.has(entity)) {
                return Error.EntityAlreadyAdded;
            }

            if (!empty_struct) {
                try self.instances.append(component);
            }

            try self.entities.append(entity);
        }

        pub fn remove(self: *Self, entity: Entity) bool {
            if (!self.has(entity)) {
                return false;
            }

            const entity_index = self.getEntityIndex(entity);

            if (!empty_struct) {
                self.instances.orderedRemove(entity_index);
            }

            self.entities.orderedRemove(entity_index);

            return true;
        }

        pub usingnamespace if (!empty_struct)
            struct {
                pub fn get(self: Self, entity: Entity) ?Component {
                    const entity_index = self.getEntityIndex(entity) catch return null;
                    return self.instances.items[entity_index];
                }

                pub fn getPtr(self: Self, entity: Entity) ?*Component {
                    const entity_index = self.getEntityIndex(entity) catch return null;
                    return &self.instances.items[entity_index];
                }
            }
        else
            struct {};
    };
}
