const std = @import("std");

const render = @import("clowder_render");
const math = @import("clowder_math");

pub fn Mesh(comptime config: render.RendererConfig) type {
    return struct {
        const Self = @This();

        const Renderer = render.Renderer(config);

        positions: std.ArrayList(f32),
        colors: std.ArrayList(f32),
        indices: std.ArrayList(u32),

        render_object: Renderer.RenderObject,

        pub fn init(
            allocator: std.mem.Allocator,
            positions: []const math.Vec3f,
            colors: []const render.Color,
            indices: []const math.Vec3u,
        ) !Self {
            var position_list = std.ArrayList(f32).init(allocator);
            errdefer position_list.deinit();

            var color_list = std.ArrayList(f32).init(allocator);
            errdefer color_list.deinit();

            var index_list = std.ArrayList(u32).init(allocator);
            errdefer index_list.deinit();

            for (positions) |position| {
                inline for (0..3) |i| {
                    try position_list.append(position[i]);
                }
            }

            for (colors) |color| {
                try color_list.append(color.red);
                try color_list.append(color.green);
                try color_list.append(color.blue);
                try color_list.append(color.alpha);
            }

            for (indices) |triangle_indicies| {
                inline for (0..3) |i| {
                    try index_list.append(triangle_indicies[i]);
                }
            }

            const render_object = Renderer.RenderObject.init(
                position_list.items,
                color_list.items,
                index_list.items,
            );

            return .{
                .positions = position_list,
                .colors = color_list,
                .indices = index_list,

                .render_object = render_object,
            };
        }

        pub fn deinit(self: Self) void {
            self.indices.deinit();
            self.colors.deinit();
            self.positions.deinit();
        }
    };
}
