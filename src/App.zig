const std = @import("std");

const ecs = @import("clowder_ecs");

const Self = @This();

pub const System = *const fn (app: *Self) anyerror!void;
pub const DeinitSystem = *const fn (app: *Self) void;

pub const Plugin = struct {
    plugins: []const Plugin = &.{},

    initSystems: []const System = &.{},
    deinitSystems: []const DeinitSystem = &.{},
    systems: []const System = &.{},

    pub fn load(self: @This(), app: *Self) !void {
        for (self.plugins) |plugin| {
            try plugin.load(app);
        }

        for (self.initSystems) |system| {
            try system(app);
        }

        for (self.deinitSystems) |system| {
            const system_addr = @intFromPtr(system);
            try app.deinit_systems.append(app.allocator, system_addr);
        }

        for (self.systems) |system| {
            const system_addr = @intFromPtr(system);
            try app.systems.append(app.allocator, system_addr);
        }
    }
};

const SystemAddr = usize;

allocator: std.mem.Allocator,
registry: ecs.Registry,

deinit_systems: std.ArrayListUnmanaged(SystemAddr) = std.ArrayListUnmanaged(SystemAddr){},
systems: std.ArrayListUnmanaged(SystemAddr) = std.ArrayListUnmanaged(SystemAddr){},

is_exit: bool = false,

/// Initiliazes a new `App`.
/// Deinitialize it with `deinit`.
pub fn init(allocator: std.mem.Allocator, plugin: Plugin) !Self {
    var self = Self{
        .allocator = allocator,
        .registry = try ecs.Registry.init(allocator),
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
            const system: System = @ptrFromInt(system_addr);
            try system(self);
        }
    }

    for (0..self.deinit_systems.items.len) |index| {
        const i = self.deinit_systems.items.len - index - 1;

        const system: DeinitSystem = @ptrFromInt(self.deinit_systems.items[i]);
        system(self);
    }
}

/// Exists the `App`.
pub inline fn exit(self: *Self) void {
    self.is_exit = true;
}

/// Spawns a new `Entity`.
pub fn spawn(self: *Self) ecs.Entity {
    return self.registry.spawn();
}

/// Despawns `entity`.
pub fn despawn(self: Self, entity: ecs.Entity) void {
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
pub fn getComponent(self: Self, entity: ecs.Entity, comptime Component: type) ?Component {
    return self.registry.getComponent(entity, Component);
}

/// Returns a pointer to the `Component` of `entity`.
pub fn getComponentPtr(self: Self, entity: ecs.Entity, comptime Component: type) ?*Component {
    return self.registry.getComponentPtr(entity, Component);
}

/// Adds `component` to `entity`.
pub fn addComponent(self: *Self, entity: ecs.Entity, component: anytype) !void {
    try self.registry.addComponent(entity, component);
}

/// Adds `bundle` to `entity`.
pub fn addBundle(self: *Self, entity: ecs.Entity, bundle: anytype) !void {
    const Bundle = @TypeOf(bundle);
    const bundle_info = @typeInfo(Bundle);

    if (bundle_info != .Struct) {
        @compileError("Expected struct, found '" ++ @typeName(Bundle) ++ "'");
    }

    if (!@hasDecl(Bundle, "build")) {
        @compileError("Bundles require a build fonction, but '" ++ @typeName(Bundle) ++ "' doesn't have one");
    }

    try bundle.build(self, entity);
}

/// Returns a `Query` that filters entities depending on the components
/// they have or not.
pub fn query(self: Self, comptime includes: anytype, comptime excludes: anytype) ecs.Query(includes, excludes) {
    return self.registry.query(includes, excludes);
}

/// Returns the first `Entity` depending on the components they have or not.
/// If the such entity does not exist, returns `null`.
pub inline fn getFirst(self: Self, comptime includes: anytype, comptime excludes: anytype) ?ecs.Entity {
    var query_ = self.query(includes, excludes);
    return query_.next();
}
