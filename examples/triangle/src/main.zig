const std = @import("std");

const clw = @import("clowder");

pub fn main() !void {
    var app = try clw.App.init(.{
        .plugins = &.{clw.defaultPlugin},
    });

    defer app.deinit();
}
