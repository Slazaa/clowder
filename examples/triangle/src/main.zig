const std = @import("std");

const clw = @import("clowder");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.App.init(allocator, clw.default_plugin);
    defer app.deinit();

    try app.run();
}
