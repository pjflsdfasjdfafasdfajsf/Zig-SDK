const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{ .default_target = .{ .os_tag = .freestanding, .cpu_arch = .wasm32 } });
    const optimize = b.standardOptimizeOption(.{});

    const sdk_path = b.path("src/main.zig");

    _ = b.addModule("sdk", .{
        .root_source_file = sdk_path,
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "mod",
        .root_module = b.createModule(.{
            .root_source_file = sdk_path,
            .target = target,
            .optimize = optimize,
            .imports = &.{},
            .pic = true,
        }),
    });
    exe.entry = .{ .symbol_name = "guest_initialize" }; // make sure guest_initialize is compiled
    exe.rdynamic = true;

    b.installArtifact(exe);
}
