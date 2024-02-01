const math = @import("clowder_math");

const Self = @This();

pub const default = init(
    math.Vec3f.zero,
    .{ 1, 1, 1 },
    math.Vec2f.zero,
);

position: math.Vec3f,
scale: math.Vec3f,
rotation: math.Vec2f,

pub fn init(position: math.Vec3f, scale: math.Vec3f, rotation: math.Vec2f) Self {
    return .{
        .position = position,
        .scale = scale,
        .rotation = rotation,
    };
}
