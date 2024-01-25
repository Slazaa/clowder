const std = @import("std");

const root = @import("../root.zig");

pub const DefaultMaterial = struct { root.DefaultMaterial };

const default_vertex_shader_source =
    \\#version 450 core
    \\
    \\layout(location = 0) in vec3 aPosition;
    \\layout(location = 1) in vec4 aColor;
    \\
    \\out vec4 fColor;
    \\
    \\void main() {
    \\    gl_Position = vec4(aPosition, 1.0f);
    \\    fColor = aColor;
    \\}
;

const default_fragment_shader_source =
    \\#version 450 core
    \\
    \\in vec4 fColor;
    \\
    \\out vec4 color;
    \\
    \\void main() {
    \\    color = fColor;
    \\}
;

pub fn initWindowSystem(app: *root.App) !void {
    const main_window = app.spawn();

    var window = try root.DefaultWindow.init(
        app.allocator,
        "Clowder Window",
        .center,
        .{ 800, 600 },
        .{},
    );

    errdefer window.deinit();

    const renderer = try root.Renderer(.{}).init(window.context());
    errdefer renderer.deinit();

    try app.addComponent(main_window, window);
    try app.addComponent(main_window, renderer);
}

pub fn initDefaultMaterialSystem(app: *root.App) !void {
    const default_material = app.spawn();

    const material = try root.DefaultMaterial.init(
        root.DefaultShader(.vertex).fromSource(default_vertex_shader_source),
        root.DefaultShader(.fragment).fromSource(default_fragment_shader_source),
    );

    try app.addComponent(default_material, DefaultMaterial{material});
}

pub fn deinitSystem(app: *root.App) void {
    var query = app.query(.{ root.DefaultWindow, root.Renderer(.{}) }, .{});

    while (query.next()) |entity| {
        const window = app.getComponent(entity, root.DefaultWindow).?;
        const renderer = app.getComponent(entity, root.Renderer(.{})).?;

        window.deinit();
        renderer.deinit();

        var mesh_query = app.query(.{root.Mesh(.{})}, .{});

        while (mesh_query.next()) |mesh_entity| {
            const mesh = app.getComponent(mesh_entity, root.Mesh(.{})).?;
            mesh.deinit();
        }
    }
}

pub fn system(app: *root.App) !void {
    const default_material_entity = app.getFirst(.{DefaultMaterial}, .{}).?;
    const default_material = app.getComponent(default_material_entity, DefaultMaterial).?[0];

    var query = app.query(.{ root.DefaultWindow, root.Renderer(.{}) }, .{});

    while (query.next()) |entity| {
        const window = app.getComponentPtr(entity, root.DefaultWindow).?;
        const renderer = app.getComponent(entity, root.Renderer(.{})).?;

        try window.update();

        if (window.shouldClose()) {
            app.exit();
        }

        renderer.clear(root.Color.rgb(0.1, 0.1, 0.1));

        var mesh_query = app.query(.{root.Mesh(.{})}, .{});

        while (mesh_query.next()) |mesh_entity| {
            const mesh = app.getComponent(mesh_entity, root.Mesh(.{})).?;
            renderer.render(mesh.render_object, default_material);
        }

        renderer.swap();
    }
}

pub const plugin = root.App.Plugin{
    .initSystems = &.{
        initWindowSystem,
        initDefaultMaterialSystem,
    },
    .deinitSystems = &.{deinitSystem},
    .systems = &.{system},
};
