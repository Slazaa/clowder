const Self = @This();

x: f32,
y: f32,
width: f32,
height: f32,

pub fn init(x: f32, y: f32, width: f32, height: f32) Self {
    return .{ .x = x, .y = y, .width = width, .height = height };
}
