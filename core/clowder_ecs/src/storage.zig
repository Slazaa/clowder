const std = @import("std");

const Registry = @import("Registry.zig");

const Entity = Registry.Entity;

pub const Error = error{
    EntityAlreadyAdded,
    InvalidEntity,
};

pub fn Storage(comptime Component: type) type {
    return struct {
        const Self = @This();

        const empty_component = @sizeOf(Component) == 0;

        allocator: std.mem.Allocator,
        component_size: usize,
        log2_align: std.mem.Allocator.Log2Align,
        entities: std.ArrayListUnmanaged(Entity),
        instances: std.ArrayListUnmanaged(Component),
        empty_component: bool,

        pub fn init(allocator: std.mem.Allocator) !*Self {
            const self = try allocator.create(Self);
            self.* = .{
                .allocator = allocator,
                .component_size = @sizeOf(Component),
                .log2_align = std.math.log2(@alignOf(Component)),
                .entities = std.ArrayListUnmanaged(Entity){},
                .instances = if (!empty_component) std.ArrayListUnmanaged(Component){} else undefined,
                .empty_component = empty_component,
            };

            return self;
        }

        pub fn deinit(self: *Self) void {
            if (!self.empty_component) {
                var bytes: []u8 = undefined;
                bytes.ptr = @ptrCast(self.instances.items.ptr);
                bytes.len = self.instances.capacity * self.component_size;

                self.allocator.rawFree(bytes, self.log2_align, @returnAddress());
            }

            self.entities.deinit(self.allocator);

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

            if (!empty_component) {
                try self.instances.append(self.allocator, component);
            }

            try self.entities.append(self.allocator, entity);
        }

        pub fn remove(self: *Self, entity: Entity) bool {
            if (!self.has(entity)) {
                return false;
            }

            const entity_index = self.getEntityIndex(entity);

            if (!empty_component) {
                self.instances.orderedRemove(entity_index);
            }

            self.entities.orderedRemove(entity_index);

            return true;
        }

        pub usingnamespace if (!empty_component)
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
