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

/// Represents a renderer.
/// The renderer renders stuff on a `Window`.
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

        /// Initializes a new `Renderer`.
        /// Deinitialize it with `deinit`.
        pub fn init(window: Window) Error!Self {
            return .{
                .window = window,
                .backend_base = try BackendBase.init(window),
            };
        }

        /// Deinitiliazes the `Renderer`.
        pub fn deinit(self: Self) void {
            self.backend_base.deinit();
        }

        /// Returns a `Context` of the `Renderer`.
        pub fn context(self: *Self) Context {
            return .{
                .renderer = self,

                .clear = Self.clear,
                .display = Self.display,
            };
        }

        /// Clears the `Renderer` with `color`.
        pub fn clear(_: Self, color: Color) void {
            Base.clear(color);
        }

        /// Swaps the buffers.
        pub fn swap(self: Self) void {
            BackendBase.swap(self.window);
        }
    };
}
