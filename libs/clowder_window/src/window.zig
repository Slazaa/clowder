const builtin = @import("builtin");
const std = @import("std");

const os = builtin.os;

const mem = std.mem;

const AutoArrayHashMap = std.AutoArrayHashMap;

const Allocator = mem.Allocator;

const cwl_math = @import("clowder_math");

const Vec2u = cwl_math.Vec2u;
const Vec2i = cwl_math.Vec2i;

const screen = @import("screen.zig");

const window_base = switch (os.tag) {
    .windows => @import("window/win32.zig"),
    else => @compileError("OS not supported"),
};

const WindowBase = window_base.WindowBase;

pub const WindowError = window_base.WindowError;

pub const WindowPos = union(enum) {
    center,
    at: Vec2i,
};

pub const RenderBackend = enum {
    opengl,
};

pub const Event = union(enum) {
    close,
};

pub const Window = struct {
    const Self = @This();

    base: WindowBase,
    render_backend: RenderBackend = .opengl,
    close_on_event: bool,
    open: bool = true,
    events: AutoArrayHashMap(Event, void),

    pub fn init(
        allocator: Allocator,
        title: [:0]const u8,
        position: WindowPos,
        size: Vec2u,
        render_backend: RenderBackend,
        close_on_event: bool,
    ) WindowError!Self {
        const position_vec = switch (position) {
            .center => @as(Vec2i, @intCast(screen.getSize(.primary) - size)) / Vec2i{ 2, 2 },
            .at => |at| at,
        };

        return .{
            .base = try WindowBase.init(title, position_vec[0], position_vec[1], size[0], size[1]),
            .render_backend = render_backend,
            .close_on_event = close_on_event,
            .events = AutoArrayHashMap(Event, void).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.events.deinit();
        self.base.deinit();
    }

    pub fn shouldClose(self: Self) bool {
        return self.events.contains(.close);
    }

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
