const std = @import("std");

const vec2 = @import("vec2.zig");
const vec3 = @import("vec3.zig");

const Vec2u = vec2.Vec2u;

const Vec3f = vec3.Vec3f;

pub fn Mat(comptime T: type, comptime m: usize, comptime n: usize) type {
    return struct {
        const Self = @This();

        pub const Child = T;

        pub const row_count = m;
        pub const column_count = n;

        pub const zero = std.mem.zeroes(Self);

        pub usingnamespace if (row_count == column_count)
            struct {
                pub const identity = blk: {
                    var mat = Self.zero;

                    for (0..row_count) |i| {
                        mat.set(i, i, 1);
                    }

                    break :blk mat;
                };
            }
        else
            struct {};

        values: [row_count * column_count]T,

        pub fn init(values: []const []const T) Self {
            if (values.len != row_count) {
                @panic("Invalid values");
            }

            for (values) |row| {
                if (row.len != column_count) {
                    @panic("Invalid values");
                }
            }

            var self = Self{
                .values = undefined,
            };

            for (0..row_count * column_count) |i| {
                const pos = Vec2u{
                    @intCast(i % column_count),
                    @intCast(@divFloor(i, column_count)),
                };

                self.set(pos[1], pos[0], values[pos[1]][pos[0]]);
            }

            return self;
        }

        inline fn checkPos(row: usize, column: usize) void {
            if (row >= row_count or column >= column_count) {
                @panic("Index out of range");
            }
        }

        pub inline fn get(self: Self, row: usize, column: usize) T {
            checkPos(row, column);
            return self.values[row * row_count + column];
        }

        pub inline fn set(self: *Self, row: usize, column: usize, value: T) void {
            checkPos(row, column);
            self.values[row * row_count + column] = value;
        }

        pub inline fn eql(a: Self, b: Self) bool {
            return std.mem.eql(T, a.values, b.values);
        }

        pub fn add(a: Self, b: anytype) @TypeOf(b) {
            const Out = @TypeOf(b);

            if (column_count != Out.row_count) {
                @compileError("Cannot add matrices with column count different that row count");
            }

            var result: Out = undefined;

            for (0..Out.row_count) |i| {
                for (0..Out.column_count) |j| {
                    result.set(i, j, a.get(i, j) + b.get(i, j));
                }
            }

            return result;
        }

        pub fn mult(a: Self, b: anytype) @TypeOf(b) {
            const Out = @TypeOf(b);

            if (column_count != Out.row_count) {
                @compileError("Cannot multiply matrices with column count different that row count");
            }

            var result: Out = undefined;

            for (0..Out.row_count) |i| {
                for (0..Out.column_count) |j| {
                    var value: Out.Child = 0;

                    for (0..Out.column_count) |k| {
                        value += a.get(j, k) * b.get(k, i);
                    }

                    result.set(i, j, value);
                }
            }

            return result;
        }

        pub fn format(self: Self, comptime fmt: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            for (0..column_count) |i| {
                try writer.writeAll("| ");

                for (0..row_count) |j| {
                    try writer.print("{" ++ fmt ++ "} ", .{self.get(j, i)});
                }

                try writer.writeAll("|\n");
            }
        }
    };
}

pub const Mat2x2f = Mat(f32, 2, 2);
pub const Mat3x4f = Mat(f32, 3, 3);
pub const Mat4x4f = Mat(f32, 4, 4);

pub fn scaling(mat: Mat4x4f, vec: Vec3f) Mat4x4f {
    return Mat4x4f.mult(
        mat,
        Mat4x4f.init(.{
            .{ vec[0], 0, 0, 0 },
            .{ 0, vec[1], 0, 0 },
            .{ 0, 0, vec[2], 0 },
            .{ 0, 0, 0, 1 },
        }),
    );
}

pub fn translation(mat: Mat4x4f, vec: Vec3f) Mat4x4f {
    return Mat4x4f.add(
        mat,
        Mat4x4f.init(&.{
            &.{ 1, 0, 0, vec[0] },
            &.{ 0, 1, 0, vec[1] },
            &.{ 0, 0, 1, vec[2] },
            &.{ 0, 0, 0, 1 },
        }),
    );
}

pub fn orthographicRhNo(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat4x4f {
    const width = right - left;
    const height = top - bottom;
    const depth = near - far;

    return Mat4x4f.init(&.{
        &.{ 2 / width, 0, 0, 0 },
        &.{ 0, 2 / height, 0, 0 },
        &.{ 0, 0, 2 / depth, (near + far) / depth },
        &.{ 0, 0, 0, 1 },
    });
}

pub fn orthographicRhZo(left: f32, right: f32, top: f32, bottom: f32, near: f32, far: f32) Mat4x4f {
    const width = right - left;
    const height = top - bottom;
    const depth = near - far;

    return Mat4x4f.init(&.{
        &.{ 2 / width, 0, 0, 0 },
        &.{ 0, 2 / height, 0, 0 },
        &.{ 0, 0, 1 / depth, (1 / depth) * near },
        &.{ 0, 0, 0, 1 },
    });
}
