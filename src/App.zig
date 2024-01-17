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

tags: std.StringArrayHashMapUnmanaged(std.ArrayListUnmanaged(ecs.Entity)) = std.StringArrayHashMapUnmanaged(std.ArrayListUnmanaged(ecs.Entity)){},

is_exit: bool = false,

/// Initiliazes a new `App`.
/// Deinitialize it with `deinit`.
pub fn init(allocator: std.mem.Allocator, plugin: Plugin) !Self {
    var self = Self{
        .allocator = allocator,
        .registry = try ecs.Registry.init(allocator),
    };

    try plugin.load(&self);

    return self;
}

/// Deinitializes the `App`.
pub fn deinit(self: *Self) void {
    for (self.tags.values()) |*entity_list| {
        entity_list.deinit(self.allocator);
    }

    self.tags.deinit(self.allocator);

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

/// Returns the `Component` of `entity`.
pub fn get(self: Self, entity: ecs.Entity, comptime Component: type) ?Component {
    return self.registry.get(entity, Component);
}

/// Returns a pointer to the `Component` of `entity`.
pub fn getPtr(self: Self, entity: ecs.Entity, comptime Component: type) ?*Component {
    return self.registry.getPtr(entity, Component);
}

/// Adds `component` to `entity`.
pub fn add(self: *Self, entity: ecs.Entity, component: anytype) !void {
    try self.registry.add(entity, component);
}

/// Returns a `Query` that filters entities depending on the components
/// they have or not.
pub fn query(self: Self, comptime includes: anytype, comptime excludes: anytype) ecs.Query(includes, excludes) {
    return self.registry.query(includes, excludes);
}

/// Returns the first `Entity` with `tag`.
/// If none exist, returns `null`.
pub fn getFirstByTag(self: Self, tag: []const u8) ?ecs.Entity {
    if (!self.tags.contains(tag)) {
        return null;
    }

    const entity_list = self.tags.get(tag).?;

    if (entity_list.items.len == 0) {
        return null;
    }

    return entity_list.items[0];
}

/// Adds `tag` to `entity`.
pub fn addTag(self: *Self, entity: ecs.Entity, tag: []const u8) !void {
    if (!self.tags.contains(tag)) {
        const entity_list = std.ArrayListUnmanaged(ecs.Entity){};
        try self.tags.put(self.allocator, tag, entity_list);
    }

    const entity_list = self.tags.getPtr(tag).?;
    try entity_list.append(self.allocator, entity);
}
