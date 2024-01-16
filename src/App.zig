const std = @import("std");

const ecs = @import("clowder_ecs");

const Self = @This();

pub const System = *const fn (app: *Self) anyerror!void;
pub const DeinitSystem = *const fn (app: *Self) void;

pub const Plugin = struct {
    plugins: []const Plugin = &.{},

    init_systems: []const System = &.{},
    deinit_systems: []const DeinitSystem = &.{},
    systems: []const System = &.{},

    pub fn load(self: @This(), app: *Self) !void {
        for (self.plugins) |plugin| {
            try plugin.load(app);
        }

        for (self.init_systems) |system| {
            try system(app);
        }

        for (self.deinit_systems) |system| {
            const system_addr = @intFromPtr(system);
            try app.deinit_systems.append(system_addr);
        }

        for (self.systems) |system| {
            const system_addr = @intFromPtr(system);
            try app.systems.append(system_addr);
        }
    }
};

const SystemAddr = usize;

allocator: std.mem.Allocator,
registry: ecs.Registry,

deinit_systems: std.ArrayList(SystemAddr),
systems: std.ArrayList(SystemAddr),

is_exit: bool = false,

pub fn init(allocator: std.mem.Allocator, plugin: Plugin) !Self {
    var self = Self{
        .allocator = allocator,
        .registry = try ecs.Registry.init(allocator),

        .deinit_systems = std.ArrayList(SystemAddr).init(allocator),
        .systems = std.ArrayList(SystemAddr).init(allocator),
    };

    try plugin.load(&self);

    return self;
}

pub fn deinit(self: *Self) void {
    self.systems.deinit();
    self.deinit_systems.deinit();

    self.registry.deinit();
}

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

pub inline fn exit(self: *Self) void {
    self.is_exit = true;
}
