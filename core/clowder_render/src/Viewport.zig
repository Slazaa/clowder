const math = @import("clowder_math");

const Self = @This();

position: math.Vec2f,
size: math.Vec2f,

pub const default = Self{
    .position = math.Vec2f{ 0, 0 },
    .size = math.Vec2f{ 1, 1 },
};
