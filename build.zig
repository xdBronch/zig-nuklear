const std = @import("std");

const Build = std.Build;
const CrossTarget = std.build.CrossTarget;
const Compile = Build.Step.Compile;

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const nk = Nuklear.init(b, .{
        .include_default_font = true,
        .include_font_backing = true,
        .include_vertex_buffer_output = true,
        .zero_command_memory = true,
        .keystate_based_input = true,
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run library tests");
    const tests = b.addTest(.{
        .name = "nuklear.zig",
        .root_source_file = .{ .path = "examples/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    test_step.dependOn(&tests.step);
    nk.addTo(tests, .{});

    const examples = b.addExecutable(.{
        .name = "examples",
        .root_source_file = .{ .path = "examples/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    examples.strip = b.option(bool, "strip", "strip the example binary");
    nk.addTo(examples, .{});

    examples.linkLibC();
    examples.linkSystemLibrary("GL");
    examples.linkSystemLibrary("glfw");
    examples.linkSystemLibrary("GLU");
    b.installArtifact(examples);
}

const Nuklear = @This();

options: Options,
lib: *Compile,

pub const Options = struct {
    include_fixed_types: bool = false,
    include_default_allocator: bool = false,
    include_stdio: bool = false,
    include_std_varargs: bool = false,
    include_vertex_buffer_output: bool = false,
    include_font_backing: bool = false,
    include_default_font: bool = false,
    include_command_userdata: bool = false,
    button_trigger_on_release: bool = false,
    zero_command_memory: bool = false,
    uint_draw_index: bool = false,
    keystate_based_input: bool = false,
    buffer_default_initial_size: ?usize = null,
    max_number_buffer: ?usize = null,
    input_max: ?usize = null,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,

    fn defineMacros(opts: Options, lib: *Compile) void {
        const b = lib.step.owner;
        if (opts.include_fixed_types)
            lib.defineCMacro("NK_INCLUDE_FIXED_TYPES", null);
        if (opts.include_default_allocator)
            lib.defineCMacro("NK_INCLUDE_DEFAULT_ALLOCATOR", null);
        if (opts.include_stdio)
            lib.defineCMacro("NK_INCLUDE_STANDARD_IO", null);
        if (opts.include_std_varargs)
            lib.defineCMacro("NK_INCLUDE_STANDARD_VARARGS", null);
        if (opts.include_vertex_buffer_output)
            lib.defineCMacro("NK_INCLUDE_VERTEX_BUFFER_OUTPUT", null);
        if (opts.include_font_backing)
            lib.defineCMacro("NK_INCLUDE_FONT_BAKING", null);
        if (opts.include_default_font)
            lib.defineCMacro("NK_INCLUDE_DEFAULT_FONT", null);
        if (opts.include_command_userdata)
            lib.defineCMacro("NK_INCLUDE_COMMAND_USERDATA", null);
        if (opts.button_trigger_on_release)
            lib.defineCMacro("NK_BUTTON_TRIGGER_ON_RELEASE", null);
        if (opts.zero_command_memory)
            lib.defineCMacro("NK_ZERO_COMMAND_MEMORY", null);
        if (opts.uint_draw_index)
            lib.defineCMacro("NK_UINT_DRAW_INDEX", null);
        if (opts.keystate_based_input)
            lib.defineCMacro("NK_KEYSTATE_BASED_INPUT", null);
        if (opts.buffer_default_initial_size) |size|
            lib.defineCMacro("NK_BUFFER_DEFAULT_INITIAL_SIZE", b.fmt("{}", .{size}));
        if (opts.max_number_buffer) |number|
            lib.defineCMacro("NK_MAX_NUMBER_BUFFER", b.fmt("{}", .{number}));
        if (opts.input_max) |number|
            lib.defineCMacro("NK_INPUT_MAX", b.fmt("{}", .{number}));
    }
};

pub fn init(b: *Build, opts: Options) Nuklear {
    const lib = b.addStaticLibrary(.{
        .name = "zig-nuklear",
        .target = opts.target,
        .optimize = opts.optimize,
    });
    lib.addCSourceFile(.{
        .file = .{ .path = b.pathJoin(&.{ dir(), "src/c/nuklear.c" }) },
        .flags = &.{},
    });
    opts.defineMacros(lib);
    return .{ .lib = lib, .options = opts };
}

pub const AddToOptions = struct {
    package_name: []const u8 = "nuklear",
};

pub fn addTo(nk: Nuklear, lib: *Compile, opt: AddToOptions) void {
    lib.addIncludePath(.{ .path = include_dir });
    lib.addAnonymousModule(opt.package_name, .{ .source_file = .{ .path = pkg_path } });
    lib.linkLibrary(nk.lib);
    nk.options.defineMacros(lib);
    lib.step.dependOn(&nk.lib.step);
}

pub const pkg_path = dir() ++ "/nuklear.zig";

pub const include_dir = dir() ++ "/src/c";

fn dir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
