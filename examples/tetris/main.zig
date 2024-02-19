const std = @import("std");

const clw = @import("clowder");

pub const PieceKind = enum { i, j, l, o, s, t, z };

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.plugin.beginner},
    });

    defer app.deinit();

    try app.run();
}
