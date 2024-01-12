const std = @import("std");

const Registry = @import("Registry.zig");

const Entity = Registry.Entity;

pub const Error = error{
    EntityAlreadyAdded,
    InvalidEntity,
};

pub fn Storage(comptime Component: type) type {
    const empty_struct = @sizeOf(Component) == 0;

    const ComponentOrDummy = if (empty_struct) struct { dummy: u1 } else Component;

    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        entities: std.ArrayList(Entity),
        instances: std.ArrayList(ComponentOrDummy),

        pub fn init(allocator: std.mem.Allocator) !*Self {
            const self = try allocator.create(Self);
            self.* = .{
                .allocator = allocator,
                .alignment = @alignOf(Component),
                .entities = std.ArrayList(Entity).init(allocator),
                .instances = if (!empty_struct) std.ArrayList(ComponentOrDummy).init(allocator) else undefined,
            };

            return self;
        }

        pub fn deinit(self: *Self) void {
            if (!empty_struct) {
                self.instances.deinit();
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

                pub fn getPtr(self: Self, entity: Entity) ?Component {
                    const entity_index = self.getEntityIndex(entity) catch return null;
                    return &self.instances.items[entity_index];
                }
            }
        else
            struct {};
    };
}
