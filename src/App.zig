const std = @import("std");

const root = @import("root.zig");

const Self = @This();

const SystemAddr = usize;

allocator: std.mem.Allocator,
registry: root.Registry,

deinit_systems: std.ArrayListUnmanaged(SystemAddr) = std.ArrayListUnmanaged(SystemAddr){},
systems: std.ArrayListUnmanaged(SystemAddr) = std.ArrayListUnmanaged(SystemAddr){},

is_exit: bool = false,

/// Initiliazes a new `App`.
/// Deinitialize it with `deinit`.
pub fn init(allocator: std.mem.Allocator, plugin: root.Plugin) !Self {
    var self = Self{
        .allocator = allocator,
        .registry = try root.Registry.init(allocator),
    };

    errdefer self.deinit();

    try plugin.load(&self);

    return self;
}

/// Deinitializes the `App`.
pub fn deinit(self: *Self) void {
    self.systems.deinit(self.allocator);
    self.deinit_systems.deinit(self.allocator);

    self.registry.deinit();
}

/// Runs the `App`.
pub fn run(self: *Self) !void {
    while (!self.is_exit) {
        for (self.systems.items) |system_addr| {
            const system: root.System = @ptrFromInt(system_addr);
            try system(self);
        }
    }

    for (0..self.deinit_systems.items.len) |index| {
        const i = self.deinit_systems.items.len - index - 1;

        const system: root.DeinitSystem = @ptrFromInt(self.deinit_systems.items[i]);
        system(self);
    }
}

/// Exists the `App`.
pub inline fn exit(self: *Self) void {
    self.is_exit = true;
}

/// Spawns a new `Entity`.
pub fn spawn(self: *Self) root.Entity {
    return self.registry.spawn();
}

/// Despawns `entity`.
pub fn despawn(self: Self, entity: root.Entity) void {
    self.registry.despawn(entity);

    for (self.tags.values()) |*entity_list| {
        for (0..entity_list.items.len) |i| {
            if (entity_list.items[i] != entity) {
                continue;
            }

            _ = entity_list.swapRemove(i);
            break;
        }
    }
}

/// Returns the `Component` of `entity`.
pub fn getComponent(self: Self, entity: root.Entity, comptime Component: type) ?Component {
    return self.registry.getComponent(entity, Component);
}

/// Returns a pointer to the `Component` of `entity`.
pub fn getComponentPtr(self: Self, entity: root.Entity, comptime Component: type) ?*Component {
    return self.registry.getComponentPtr(entity, Component);
}

/// Adds `component` to `entity`.
pub fn addComponent(self: *Self, entity: root.Entity, component: anytype) !void {
    try self.registry.addComponent(entity, component);
}

/// Adds `bundle` to `entity`.
pub fn addBundle(self: *Self, entity: root.Entity, bundle: anytype) !void {
    const Bundle = @TypeOf(bundle);
    const bundle_info = @typeInfo(Bundle);

    if (bundle_info != .Struct) {
        @compileError("Expected struct, found '" ++ @typeName(Bundle) ++ "'");
    }

    if (!@hasDecl(Bundle, "build")) {
        @compileError("Bundles require a 'build' function, but '" ++ @typeName(Bundle) ++ "' doesn't have one");
    }

    try bundle.build(self, entity);
}

/// Returns a `Query` that filters entities depending on the components
/// they have or not.
pub fn query(self: Self, comptime includes: anytype, comptime excludes: anytype) root.Query(includes, excludes) {
    return self.registry.query(includes, excludes);
}

/// Returns the first `Entity` depending on the components they have or not.
/// If the such entity does not exist, returns `null`.
pub inline fn getFirst(self: Self, comptime includes: anytype, comptime excludes: anytype) ?root.Entity {
    var query_ = self.query(includes, excludes);
    return query_.next();
}
