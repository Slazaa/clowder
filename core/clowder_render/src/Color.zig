//! A struct representing a color.
//! Values are between `0` and `1`.

const Self = @This();

pub const black = rgb(0, 0, 0);
pub const blue = rgb(0, 0, 1);
pub const cyan = rgb(0, 1, 1);
pub const green = rgb(0, 1, 0);
pub const orange = rgb(1, 0.5, 0);
pub const pink = rgb(1, 0, 1);
pub const red = rgb(1, 0, 0);
pub const white = rgb(1, 1, 1);
pub const yellow = rgb(1, 1, 0);

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
