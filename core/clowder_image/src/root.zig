const std = @import("std");

const math = @import("clowder_math");

// pub const png = @import("png.zig"); // WIP
pub const tga = @import("tga.zig");

pub const Error = error{
    InvalidFormat,
};

pub fn Rgb(comptime T: type) type {
    return packed struct { r: T, g: T, b: T };
}

pub const Rgb24 = Rgb(u8);

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

pub fn loadImage(allocator: std.mem.Allocator, path: [:0]const u8) !Image {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const reader = file.reader();

    // TGA
    if (std.mem.endsWith(u8, path, ".tga")) {
        return try tga.load(allocator, reader);
    }

    // Invalid format.
    else {
        return Error.InvalidFormat;
    }
}
