const std = @import("std");

const math = @import("clowder_math");

// pub const png = @import("png.zig"); // WIP
// pub const tga = @import("tga.zig"); // WIP

const img = @import("zigimg");

pub const Error = error{
    InvalidFormat,
};

pub const Image = struct {
    const Self = @This();

    data: std.ArrayList(u8),
    size: math.Vec2u,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .data = std.ArrayList(u8).init(allocator),
            .size = undefined,
        };
    }

    pub fn deinit(self: Self) void {
        self.data.deinit();
    }
};

pub fn loadImage(allocator: std.mem.Allocator, path: []const u8) !Image {
    const img_image = try img.Image.fromFilePath(allocator, path);

    const image = Image{
        .data = std.ArrayList(u8).fromOwnedSlice(allocator, img_image.pixels.asBytes()),
        .size = .{ @intCast(img_image.width), @intCast(img_image.height) },
    };

    return image;
}
