const builtin = @import("builtin");
const std = @import("std");

const window = @import("clowder_window");
const math = @import("clowder_math");

const Color = @import("Color.zig");

pub const Backend = enum {
    opengl,
};

pub const Config = struct {
    render_backend: Backend = .opengl,
    window_backend: window.Backend = window.default_backend,
};

pub const Context = struct {
    clear: *const fn (color: Color) void,
    display: *const fn () void,
};

/// Represents a renderer.
/// The renderer renders stuff on a `Window`.
pub fn Renderer(comptime config: Config) type {
    return struct {
        const Self = @This();

        const backend_base = switch (config.render_backend) {
            .opengl => switch (config.window_backend) {
                .win32 => @import("base/opengl/win32.zig"),
            },
        };

        pub const Error = backend_base.Error;

        pub const RenderObject = backend_base.RenderObject;

        const Base = backend_base.Base;

        const Window = window.Window(config.window_backend);

        window_context: Window.Context,
        backend_base: Base,

        /// Initializes a new `Renderer`.
        /// Deinitialize it with `deinit`.
        pub fn init(window_context: Window.Context, shader_report: ?*std.ArrayList(u8)) !Self {
            if (window_context.backend != config.window_backend) {
                @compileError("Renderer backend does not match window backend");
            }

            return .{
                .window_context = window_context,
                .backend_base = try Base.init(window_context, shader_report),
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
            Base.swap(self.window_context);
        }

        pub fn render(_: Self, render_object: RenderObject) void {
            Base.render(render_object);
        }
    };
}
