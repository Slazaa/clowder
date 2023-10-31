const Self = @This();

pub const white = Self.rgb(1, 1, 1);
pub const black = Self.rgb(0, 0, 0);

pub const red = Self.rgb(1, 0, 0);
pub const green = Self.rgb(0, 1, 0);
pub const blue = Self.rgb(0, 0, 1);

red: f32,
green: f32,
blue: f32,
alpha: f32,

pub fn rgba(r: f32, g: f32, b: f32, a: f32) Self {
    return .{ .red = r, .green = g, .blue = b, .alpha = a };
}

pub fn rgb(r: f32, g: f32, b: f32) Self {
    return rgba(r, g, b, 1);
}
