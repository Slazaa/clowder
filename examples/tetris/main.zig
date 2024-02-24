const std = @import("std");

const clw = @import("clowder");

pub const PieceKind = enum { i, j, l, o, s, t, z };

fn spawnPiece(app: *clw.App, image: clw.Image, kind: PieceKind) !clw.Entity {
    const index: usize = @intFromEnum(kind);

    const tile_size = clw.Vec2f{ 30, 30 };

    const positions: [4]clw.Vec3f = switch (kind) {
        .i => .{
            .{ -tile_size[0], 0, 0 },
            .{ 0, 0, 0 },
            .{ tile_size[0], 0, 0 },
            .{ tile_size[0] * 2, 0, 0 },
        },
        .j => .{
            .{ -tile_size[0], 0, 0 },
            .{ 0, 0, 0 },
            .{ tile_size[0], 0, 0 },
            .{ tile_size[0], tile_size[1], 0 },
        },
        .l => .{
            .{ -tile_size[0], 0, 0 },
            .{ 0, 0, 0 },
            .{ tile_size[0], 0, 0 },
            .{ -tile_size[0], tile_size[1], 0 },
        },
        .o => .{
            .{ 0, 0, 0 },
            .{ tile_size[0], 0, 0 },
            .{ 0, tile_size[1], 0 },
            .{ tile_size[0], tile_size[1], 0 },
        },
        .s => .{
            .{ 0, 0, 0 },
            .{ tile_size[0], 0, 0 },
            .{ -tile_size[0], tile_size[1], 0 },
            .{ 0, tile_size[1], 0 },
        },
        .t => .{
            .{ 0, -tile_size[1], 0 },
            .{ -tile_size[0], 0, 0 },
            .{ 0, 0, 0 },
            .{ tile_size[0], 0, 0 },
        },
        .z => .{
            .{ -tile_size[0], 0, 0 },
            .{ 0, 0, 0 },
            .{ 0, tile_size[1], 0 },
            .{ tile_size[0], tile_size[1], 0 },
        },
    };

    const m1 = clw.Mat2x2f.init(&.{
        &.{ 1, 0 },
        &.{ 2, -1 },
    });

    const m2 = clw.Mat2x2f.init(&.{
        &.{ 3, 4 },
        &.{ -2, -3 },
    });

    std.debug.print("{d:.2}\n", .{clw.Mat2x2f.mult(m1, m2)});

    const piece = app.spawn();

    for (0..4) |i| {
        const tile = app.spawn();

        const sprite_bundle = try clw.bundle.Sprite(.{}).init(
            app.allocator,
            tile_size,
            clw.Rect.init(@floatFromInt(8 * index), 0, 8, 8),
            .{ .texture = clw.DefaultTexture.initFromImage(image, .{}) },
        );

        errdefer sprite_bundle.deinit();

        try app.addBundle(tile, sprite_bundle);
        try app.addComponent(tile, clw.Transform.init(positions[i], .{ 1, 1, 1 }, .{ 0, 0, 0 }));

        try app.addChild(piece, tile);
    }

    return piece;
}

fn initSystem(app: *clw.App) !void {
    const current_path = comptime std.fs.path.dirname(@src().file).?;

    const tile_path = current_path ++ "/tiles.png";

    const tile_image = try clw.loadImageFromFile(app.allocator, tile_path);
    defer tile_image.deinit();

    const piece = try spawnPiece(app, tile_image, .i);
    _ = piece;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.plugin.beginner},
        .initSystems = &.{initSystem},
    });

    defer app.deinit();

    try app.run();
}
