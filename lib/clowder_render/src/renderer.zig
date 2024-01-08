const builtin = @import("builtin");

const clw_window = @import("clowder_window");

const Window = clw_window.Window;

const Color = @import("Color.zig");

pub const Backend = enum {
    opengl,
};

pub const Config = struct {
    backend: Backend = .opengl,
};

pub const Context = struct {
    renderer: *Renderer,

    clear: *const fn (color: Color) void,
    display: *const fn () void,
};

pub fn Renderer(comptime config: Config) type {
    return struct {
        const Self = @This();

        const backend_base = switch (config.backend) {
            .opengl => @import("base/opengl.zig"),
        };

        const Error = backend_base.Error;
        const BackendBase = backend_base.BackendBase;
        const Base = backend_base.Base;

        window: Window,
        backend_base: BackendBase,

        pub fn init(window: Window) Error!Self {
            return .{
                .window = window,
                .backend_base = try BackendBase.init(window),
            };
        }

        pub fn deinit(_: Self) void {}

        pub fn context(self: *Self) Context {
            return .{
                .renderer = self,

                .clear = Self.clear,
                .display = Self.display,
            };
        }

        pub fn clear(_: Self, color: Color) void {
            Base.clear(color);
        }

        pub fn display(self: Self) void {
            BackendBase.display(self.window);
        }
    };
}
