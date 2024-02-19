const std = @import("std");

const Registry = @import("Registry.zig");
const Entity = Registry.Entity;

const Storage = @import("storage.zig").Storage;

pub fn Query(comptime includes: anytype, comptime excludes: anytype) type {
    {
        const IncludesType = @TypeOf(includes);

        if (@typeInfo(IncludesType) != .Struct) {
            @compileError("Expected tuple for includes, found '" ++ @typeName(IncludesType) ++ "'");
        }

        const ExcludesType = @TypeOf(excludes);

        if (@typeInfo(ExcludesType) != .Struct) {
            @compileError("Expected tuple for excludes, found '" ++ @typeName(ExcludesType) ++ "'");
        }
    }

    for (includes) |include| {
        const Include = @TypeOf(include);

        if (@typeInfo(Include) != .Type) {
            @compileError("Expected type, found '" ++ @typeName(Include) ++ "'");
        }
    }

    for (excludes) |exclude| {
        const Exclude = @TypeOf(exclude);

        if (@typeInfo(Exclude) != .Type) {
            @compileError("Excpeted type, found '" ++ @typeName(Exclude) ++ "'");
        }
    }

    for (includes) |include| {
        for (excludes) |exclude| {
            if (include == exclude) {
                @compileError("'" ++ @typeName(include) ++ "' found both in includes and exculdes");
            }
        }
    }

    return struct {
        const Self = @This();

        fn PredicateLists(length: usize) type {
            if (length != 0) {
                return struct {
                    entity_lists: [length - 1][]const Entity,
                    base_entity_list: []const Entity,
                };
            } else {
                return struct {};
            }
        }

        const IncludesLists = PredicateLists(includes.len);
        const ExcludesLists = PredicateLists(excludes.len);

        registry: Registry,

        includes_lists: IncludesLists,
        excludes_lists: ExcludesLists,

        index: usize = 0,

        pub fn init(registry: Registry) Self {
            var includes_lists: IncludesLists = undefined;

            inline for (includes, 0..) |Include, i| {
                const entity_list: []const Entity = if (registry.getStorage(Include)) |storage|
                    storage.entities.items
                else |_|
                    &.{};

                if (i == 0) {
                    includes_lists.base_entity_list = entity_list;
                } else if (entity_list.len < includes_lists.base_entity_list.len) {
                    includes_lists.entity_lists[i - 1] = includes_lists.base_entity_list;
                    includes_lists.base_entity_list = entity_list;
                } else {
                    includes_lists.entity_lists[i - 1] = entity_list;
                }
            }

            var excludes_lists: ExcludesLists = undefined;

            inline for (excludes, 1..) |Exclude, i| {
                const entity_list: []const Entity = if (registry.getStorage(Exclude)) |storage|
                    storage.entities.items
                else |_|
                    &.{};

                if (entity_list.len < excludes_lists.base_entity_list.len) {
                    excludes_lists.entity_lists[i - 1] = excludes_lists.base_entity_list;
                    excludes_lists.base_entity_list = entity_list;
                } else {
                    excludes_lists.entity_lists[i - 1] = entity_list;
                }
            }

            return .{
                .registry = registry,

                .includes_lists = includes_lists,
                .excludes_lists = excludes_lists,
            };
        }

        /// Returns the next `Entity` in the `Query`.
        /// TODO: Excludes not implemented yet.
        pub fn next(self: *Self) ?Entity {
            if (self.includes_lists.base_entity_list.len == 0 or
                self.index >= self.includes_lists.base_entity_list.len)
            {
                return null;
            }

            const entity = self.includes_lists.base_entity_list[self.index];

            const incl_valid = for (self.includes_lists.entity_lists) |entity_list| {
                if (!std.mem.containsAtLeast(Entity, entity_list, 1, &.{entity})) {
                    break false;
                }
            } else true;

            self.index += 1;

            if (incl_valid) {
                return entity;
            }

            return self.next();
        }
    };
}
