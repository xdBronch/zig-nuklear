# zig-nuklear

WIP bindings for [Nuklear](https://github.com/Immediate-Mode-UI/Nuklear).

## Goals

* Provide an API simular to Nuklear, but with improvements thrown in where it makes
  sense.
* Support using Nuklear with or without libc.
  * Provide default implementations for overridable Nuklear function in Zig if libc is
    unwanted.

## Usage

This is an example with no backend. See [`examples/main.zig`](examples/main.zig) for a full example
using `glfw` and `opengl`.

`zig fetch --save https://github.com/xdBronch/zig-nuklear/archive/<COMMIT-HASH>.tar.gz`
```zig
// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const nk = b.dependency("zig-nuklear", .{
        // config options here
    });

    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addImport("nuklear", nk.module("zig-nuklear"));

    // Link to your backend here!

    b.installArtifact(exe);
}
```

```zig
// main.zig
const nk = @import("nuklear");
const std = @import("std");

pub fn main() !void {
    const allocator = // Choose your allocator!
    const font = // Initialize your font!
    var ctx = nk.init(&allocator, font);
    defer nk.free(&ctx);

    while (
        // Backend is running
    ) {
        nk.input.begin(&ctx);

        // Forward events from backend to Nuklear here!

        nk.input.end(&ctx);

        if (nk.window.begin(&ctx, &nk.id(opaque {}), nk.rect(0, 0, 200, 200), .{
            .title = "hello world",
            .border = true,
            .moveable = true,
            .closable = true,
            .minimizable = true,
            .background = false,
            .scalable = true,
        })) |_| {
            nk.layout.rowDynamic(&ctx, 0, 1);
            nk.text.label(&ctx, "Hello world!", .mid_right);
            if (nk.button.label(&ctx, "Hello world!"))
                std.log.info("Hello world!", .{});
        }
        nk.window.end(&ctx);

        // Render gui out to your backend here!

        nk.clear(&ctx);
    }
}
```

