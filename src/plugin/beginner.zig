const std = @import("std");

const root = @import("../root.zig");

pub const Shader = struct { root.Shader };
pub const RenderMaterial = struct { root.RenderMaterial };

pub const Fps = struct { f32 };

pub const Delta = struct {
    value: f32,
    now: u64 = 0,
};

pub fn initWindowSystem(app: *root.App) !void {
    const main_window = app.spawn();

    var window = try root.Window.init(
        app.allocator,
        "Clowder Window",
        .center,
        .{ 800, 600 },
        .{},
    );

    errdefer window.deinit();

    const renderer = try root.Renderer.init(window.context());
    errdefer renderer.deinit();

    try app.addComponent(main_window, window);
    try app.addComponent(main_window, renderer);
}

pub fn initCameraSystem(app: *root.App) !void {
    const window_entity = app.getFirst(.{ root.Window, root.Renderer }, .{}).?;
    const window = app.getComponent(window_entity, root.Window).?;

    const camera = app.spawn();

    try app.addBundle(camera, root.bundle.OrthographicCamera.init(window.getSize()));

    try app.addComponent(camera, root.Transform.init(.{ 0, 0, 0 }, .{ 1, 1, 1 }, .{ 0, 0, 0 }));
}

pub fn initDefaultShaderSystem(app: *root.App) !void {
    const vertex_shader_source =
        \\#version 450 core
        \\
        \\layout(location = 0) in vec3 aPosition;
        \\layout(location = 1) in vec4 aColor;
        \\layout(location = 2) in vec2 aUvCoords;
        \\
        \\out vec4 fColor;
        \\out vec2 fUvCoords;
        \\
        \\uniform mat4 uTransform;
        \\
        \\void main() {
        \\    gl_Position = uTransform * vec4(aPosition, 1.0f);
        \\
        \\    fColor = aColor;
        \\    fUvCoords = aUvCoords;
        \\}
    ;

    const fragment_shader_source =
        \\#version 450 core
        \\
        \\in vec4 fColor;
        \\in vec2 fUvCoords;
        \\
        \\out vec4 color;
        \\
        \\uniform vec4 uColor;
        \\uniform sampler2D uTexture;
        \\
        \\void main() {
        \\    vec4 texColor = texture(uTexture, fUvCoords) * fColor * uColor;
        \\
        \\    if (texColor.a < 0.1) {
        \\        discard;
        \\    }
        \\
        \\    color = texColor;
        \\}
    ;

    const shader_entity = app.spawn();

    var shader_report = std.ArrayList(u8).init(app.allocator);
    defer shader_report.deinit();

    const shader = root.Shader.fromSources(
        vertex_shader_source,
        fragment_shader_source,
        &shader_report,
    ) catch |err| {
        std.log.err("{s}", .{shader_report.items});
        return err;
    };

    try app.addComponent(shader_entity, Shader{shader});
}

pub fn initDefaultMaterialSystem(app: *root.App) !void {
    const default_shader_entity = app.getFirst(.{Shader}, .{}).?;
    const default_shader = app.getComponent(default_shader_entity, Shader).?[0];

    const material_entity = app.spawn();

    const material = root.RenderMaterial.init(default_shader, null, null);
    try app.addComponent(material_entity, RenderMaterial{material});
}

pub fn initDeltaSystem(app: *root.App) !void {
    const fps = app.spawn();
    try app.addComponent(fps, Fps{1});

    const delta = app.spawn();
    try app.addComponent(delta, Delta{ .value = 0 });
}

pub fn deinitWindowSystem(app: *root.App) void {
    var query = app.query(.{ root.Window, root.Renderer }, .{});

    while (query.next()) |entity| {
        const window = app.getComponent(entity, root.Window).?;
        const renderer = app.getComponent(entity, root.Renderer).?;

        window.deinit();
        renderer.deinit();
    }
}

pub fn deinitMeshSystem(app: *root.App) void {
    var mesh_query = app.query(.{root.Mesh}, .{});

    while (mesh_query.next()) |mesh_entity| {
        const mesh = app.getComponent(mesh_entity, root.Mesh).?;
        mesh.deinit();
    }
}

fn transformFromEntity(app: *root.App, entity: root.Entity) root.Transform {
    var maybe_current_entity: ?root.Entity = entity;
    var result = root.Transform.default;

    while (maybe_current_entity) |current_entity| {
        const transform = app.getComponent(current_entity, root.Transform) orelse root.Transform.default;
        result = root.Transform.combine(result, transform);

        maybe_current_entity = app.getParent(current_entity);
    }

    return result;
}

pub fn renderSystem(app: *root.App) !void {
    const window_entity = app.getFirst(.{ root.Window, root.Renderer }, .{}).?;

    const window = app.getComponentPtr(window_entity, root.Window).?;
    const renderer = app.getComponent(window_entity, root.Renderer).?;

    const default_render_material_entity = app.getFirst(.{RenderMaterial}, .{}).?;
    const default_render_material = app.getComponent(default_render_material_entity, RenderMaterial).?[0];

    try window.update();

    if (window.shouldClose()) {
        app.exit();
    }

    renderer.clear(root.Color.rgb(0.1, 0.1, 0.1));

    var camera_query = app.query(.{root.Camera}, .{});

    while (camera_query.next()) |camera_entity| {
        const camera = app.getComponent(camera_entity, root.Camera).?;

        const camera_transform = app.getComponent(camera_entity, root.Transform) orelse root.Transform.default;

        var mesh_query = app.query(.{root.Mesh}, .{});

        while (mesh_query.next()) |mesh_entity| {
            const mesh = app.getComponent(mesh_entity, root.Mesh).?;

            const transform = transformFromEntity(app, mesh_entity);

            const render_material = blk: {
                const material = app.getComponent(mesh_entity, root.Material) orelse {
                    break :blk default_render_material;
                };

                const shader = material.shader orelse default_render_material.shader;

                break :blk root.DefaultRenderMaterial{
                    .shader = shader,
                    .color = material.color,
                    .texture = material.texture,
                };
            };

            renderer.render(render_material, camera, camera_transform, mesh.render_object, transform);
        }
    }

    renderer.swap();
}

pub fn deltaSystem(app: *root.App) !void {
    const fps = app.getFirst(.{Fps}, .{}).?;
    const fps_comp = app.getComponent(fps, Fps).?;

    const delta = app.getFirst(.{Delta}, .{}).?;
    const delta_comp = app.getComponentPtr(delta, Delta).?;

    if (delta_comp.now == 0) {
        delta_comp.now = @intCast(std.time.milliTimestamp());
    }

    const last = delta_comp.now;
    delta_comp.now = @intCast(std.time.milliTimestamp());

    delta_comp.value = @floatFromInt(delta_comp.now - last / 1_000);

    const target = 1 / fps_comp[0];

    if (delta_comp.value < target) {
        std.time.sleep(@intFromFloat((target - delta_comp.value) * 1_000_000));
    }
}

pub const plugin = root.Plugin{
    .initSystems = &.{
        initWindowSystem,
        initCameraSystem,
        initDefaultShaderSystem,
        initDefaultMaterialSystem,
        initDeltaSystem,
    },
    .deinitSystems = &.{
        deinitWindowSystem,
        deinitMeshSystem,
    },
    .systems = &.{
        renderSystem,
        deltaSystem,
    },
};
