const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const sanitize_c_type = @typeInfo(@FieldType(std.Build.Module.CreateOptions, "sanitize_c")).optional.child;
    const sanitize_c = b.option(sanitize_c_type, "sanitize-c", "Detect undefined behavior in C");
    const harfbuzz_enabled = b.option(bool, "enable-harfbuzz", "Use HarfBuzz to improve text shaping") orelse true;

    const upstream = b.dependency("SDL_ttf", .{});

    const preferred_linkage = b.option(
        std.builtin.LinkMode,
        "preferred_linkage",
        "Prefer building statically or dynamically linked libraries (default: static)",
    ) orelse .static;

    const lib = b.addLibrary(.{
        .name = "SDL3_ttf",
        .version = .{ .major = 3, .minor = 2, .patch = 2 },
        .linkage = preferred_linkage,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
            .sanitize_c = sanitize_c,
        }),
    });
    lib.addIncludePath(upstream.path("include"));
    lib.addIncludePath(upstream.path("src"));
    lib.addCSourceFiles(.{
        .root = upstream.path("src"),
        .files = srcs,
    });

    if (harfbuzz_enabled) {
        const harfbuzz_dep = b.dependency("harfbuzz", .{
            .target = target,
            .optimize = optimize,
        });
        lib.linkLibrary(harfbuzz_dep.artifact("harfbuzz"));
        lib.root_module.addCMacro("TTF_USE_HARFBUZZ", "1");
    }

    const freetype_dep = b.dependency("freetype", .{
        .target = target,
        .optimize = optimize,
    });
    lib.linkLibrary(freetype_dep.artifact("freetype"));

    const sdl = b.dependency("SDL", .{
        .target = target,
        .optimize = optimize,
        .preferred_linkage = preferred_linkage,
    }).artifact("SDL3");
    lib.linkLibrary(sdl);

    lib.installHeadersDirectory(upstream.path("include"), "", .{});

    b.installArtifact(lib);
}

const srcs: []const []const u8 = &.{
    "SDL_gpu_textengine.c",
    "SDL_hashtable.c",
    "SDL_hashtable_ttf.c",
    "SDL_renderer_textengine.c",
    "SDL_surface_textengine.c",
    "SDL_ttf.c",
};
