const builtin = @import("builtin");
const std = @import("std");

const math = @import("clowder_math");

const root = @import("root.zig");

pub const WindowPos = union(enum) {
    center,
    at: math.Vec2i,
};

pub const Config = struct {
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
            .x11 => @import("base/x11.zig"),
        };

        pub const Error = base.Error;

        const Base = base.Base;
        const Screen = root.Screen(backend);

        pub const Context = struct {
            comptime backend: root.Backend = backend,
            base: Base,
        };

        base: Base,
        events: std.ArrayList(root.Event),

        /// Intializes a new `Window`.
        /// Deinitiliaze it with `deinit`.
        pub fn init(allocator: std.mem.Allocator, title: [:0]const u8, position: WindowPos, size: math.Vec2u, config: Config) Error!Self {
            const position_vec = switch (position) {
                .center => @as(math.Vec2i, @intCast(Screen.getSize(.primary) - size)) /
                    @as(math.Vec2i, @splat(2)),
                .at => |at| at,
            };

            const base_ = try Base.init(
                title,
                position_vec[0],
                position_vec[1],
                size[0],
                size[1],
                config,
            );

            errdefer base_.deinit();

            return .{
                .base = base_,
                .events = std.ArrayList(root.Event).init(allocator),
            };
        }

        /// Deinitiliazes the `Window`.
        pub fn deinit(self: Self) void {
            self.events.deinit();
            self.base.deinit();
        }

        /// Returns the size of the `Window`.
        pub inline fn getSize(self: Self) math.Vec2u {
            return self.base.getSize();
        }

        /// Sets the tile of the `Window` to `title`.
        pub inline fn setTitle(self: Self, title: [:0]const u8) void {
            self.base.setTitle(title);
        }

        /// Returns a `Context` of the `Window`.
        pub fn context(self: *Self) Context {
            return .{
                .base = self.base,
            };
        }

        fn emitEvent(self: *Self, event: root.Event) !void {
            try self.events.append(event);
        }

        fn getKeyEventPtr(self: *Self, key_code: root.Event.KeyCode, state: root.Event.KeyState) ?*root.Event.Key {
            for (self.events.items) |*event| {
                const key = switch (event.*) {
                    .key => |*key| key,
                    else => continue,
                };

                if (key.code != key_code or key.state != state) {
                    continue;
                }

                return key;
            }

            return null;
        }

        fn updateKeyDown(self: *Self, key_code: root.Event.KeyCode) !void {
            const key = self.getKeyEventPtr(key_code, .down) orelse {
                try self.emitEvent(.{ .key = .{
                    .code = key_code,
                    .state = .down,
                } });

                return;
            };

            key.tick += 1;
        }

        /// Returns `true` if `Event.close` is emitted.
        /// Else returns `false`.
        pub fn shouldClose(self: Self) bool {
            for (self.events.items) |event| {
                if (event == .close) {
                    return true;
                }
            }

            return false;
        }

        /// Returns `true` if `key_code` is emitted with `state` and `tick`.
        /// Else returns `false`.
        ///
        /// Consider using `isKeyPressed`, `isKeyDown` or `isKeyReleased`.
        pub fn isKeyInState(
            self: Self,
            key_code: root.Event.KeyCode,
            state: root.Event.KeyState,
            tick: ?u32,
        ) bool {
            for (self.events.items) |event| {
                const key = switch (event) {
                    .key => |key| key,
                    else => continue,
                };

                const valid_tick = if (tick) |tick_|
                    key.tick == tick_
                else
                    true;

                if (key.code == key_code and key.state == state and valid_tick) {
                    return true;
                }
            }

            return false;
        }

        /// Returns `true` if `key_code` is emitted with state `.down` on first tick.
        pub inline fn isKeyPressed(self: Self, key_code: root.Event.KeyCode) bool {
            return self.isKeyInState(key_code, .down, 0);
        }

        /// Returns `true` if `key_code` is emitted with state `.down`.
        pub inline fn isKeyDown(self: Self, key_code: root.Event.KeyCode) bool {
            return self.isKeyInState(key_code, .down, null);
        }

        /// Returns `true` if `key_code` is emitted with state `.released`.
        pub inline fn isKeyReleased(self: Self, key_code: root.Event.KeyCode) bool {
            return self.isKeyInState(key_code, .released, null);
        }

        fn clearEvents(self: *Self) void {
            var i: usize = 0;

            while (i < self.events.items.len) {
                const event = &self.events.items[i];

                const key = switch (event.*) {
                    .key => |*key| key,
                    else => {
                        _ = self.events.orderedRemove(i);
                        continue;
                    },
                };

                if (key.state == .released) {
                    const key_ = self.events.orderedRemove(i).key;

                    var j: usize = 0;

                    while (j != self.events.items.len) {
                        const sub_event = self.events.items[j];

                        const sub_key = switch (sub_event) {
                            .key => |sub_key| sub_key,
                            else => {
                                j += 1;
                                continue;
                            },
                        };

                        if (sub_key.code != key_.code or sub_key.state != .down) {
                            j += 1;
                            continue;
                        }

                        _ = self.events.orderedRemove(j);
                    }

                    continue;
                }

                key.tick += 1;
                i += 1;
            }
        }

        /// Updates the `Window`.
        pub fn update(self: *Self) !void {
            self.clearEvents();

            while (self.base.pollEvent()) |event| {
                const key = switch (event) {
                    .key => |key| key,
                    else => {
                        try self.emitEvent(event);
                        continue;
                    },
                };

                if (key.state != .down) {
                    try self.emitEvent(event);
                    continue;
                }

                try self.updateKeyDown(key.code);
            }
        }
    };
}
