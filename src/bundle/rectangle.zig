const std = @import("std");

const root = @import("../root.zig");

/// This plugin creates rectangular `Mesh` component.
pub fn Rectangle(comptime config: root.RendererConfig) type {
    return struct {
        const Self = @This();

        const Material = root.Material(config.render_backend);
        const Mesh = root.Mesh(config);

        mesh: Mesh,
        material: ?Material,

        /// Initiliazes a new `Rectangle` with size `size`.
        pub fn init(allocator: std.mem.Allocator, size: root.Vec2f, color: ?root.Color) !Self {
            const half_size = size / @as(root.Vec2f, @splat(2));

            const mesh = try Mesh.init(
                allocator,
                &.{
                    .{ -half_size[0], -half_size[0], 0 },
                    .{ -half_size[0], half_size[0], 0 },
                    .{ half_size[0], -half_size[0], 0 },
                    .{ half_size[0], half_size[0], 0 },
                },
                &(.{root.Color.white} ** 4),
                &.{
                    .{ 0, 0 },
                    .{ 0, 1 },
                    .{ 1, 0 },
                    .{ 1, 1 },
                },
                &.{
                    .{ 0, 1, 2 },
                    .{ 1, 3, 2 },
                },
            );

            errdefer mesh.deinit();

            const material: ?Material = if (color) |color_|
                .{
                    .color = color_,
                }
            else
                null;

            return .{
                .mesh = mesh,
                .material = material,
            };
        }

        /// This should be called in case of error before adding the bundle.
        pub fn deinit(self: Self) void {
            self.mesh.deinit();
        }

        pub fn build(self: Self, app: *root.App, entity: root.Entity) !void {
            try app.addComponent(entity, self.mesh);

            if (self.material) |material| {
                try app.addComponent(entity, material);
            }
        }
    };
}
