const std = @import("std");
const c = @import("c.zig");

pub fn main() !void {
    const texturePath = "painting.png";

    std.log.info("Loading texture using stb_image..", .{});

    var w: c_int = undefined;
    var h: c_int = undefined;
    var channels: c_int = undefined;

    // This is where we call C code!
    var buffer = c.stbi_load(texturePath, &w, &h, &channels, 0);
    defer c.stbi_image_free(buffer);

    std.log.info("Loaded texture {s}: width: {}, height: {}, channels: {}", .{ texturePath, w, h, channels });

    // Paint the image in terminal:

    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("\n\n", .{});

    for (0..@intCast(h)) |y| {
        if (y % 2 == 1)
            continue;
        for (0..@intCast(w)) |x| {
            //if (x % 2 == 1)
            //continue;

            const i = (y * asU(w) + x) * asU(channels);
            const r: u8 = buffer[i];
            const g: u8 = buffer[i + 1];
            const b: u8 = buffer[i + 2];
            const outCol = closestColor(Color{ r, g, b });
            try stdout.print("{s}#", .{outCol.code});
        }
        try stdout.print("\n", .{});
    }

    try bw.flush();
}

// Color painting functions

const Color = @Vector(3, u8);

const ColorPair = struct {
    vec: Color,
    code: []const u8,
};

const black = ColorPair{ .vec = .{ 0, 0, 0 }, .code = "\x1b[30m" };
const red = ColorPair{ .vec = .{ 1, 0, 0 }, .code = "\x1b[31m" };
const green = ColorPair{ .vec = .{ 0, 1, 0 }, .code = "\x1b[32m" };
const yellow = ColorPair{ .vec = .{ 1, 1, 0 }, .code = "\x1b[33m" };
const blue = ColorPair{ .vec = .{ 0, 0, 1 }, .code = "\x1b[34m" };
const magenta = ColorPair{ .vec = .{ 1, 0, 1 }, .code = "\x1b[35m" };
const cyan = ColorPair{ .vec = .{ 0, 1, 1 }, .code = "\x1b[36m" };
const white = ColorPair{ .vec = .{ 1, 1, 1 }, .code = "\x1b[37m" };

const colors = [_]ColorPair{ black, red, green, yellow, blue, magenta, cyan, white };

fn to255(cpair: ColorPair) ColorPair {
    return .{ .code = cpair.code, .vec = cpair.vec * @as(Color, @splat(255)) };
}

fn toF(color: Color) @Vector(3, f32) {
    return @as(@Vector(3, f32), @floatFromInt(color));
}

fn asU(i: anytype) usize {
    return @as(usize, @intCast(i));
}

fn closestColor(inColor: Color) ColorPair {
    var closestDistance = std.math.inf(f32);
    var closest: ColorPair = undefined;

    for (colors) |color| {
        const tableCol = toF(to255(color).vec);
        const inCol = toF(inColor);
        const diff = tableCol - inCol;
        const d = @sqrt(diff[0] * diff[0] + diff[1] * diff[1]);
        if (d < closestDistance) {
            closestDistance = d;
            closest = color;
        }
    }

    return closest;
}
