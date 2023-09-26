const std = @import("std");
const c = @import("c.zig");

pub fn main() !void {
    std.log.info("Works..?", .{});
    _ = c;

    var w: c_int = undefined;
    var h: c_int = undefined;
    var channels: c_int = undefined;
    var buffer = c.stbi_load("test.png", &w, &h, &channels, 4);
    defer c.stbi_image_free(buffer);

    var color = buffer[0];

    std.log.info("w: {}, h: {}, channels: {}, color {}", .{ w, h, channels, color });
}
