const std = @import("std");

const root = @import("../root.zig");

pub const DefaultShader = struct { root.DefaultShader };
pub const DefaultRenderMaterial = struct { root.DefaultRenderMaterial };

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
        \\    color = texture(uTexture, fUvCoords) * fColor * uColor;
        \\}
    ;

    const shader_entity = app.spawn();

    var shader_report = std.ArrayList(u8).init(app.allocator);
    defer shader_report.deinit();

    const shader = root.DefaultShader.fromSources(
        vertex_shader_source,
        fragment_shader_source,
        &shader_report,
    ) catch |err| {
        std.log.err("{s}", .{shader_report.items});
        return err;
    };

    try app.addComponent(shader_entity, DefaultShader{shader});
}

pub fn initDefaultMaterialSystem(app: *root.App) !void {
    const default_shader_entity = app.getFirst(.{DefaultShader}, .{}).?;
    const default_shader = app.getComponent(default_shader_entity, DefaultShader).?[0];

    const material_entity = app.spawn();

    const material = root.DefaultRenderMaterial.init(default_shader, null, null);
    try app.addComponent(material_entity, DefaultRenderMaterial{material});
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

        var tilemap_query = app.query(.{root.Tilemap(.{})}, .{});

        while (tilemap_query.next()) |tilemap_entity| {
            const tilemap = app.getComponent(tilemap_entity, root.Tilemap(.{})).?;
            tilemap.deinit();
        }
    }
}

fn transformFromEntity(app: *root.App, entity: root.Entity) root.Transform {
    var maybe_current_entity: ?root.Entity = entity;
    var result = root.Transform.default;

    while (maybe_current_entity) |current_entity| {
        const transform = app.getComponent(entity, root.Transform) orelse root.Transform.default;
        result = root.Transform.combine(result, transform);

        maybe_current_entity = app.getParent(current_entity);
    }

    return result;
}

pub fn renderSystem(app: *root.App) !void {
    const window_entity = app.getFirst(.{ root.DefaultWindow, root.Renderer(.{}) }, .{}).?;

    const window = app.getComponentPtr(window_entity, root.DefaultWindow).?;
    const renderer = app.getComponent(window_entity, root.Renderer(.{})).?;

    const default_render_material_entity = app.getFirst(.{DefaultRenderMaterial}, .{}).?;
    const default_render_material = app.getComponent(default_render_material_entity, DefaultRenderMaterial).?[0];

    try window.update();

    if (window.shouldClose()) {
        app.exit();
    }

    renderer.clear(root.Color.rgb(0.1, 0.1, 0.1));

    var camera_query = app.query(.{root.Camera}, .{});

    while (camera_query.next()) |camera_entity| {
        const camera = app.getComponent(camera_entity, root.Camera).?;

        { // Tilemaps
            var tilemap_query = app.query(.{root.Tilemap(.{})}, .{});

            while (tilemap_query.next()) |tilemap_entity| {
                const tilemap = app.getComponent(tilemap_entity, root.Tilemap(.{})).?;

                const total_tilemap_size = tilemap.tile_size * @as(root.Vec2f, @floatFromInt(tilemap.size));
                const tilemap_transform = transformFromEntity(app, tilemap_entity);

                const render_material = blk: {
                    const material = app.getComponent(tilemap_entity, root.DefaultMaterial) orelse {
                        break :blk default_render_material;
                    };

                    const shader = material.shader orelse default_render_material.shader;

                    break :blk root.DefaultRenderMaterial{
                        .shader = shader,
                        .color = material.color,
                        .texture = material.texture,
                    };
                };

                for (tilemap.tiles.items, 0..tilemap.tiles.items.len) |maybe_sprite, i| {
                    const sprite = maybe_sprite orelse continue;

                    const pos = root.Vec2f{
                        @floatFromInt(@mod(i, tilemap.size[0])),
                        @floatFromInt(@divFloor(i, tilemap.size[0])),
                    };

                    const tile_position = root.Vec2f{ tilemap_transform.position[0], tilemap_transform.position[1] } +
                        pos * tilemap.tile_size -
                        total_tilemap_size / @as(root.Vec2f, @splat(2));

                    const tile_transform = root.Transform.init(
                        .{ tile_position[0], tile_position[1], 0 },
                        tilemap_transform.scale,
                        tilemap_transform.rotation,
                    );

                    renderer.render(sprite.rectangle.mesh.render_object, render_material, camera, tile_transform);
                }
            }
        }

        { // Meshes
            var mesh_query = app.query(.{root.Mesh(.{})}, .{});

            while (mesh_query.next()) |mesh_entity| {
                const mesh = app.getComponent(mesh_entity, root.Mesh(.{})).?;

                const transform = transformFromEntity(app, mesh_entity);

                const render_material = blk: {
                    const material = app.getComponent(mesh_entity, root.DefaultMaterial) orelse {
                        break :blk default_render_material;
                    };

                    const shader = material.shader orelse default_render_material.shader;

                    break :blk root.DefaultRenderMaterial{
                        .shader = shader,
                        .color = material.color,
                        .texture = material.texture,
                    };
                };

                renderer.render(mesh.render_object, render_material, camera, transform);
            }
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
    .systems = &.{renderSystem},
};
