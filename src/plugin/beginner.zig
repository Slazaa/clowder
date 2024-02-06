const std = @import("std");

const root = @import("../root.zig");

pub const DefaultShader = struct { root.DefaultShader };
pub const DefaultMaterial = struct { root.DefaultMaterial };

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

pub fn initCameraSystem(app: *root.App) !void {
    const window_entity = app.getFirst(.{ root.DefaultWindow, root.Renderer(.{}) }, .{}).?;
    const window = app.getComponent(window_entity, root.DefaultWindow).?;

    const camera = app.spawn();

    try app.addBundle(camera, root.bundle.OrthographicCamera.init(window.getSize()));
}

pub fn initDefaultShaderSystem(app: *root.App) !void {
    const shader_entity = app.spawn();

    const shader = try root.DefaultShader.default();
    try app.addComponent(shader_entity, DefaultShader{shader});
}

pub fn initDefaultMaterialSystem(app: *root.App) !void {
    const default_shader_entity = app.getFirst(.{DefaultShader}, .{}).?;
    const default_shader = app.getComponent(default_shader_entity, DefaultShader).?[0];

    const material_entity = app.spawn();

    const material = root.DefaultMaterial.init(default_shader, null, null);
    try app.addComponent(material_entity, DefaultMaterial{material});
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

    const window_entity = app.getFirst(.{ root.DefaultWindow, root.Renderer(.{}) }, .{}).?;

    const window = app.getComponentPtr(window_entity, root.DefaultWindow).?;
    const renderer = app.getComponent(window_entity, root.Renderer(.{})).?;

    try window.update();

    if (window.shouldClose()) {
        app.exit();
    }

    renderer.clear(root.Color.rgb(0.1, 0.1, 0.1));

    var camera_query = app.query(.{root.Camera}, .{});

    while (camera_query.next()) |camera_entity| {
        const camera = app.getComponent(camera_entity, root.Camera).?;

        var mesh_query = app.query(.{root.Mesh(.{})}, .{});

        while (mesh_query.next()) |mesh_entity| {
            const mesh = app.getComponent(mesh_entity, root.Mesh(.{})).?;

            const transform = app.getComponent(mesh_entity, root.Transform) orelse root.Transform.default;
            const material = app.getComponent(mesh_entity, root.DefaultMaterial) orelse default_material;
            const texture = app.getComponent(mesh_entity, root.DefaultTexture);

            renderer.render(mesh.render_object, material, camera, transform, texture);
        }
    }

    renderer.swap();
}

pub const plugin = root.Plugin{
    .initSystems = &.{
        initWindowSystem,
        initCameraSystem,
        initDefaultShaderSystem,
        initDefaultMaterialSystem,
    },
    .deinitSystems = &.{deinitSystem},
    .systems = &.{system},
};
