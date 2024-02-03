const math = @import("clowder_math");

const root = @import("root.zig");

const Self = @This();

viewport: root.Viewport,
projection: math.Mat4x4f,
