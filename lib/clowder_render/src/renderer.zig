const builtin = @import("builtin");

const clw_window = @import("clowder_window");

const Window = clw_window.Window;

const Color = @import("Color.zig");

const win32_opengl = @import("renderer/opengl/win32.zig");

pub const Error = win32_opengl.Error;

pub const Backend = enum {
    opengl,
};

pub const Context = struct {
    renderer: *Renderer,

    clear: *const fn (Color) void,
    display: *const fn () void,
};

pub fn Renderer(comptime backend: Backend) type {
    return struct {
        const Self = @This();

        const BackendBase = switch (backend) {
            .opengl => switch (builtin.os.tag) {
                .windows => win32_opengl.Base,
                else => @compileError("OS not supported"),
            },
        };

        const Base = switch (backend) {
            .opengl => @import("renderer/opengl.zig").Base,
        };

        window: Window,
        backend_base: BackendBase,

        pub fn init(window: Window) Error!Self {
            return .{
                .window = window,
                .backend_base = try BackendBase.init(window),
            };
        }

        pub fn deinit(self: Self) void {
            _ = self;
        }

        pub fn context(self: *Self) Context {
            return .{
                .renderer = self,

                .clear = Self.clear,
                .display = Self.display,
            };
        }

        pub fn clear(self: Self, color: Color) void {
            _ = self;
            Base.clear(color);
        }

        pub fn display(self: Self) void {
            BackendBase.display(self.window);
        }
    };
}
