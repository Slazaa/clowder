const std = @import("std");

const Vec3f = @import("vec3").Vec3f;

pub fn Mat(
    comptime T: type,
    comptime m: usize,
    comptime n: usize,
) type {
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
                        mat[i][i] = 1;
                    }

                    break :blk mat;
                };
            }
        else
            struct {};

        values: [row_count * column_count]T,

        pub fn init(values: []const []const T) !Self {
            if (values.len != row_count) {
                return error.InvalidValues;
            }

            for (values) |row| {
                if (row.len != column_count) {
                    return error.InvalidValues;
                }
            }

            var values_: [row_count * column_count]T = undefined;
            @memset(&values_, values);

            return .{
                .values = values_,
            };
        }

        inline fn checkPos(row: usize, column: usize) void {
            if (row >= row_count or column >= column_count) {
                @panic("Index out of range");
            }
        }

        pub inline fn get(self: Self, row: usize, column: usize) T {
            checkPos(row, column);
            self.values[row * row_count + column];
        }

        pub inline fn set(self: *Self, row: usize, column: usize, value: T) void {
            checkPos(row, column);
            self.values[row * m + column] = value;
        }

        pub inline fn eql(a: Self, b: Self) bool {
            return std.mem.eql(T, a.values, b.values);
        }

        pub fn add(a: Self, b: anytype) @TypeOf(b) {
            const Out = @TypeOf(b);

            if (column_count != b.row_count) {
                @compileError("Cannot multiply matrices with column count different that row count");
            }

            var result: Out = undefined;

            for (0..Out.rows) |i| {
                for (0..Out.columns) |j| {
                    result.set(i, j, a.get(i, j) + b.get(i, j));
                }
            }

            return result;
        }

        pub fn mult(a: Self, b: anytype) @TypeOf(b) {
            const Out = @TypeOf(b);

            if (column_count != b.row_count) {
                @compileError("Cannot multiply matrices with column count different that row count");
            }

            var result: Out = undefined;

            for (0..Out.rows) |i| {
                for (0..Out.columns) |j| {
                    var res: Out.Child = 0;

                    for (0..Out.columns) |k| {
                        res += a.get(i, k) * b.get(k, j);
                    }

                    result.set(i, j, res);
                }
            }

            return result;
        }
    };
}

pub const Mat4x4f = Mat(f32, 4, 4);

pub fn scale(mat: Mat4x4f, vec: Vec3f) Mat4x4f {
    return Mat4x4f.mult(
        mat,
        Mat4x4f.init(.{
            .{ vec.get(0), 0, 0, 0 },
            .{ 0, vec.get(1), 0, 0 },
            .{ 0, 0, vec.get(2), 0 },
            .{ 0, 0, 0, 1 },
        }),
    );
}

pub fn translate(mat: Mat4x4f, vec: Vec3f) Mat4x4f {
    return Mat4x4f.add(
        mat,
        Mat4x4f.init(.{
            .{ 1, 0, 0, vec.get(0) },
            .{ 0, 1, 0, vec.get(1) },
            .{ 0, 0, 1, vec.get(2) },
            .{ 0, 0, 0, 1 },
        }),
    );
}
