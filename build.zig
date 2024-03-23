const std = @import("std");

const Build = std.Build;
const Module = Build.Module;

pub fn build(b: *Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    var opts: Options = .{};
    inline for (@typeInfo(Options).Struct.fields) |field| {
        @field(opts, field.name) = switch (@typeInfo(field.type)) {
            .Optional => b.option(@typeInfo(field.type).Optional.child, field.name, ""),
            else => b.option(field.type, field.name, "") orelse
                @as(*const field.type, @ptrCast(@alignCast(field.default_value))).*,
        };
    }

    const mod = b.addModule("zig-nuklear", .{
        .root_source_file = .{ .path = "nuklear.zig" },
        .target = target,
        .optimize = optimize,
    });
    mod.addIncludePath(.{ .path = "src/c" });
    mod.addCSourceFile(.{
        .file = .{ .path = "src/c/nuklear.c" },
        .flags = &.{},
    });

    const test_step = b.step("test", "Run library tests");
    const tests = b.addTest(.{
        .name = "nuklear.zig",
        .root_source_file = .{ .path = "examples/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    test_step.dependOn(&tests.step);
    tests.root_module.addImport("nuklear", mod);

    if (b.option(bool, "example", "build example") == true) {
        opts = .{
            .include_default_font = true,
            .include_font_backing = true,
            .include_vertex_buffer_output = true,
            .zero_command_memory = true,
            .keystate_based_input = true,
        };
        const examples = b.addExecutable(.{
            .name = "examples",
            .root_source_file = .{ .path = "examples/main.zig" },
            .target = target,
            .optimize = optimize,
        });
        examples.root_module.addImport("nuklear", mod);
        examples.linkLibC();
        examples.linkSystemLibrary("GL");
        examples.linkSystemLibrary("glfw");
        examples.linkSystemLibrary("GLU");
        b.installArtifact(examples);
    }

    opts.defineMacros(mod);
}

const Nuklear = @This();

options: Options,
mod: *Module,

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

    fn defineMacros(opts: Options, mod: *Module) void {
        const b = mod.owner;
        if (opts.include_fixed_types)
            mod.addCMacro("NK_INCLUDE_FIXED_TYPES", "1");
        if (opts.include_default_allocator)
            mod.addCMacro("NK_INCLUDE_DEFAULT_ALLOCATOR", "1");
        if (opts.include_stdio)
            mod.addCMacro("NK_INCLUDE_STANDARD_IO", "1");
        if (opts.include_std_varargs)
            mod.addCMacro("NK_INCLUDE_STANDARD_VARARGS", "1");
        if (opts.include_vertex_buffer_output)
            mod.addCMacro("NK_INCLUDE_VERTEX_BUFFER_OUTPUT", "1");
        if (opts.include_font_backing)
            mod.addCMacro("NK_INCLUDE_FONT_BAKING", "1");
        if (opts.include_default_font)
            mod.addCMacro("NK_INCLUDE_DEFAULT_FONT", "1");
        if (opts.include_command_userdata)
            mod.addCMacro("NK_INCLUDE_COMMAND_USERDATA", "1");
        if (opts.button_trigger_on_release)
            mod.addCMacro("NK_BUTTON_TRIGGER_ON_RELEASE", "1");
        if (opts.zero_command_memory)
            mod.addCMacro("NK_ZERO_COMMAND_MEMORY", "1");
        if (opts.uint_draw_index)
            mod.addCMacro("NK_UINT_DRAW_INDEX", "1");
        if (opts.keystate_based_input)
            mod.addCMacro("NK_KEYSTATE_BASED_INPUT", "1");
        if (opts.buffer_default_initial_size) |size|
            mod.addCMacro("NK_BUFFER_DEFAULT_INITIAL_SIZE", b.fmt("{}", .{size}));
        if (opts.max_number_buffer) |number|
            mod.addCMacro("NK_MAX_NUMBER_BUFFER", b.fmt("{}", .{number}));
        if (opts.input_max) |number|
            mod.addCMacro("NK_INPUT_MAX", b.fmt("{}", .{number}));
    }
};
