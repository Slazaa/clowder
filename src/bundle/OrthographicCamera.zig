const root = @import("../root.zig");

const Self = @This();

camera: root.Camera,

pub fn init(size: root.Vec2u) Self {
    return .{
        .camera = .{
            .viewport = root.Viewport.default,
            .projection = root.mat.orthographicRhNo(
                -@as(f32, @floatFromInt(size[0] / 2)),
                @floatFromInt(size[0] / 2),
                -@as(f32, @floatFromInt(size[1] / 2)),
                @floatFromInt(size[1] / 2),
                -1,
                1,
            ),
        },
    };
}

pub fn build(self: Self, app: *root.App, entity: root.Entity) !void {
    try app.addComponent(entity, self.camera);
}
