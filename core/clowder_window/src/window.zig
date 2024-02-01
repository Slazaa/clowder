const builtin = @import("builtin");
const std = @import("std");

const clw_math = @import("clowder_math");

const root = @import("root.zig");

pub const WindowPos = union(enum) {
    center,
    at: clw_math.Vec2i,
};

pub const Event = enum(u1) {
    close,
};

pub const default_backend: root.Backend = switch (builtin.os.tag) {
    .windows => .win32,
    else => @compileError("OS not supported"),
};

pub const Config = packed struct {
    resizable: bool = false,
    maximize_box: bool = false,
    minimize_box: bool = true,
};

/// Represents a window.
pub fn Window(comptime backend: root.Backend) type {
    return struct {
        const Self = @This();

        const base = switch (backend) {
            .win32 => @import("base/win32.zig"),
        };

        pub const Error = base.Error;

        const Base = base.Base;
        const Screen = root.Screen(backend);

        pub const Context = struct {
            comptime backend: root.Backend = backend,
            base: Base,
        };

        base: Base,
        events: std.ArrayList(Event),

        /// Intializes a new `Window`.
        /// Deinitiliaze it with `deinit`.
        pub fn init(
            allocator: std.mem.Allocator,
            title: [:0]const u8,
            position: WindowPos,
            size: clw_math.Vec2u,
            config: Config,
        ) Error!Self {
            const position_vec = switch (position) {
                .center => @as(clw_math.Vec2i, @intCast(Screen.getSize(.primary) - size)) /
                    @as(clw_math.Vec2i, @splat(2)),
                .at => |at| at,
            };

            const base_config: base.Config = @bitCast(config);

            return .{
                .base = try Base.init(title, position_vec[0], position_vec[1], size[0], size[1], base_config),
                .events = std.ArrayList(Event).init(allocator),
            };
        }

        /// Deinitiliazes the `Window`.
        pub fn deinit(self: Self) void {
            self.events.deinit();
            self.base.deinit();
        }

        /// Returns a `Context` of the `Window`.
        pub fn context(self: *Self) Context {
            return .{
                .base = self.base,
            };
        }

        /// Returns `true` if `event` is emitted.
        /// Else returns `false`.
        pub fn isEventEmitted(self: Self, event: Event) bool {
            return std.mem.containsAtLeast(Event, self.events.items, 1, &.{event});
        }

        /// Emits `event`.
        pub fn emitEvent(self: *Self, event: Event) !void {
            try self.events.append(event);
        }

        /// Returns `true` if `Event.close` is emitted.
        /// Else returns `false`.
        pub fn shouldClose(self: Self) bool {
            return self.isEventEmitted(.close);
        }

        /// Updates the `Window`.
        pub fn update(self: *Self) !void {
            self.events.clearRetainingCapacity();

            while (self.base.pollEvent()) |event| {
                try self.emitEvent(event);
            }
        }
    };
}

pub const DefaultWindow = Window(default_backend);
