const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("SDL_ttf", .{});

    const lib = b.addLibrary(.{
        .name = "SDL2_ttf",
        .version = .{ .major = 2, .minor = 24, .patch = 0 },
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    lib.addCSourceFile(.{ .file = upstream.path("SDL_ttf.c") });

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(freetype_dep.artifact("freetype"));

    const sdl_dep = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
    });
    const sdl_lib = sdl_dep.artifact("SDL2");
    lib.linkLibrary(sdl_lib);
    lib.addIncludePath(sdl_lib.getEmittedIncludeTree().path(b, "SDL2"));

    lib.installHeader(upstream.path("SDL_ttf.h"), "SDL2/SDL_ttf.h");

    b.installArtifact(lib);
}
