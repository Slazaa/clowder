const builtin = @import("builtin");
const std = @import("std");

const clw_math = @import("clowder_math");

const screen = @import("screen.zig");

pub const Backend = enum {
    win32,
};

pub const WindowPos = union(enum) {
    center,
    at: clw_math.Vec2i,
};

pub const Event = enum(u1) {
    close,
};

pub const default_backend: Backend = switch (builtin.os.tag) {
    .windows => .win32,
    else => @compileError("OS not supported"),
};

/// Represents a window.
pub fn Window(comptime backend: Backend) type {
    return struct {
        const Self = @This();

        const base = switch (backend) {
            .win32 => @import("base/win32.zig"),
        };

        pub const Error = base.Error;

        const Base = base.Base;

        pub const Context = struct {
            comptime backend: Backend = backend,
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
        ) Error!Self {
            const position_vec = switch (position) {
                .center => @as(clw_math.Vec2i, @intCast(screen.getSize(.primary) - size)) /
                    @as(clw_math.Vec2i, @splat(2)),
                .at => |at| at,
            };

            return .{
                .base = try Base.init(title, position_vec[0], position_vec[1], size[0], size[1]),
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

        pub fn hasEvent(self: Self, event: Event) bool {
            return std.mem.containsAtLeast(Event, self.events.items, 1, &.{event});
        }

        pub fn emitEvent(self: *Self, event: Event) !void {
            try self.events.append(event);
        }

        /// Returns `true` if `Event.close` is emitted.
        /// Else returns `false`.
        pub fn shouldClose(self: Self) bool {
            return self.hasEvent(.close);
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
