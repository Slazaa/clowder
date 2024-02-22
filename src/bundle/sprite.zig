const std = @import("std");

const root = @import("../root.zig");

pub fn Sprite(comptime config: root.RendererConfig) type {
    return struct {
        const Self = @This();

        const Rectangle = root.bundle.Rectangle(config);
        const Material = root.Material(config.render_backend);

        rectangle: Rectangle,
        material: Material,

        pub fn init(allocator: std.mem.Allocator, size: root.Vec2f, maybe_frame: ?root.Rect, material: Material) !Self {
            var rectangle = try Rectangle.init(allocator, size, null);
            errdefer rectangle.deinit();

            if (material.texture) |texture| {
                const frame = maybe_frame orelse root.Rect.init(0, 0, @floatFromInt(texture.size[0]), @floatFromInt(texture.size[1]));
                const texture_size: root.Vec2f = @floatFromInt(texture.size);

                const uv_coords = &.{
                    .{ frame.x / texture_size[0], frame.y / texture_size[1] },
                    .{ frame.x / texture_size[0], (frame.y + frame.height) / texture_size[1] },
                    .{ (frame.x + frame.width) / texture_size[0], frame.y / texture_size[1] },
                    .{ (frame.x + frame.width) / texture_size[0], (frame.y + frame.height) / texture_size[1] },
                };

                try rectangle.mesh.setUvCoords(uv_coords);
            }

            return .{
                .rectangle = rectangle,
                .material = material,
            };
        }

        pub fn deinit(self: Self) void {
            self.rectangle.deinit();
        }

        pub fn build(self: Self, app: *root.App, entity: root.Entity) !void {
            try app.addBundle(entity, self.rectangle);
            try app.addComponent(entity, self.material);
        }
    };
}
