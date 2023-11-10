const builtin = @import("builtin");
const std = @import("std");

const mem = std.mem;

const AutoArrayHashMap = std.AutoArrayHashMap;

const Allocator = mem.Allocator;

const cwl_math = @import("clowder_math");

const Vec2u = cwl_math.Vec2u;
const Vec2i = cwl_math.Vec2i;

const screen = @import("screen.zig");

const base = switch (builtin.os.tag) {
    .windows => @import("base/win32.zig"),
    else => @compileError("OS not supported"),
};

const Base = base.Base;

pub const Error = base.Error;

pub const WindowPos = union(enum) {
    center,
    at: Vec2i,
};

pub const Event = union(enum) {
    close,
};

pub const Window = struct {
    const Self = @This();

    base: Base,
    close_on_event: bool,
    open: bool = true,
    events: AutoArrayHashMap(Event, void),

    /// Intializes a new `Window`.
    /// Deinitiliaze it with `deinit`.
    pub fn init(
        allocator: Allocator,
        title: [:0]const u8,
        position: WindowPos,
        size: Vec2u,
        close_on_event: bool,
    ) Error!Self {
        const position_vec = switch (position) {
            .center => @as(Vec2i, @intCast(screen.getSize(.primary) - size)) / Vec2i{ 2, 2 },
            .at => |at| at,
        };

        return .{
            .base = try Base.init(title, position_vec[0], position_vec[1], size[0], size[1]),
            .close_on_event = close_on_event,
            .events = AutoArrayHashMap(Event, void).init(allocator),
        };
    }

    /// Deinitiliazes the `Window`.
    pub fn deinit(self: *Self) void {
        self.events.deinit();
        self.base.deinit();
    }

    /// Returns `true` if `Event.close` is emitted.
    /// Else returns `false`.
    pub fn shouldClose(self: Self) bool {
        return self.events.contains(.close);
    }

    /// Updates the `Window`.
    pub fn update(self: *Self) !void {
        self.events.clearRetainingCapacity();

        while (self.base.pollEvent()) |event| {
            try self.events.put(event, void{});
        }

        if (self.close_on_event and self.shouldClose()) {
            self.open = false;
        }
    }
};
