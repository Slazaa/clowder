const std = @import("std");

const root = @import("../root.zig");

/// A `Mesh` represent collection of vertices.
pub fn Mesh(comptime config: root.RendererConfig) type {
    return struct {
        const Self = @This();

        const Renderer = root.Renderer(config);
        const RenderObject = root.RenderObject(config.render_backend);

        positions: std.ArrayList(f32),
        colors: std.ArrayList(f32),
        uv_coords: std.ArrayList(f32),

        indices: std.ArrayList(u32),

        render_object: RenderObject,

        /// Initializes a new `Mesh`.
        /// Deinitialize it with `deinit`.
        pub fn init(
            allocator: std.mem.Allocator,
            positions: []const root.Vec3f,
            colors: []const root.Color,
            uv_coords: []const root.Vec2f,
            indices: []const root.Vec3u,
        ) !Self {
            var position_list = std.ArrayList(f32).init(allocator);
            errdefer position_list.deinit();

            var color_list = std.ArrayList(f32).init(allocator);
            errdefer color_list.deinit();

            var uv_coord_list = std.ArrayList(f32).init(allocator);
            errdefer uv_coord_list.deinit();

            var index_list = std.ArrayList(u32).init(allocator);
            errdefer index_list.deinit();

            // Positions
            for (positions) |position| {
                inline for (0..3) |i| {
                    try position_list.append(position[i]);
                }
            }

            // Colors
            for (0..positions.len) |i| {
                const color = if (i < colors.len)
                    colors[i]
                else
                    root.Color.white;

                try color_list.append(color.red);
                try color_list.append(color.green);
                try color_list.append(color.blue);
                try color_list.append(color.alpha);
            }

            // UV coords
            for (uv_coords) |uv| {
                inline for (0..2) |i| {
                    try uv_coord_list.append(uv[i]);
                }
            }

            // Indices
            for (indices) |triangle_indicies| {
                inline for (0..3) |i| {
                    try index_list.append(triangle_indicies[i]);
                }
            }

            const render_object = RenderObject.init(
                position_list.items,
                color_list.items,
                uv_coord_list.items,
                index_list.items,
            );

            return .{
                .positions = position_list,
                .colors = color_list,
                .uv_coords = uv_coord_list,

                .indices = index_list,

                .render_object = render_object,
            };
        }

        /// Sets the UV coords of the `Mesh`.
        pub fn setUvCoords(self: *Self, uv_coords: []const root.Vec2f) !void {
            self.uv_coords.clearRetainingCapacity();

            for (uv_coords) |uv| {
                inline for (0..2) |i| {
                    try self.uv_coords.append(uv[i]);
                }
            }

            self.render_object.setUvCoords(self.uv_coords.items);
        }

        /// Deinitilizes the `Mesh`.
        pub fn deinit(self: Self) void {
            self.indices.deinit();

            self.uv_coords.deinit();
            self.colors.deinit();
            self.positions.deinit();
        }
    };
}
