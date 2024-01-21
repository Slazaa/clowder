const std = @import("std");

const render = @import("clowder_render");
const math = @import("clowder_math");

pub fn Mesh(comptime config: render.RendererConfig) type {
    return struct {
        const Self = @This();

        const Renderer = render.Renderer(config);

        vertices: std.ArrayList(math.Vertex),
        render_object: Renderer.RenderObject,

        pub fn init(allocator: std.mem.Allocator, vertices: []const math.Vertex) !Self {
            var vertices_list = std.ArrayList(math.Vertex).init(allocator);
            errdefer vertices_list.deinit();

            try vertices_list.appendSlice(vertices);

            const render_object = Renderer.RenderObject.init(vertices_list.items);

            return .{
                .vertices = vertices_list,
                .render_object = render_object,
            };
        }

        pub fn deinit(self: Self) void {
            self.vertices.deinit();
        }
    };
}
