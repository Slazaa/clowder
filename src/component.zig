const root = @import("root.zig");

pub const BaseMaterial = @import("component/material.zig").Material;
pub const BaseMesh = @import("component/mesh.zig").Mesh;

pub const Material = BaseMaterial(root.default_render_backend);
pub const Mesh = BaseMesh(.{});
