const math = @import("clowder_math");

const Self = @This();

pub const default = init(
    @splat(0),
    @splat(1),
    @splat(0),
);

position: math.Vec3f,
scale: math.Vec3f,
rotation: math.Vec3f,

pub fn init(position: math.Vec3f, scale: math.Vec3f, rotation: math.Vec3f) Self {
    return .{
        .position = position,
        .scale = scale,
        .rotation = rotation,
    };
}

pub fn combine(first: Self, second: Self) Self {
    return init(
        first.position + second.position,
        first.scale * second.scale,
        first.rotation + second.rotation,
    );
}
