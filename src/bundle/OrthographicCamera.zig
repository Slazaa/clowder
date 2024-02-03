const math = @import("clowder_math");
const render = @import("clowder_render");

const root = @import("../root.zig");

const Self = @This();

camera: render.Camera,

pub fn init(size: math.Vec2u) Self {
    return .{
        .camera = .{
            .viewport = render.Viewport.default,
            .projection = math.mat.orthographicRhNo(
                -@as(f32, @floatFromInt(size[0] / 2)),
                @as(f32, @floatFromInt(size[0] / 2)),
                -@as(f32, @floatFromInt(size[1] / 2)),
                @as(f32, @floatFromInt(size[1] / 2)),
                -1,
                1,
            ),
        },
    };
}

pub fn build(self: Self, app: *root.App, entity: root.Entity) !void {
    try app.addComponent(entity, self.camera);
}
