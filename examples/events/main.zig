const std = @import("std");

const clw = @import("clowder");

const SelectedColor = struct {
    const Self = @This();

    pub const colors = [_]clw.Color{
        clw.Color.rgb(0.8, 0.0, 0.0),
        clw.Color.rgb(0.0, 0.8, 0.0),
        clw.Color.rgb(0.0, 0.0, 0.8),
    };

    index: usize = 0,

    pub fn next(self: *Self) clw.Color {
        const res = self.index;

        self.index += 1;

        if (self.index >= colors.len) {
            self.index = 0;
        }

        return colors[res];
    }
};

fn initSystem(app: *clw.App) !void {
    const rect = app.spawn();

    var selected_color = SelectedColor{};

    const rectangle_bundle = try clw.bundle.Rectangle(.{}).init(
        app.allocator,
        .{ 256, 256 },
        selected_color.next(),
    );

    errdefer rectangle_bundle.deinit();

    try app.addBundle(rect, rectangle_bundle);
    try app.addComponent(rect, selected_color);
}

fn system(app: *clw.App) !void {
    const window_entity = app.getFirst(.{clw.DefaultWindow}, .{}).?;
    const window = app.getComponent(window_entity, clw.DefaultWindow).?;

    const rect = app.getFirst(.{SelectedColor}, .{}).?;

    const material = app.getComponentPtr(rect, clw.DefaultMaterial).?;
    const selected_color = app.getComponentPtr(rect, SelectedColor).?;

    if (window.isKeyPressed(.space)) {
        material.color = selected_color.next();
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    var app = try clw.init(allocator, .{
        .plugins = &.{clw.plugin.beginner},
        .initSystems = &.{initSystem},
        .systems = &.{system},
    });

    defer app.deinit();

    try app.run();
}
