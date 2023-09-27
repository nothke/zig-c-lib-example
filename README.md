Example of using C code in zig with stbi_image. If you call `zig build run`, it should show you the info about an image and display it as colored ascii characters.

## To summarize..

1. Add C code to your project, in this example stb_image.c and stb_image.h to libs/
2. In your build.zig, link libc, add C source files and add include folder like:
```zig
exe.linkLibC();
exe.addCSourceFile(.{
    .file = .{ .path = "libs/stb_image.c" },
    .flags = &.{},
});

exe.addIncludePath(.{ .path = "libs" });
```
3. Add c.zig which imports your header like:
```zig
pub usingnamespace @cImport({
    @cInclude("stb_image.h");
});
```
4. now in your main, import c.zig:
```zig
const c = @import("c.zig");
```
5. Put `_ = c;` somewhere in your code and `zig build` to see if it builds correctly
6. Now you can use the C library as you wish!