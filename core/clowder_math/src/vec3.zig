const std = @import("std");

pub const Vec3f = @Vector(3, f32);
pub const Vec3u = @Vector(3, u32);
pub const Vec3i = @Vector(3, i32);

fn checkVec(vec: anytype) void {
    const T = @TypeOf(vec);

    switch (@typeInfo(T)) {
        .Vector => |typeInfo| {
            if (typeInfo.len != 3) {
                @compileError("Expected length 3, found " ++ typeInfo.len);
            }
        },
        else => @compileError("Expected vector, found '" ++ @typeName(T) ++ "'"),
    }
}

fn checkVecs(vecs: anytype) void {
    const T = @TypeOf(vecs);

    if (@typeInfo(T) != .Struct) {
        @compileError("Expected tuple, found '" ++ @typeName(T) ++ "'");
    }

    inline for (vecs) |vec| {
        if (@TypeOf(vec) != @TypeOf(vecs[0])) {
            @compileError("All vectors must be the same type");
        }

        checkVec(vec);
    }
}

fn ChildType(comptime Vec: type) type {
    return @typeInfo(Vec).Vector.child;
}

fn toFloat(vec: anytype) Vec3f {
    if (ChildType(@TypeOf(vec)) == .Int) {
        return @floatFromInt(vec);
    } else {
        return vec;
    }
}

pub fn div(fst: anytype, sec: anytype) @TypeOf(fst) {
    checkVecs(.{ fst, sec });
    return fst / sec;
}

pub fn len(vec: anytype) f32 {
    checkVec(vec);
    return @sqrt(@reduce(.Add, toFloat(vec * vec)));
}

test "Vec3 len" {
    const vec = Vec3i{ 10, 25, 36 };
    std.testing.expectEqual(len(vec), 44.96);
}

pub fn norm(vec: anytype) @TypeOf(vec) {
    checkVec(vec);

    const T = @TypeOf(vec);
    const vec_len = len(vec);

    if (vec_len > 0) {
        return div(vec, @as(T, @splat(vec_len)));
    }

    return @splat(0);
}

pub fn dot(fst: anytype, sec: anytype) ChildType(@TypeOf(fst)) {
    checkVecs(.{ fst, sec });
    return @reduce(.Add, fst * sec);
}

pub fn cross(fst: anytype, sec: anytype) @TypeOf(fst) {
    checkVecs(.{ fst, sec });

    return .{
        fst[1] * sec[2] - fst[2] * sec[1],
        fst[2] * sec[0] - fst[0] * sec[2],
        fst[0] * sec[1] - fst[1] * sec[0],
    };
}
