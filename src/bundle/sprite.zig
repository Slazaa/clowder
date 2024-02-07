const std = @import("std");

const root = @import("../root.zig");

pub fn Sprite(comptime config: root.RendererConfig) type {
    return struct {
        const Self = @This();

        const Rectangle = root.bundle.Rectangle(config);
        const Material = root.Material(config.render_backend);

        rectangle: Rectangle,
        material: Material,

        pub fn init(allocator: std.mem.Allocator, size: root.Vec2f, material: Material) !Self {
            return .{
                .rectangle = try Rectangle.init(allocator, size),
                .material = material,
            };
        }

        pub fn build(self: Self, app: *root.App, entity: root.Entity) !void {
            try app.addBundle(entity, self.rectangle);
            try app.addComponent(entity, self.material);
        }
    };
}
