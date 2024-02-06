const root = @import("root.zig");

pub const beginner = @import("plugin/beginner.zig").plugin;

/// A `Plugin` is bundle of `System`s and `DeinitSystem`s which you can add to
/// your `App`.
/// `Plugin`s can also hold other `Plugin`s.
pub const Plugin = struct {
    plugins: []const Plugin = &.{},

    initSystems: []const root.System = &.{},
    deinitSystems: []const root.DeinitSystem = &.{},
    systems: []const root.System = &.{},

    /// Loads the `Plugin` to the `App`.
    /// You probably shouldn't call this.
    pub fn load(self: @This(), app: *root.App) !void {
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
