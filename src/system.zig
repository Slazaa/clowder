const root = @import("root.zig");

pub const System = *const fn (app: *root.App) anyerror!void;
pub const DeinitSystem = *const fn (app: *root.App) void;
