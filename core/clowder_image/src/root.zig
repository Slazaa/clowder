const std = @import("std");

const math = @import("clowder_math");

pub const png = @import("png.zig"); // WIP
// pub const tga = @import("tga.zig"); // WIP

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

pub fn Rgb(comptime T: type) type {
    return struct { red: T, green: T, blue: T };
}

pub const Rgb24 = Rgb(u8);

pub fn Rgba(comptime T: type) type {
    return struct { red: T, green: T, blue: T, alpha: T };
}

pub const Rgba32 = Rgba(u8);

pub fn loadImageFromPath(allocator: std.mem.Allocator, path: []const u8) !Image {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var stream = std.io.StreamSource{ .file = file };

    if (std.mem.endsWith(u8, path, ".png")) {
        return try png.loadFromStream(allocator, &stream);
    } else {
        return error.FormatNotSupported;
    }
}
