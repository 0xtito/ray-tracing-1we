const std = @import("std");
const print = std.debug.print;

const V = @import("vec3.zig");
const Vec3 = V.Vec3;
const Color = V.Color;

pub fn main() !void {

    // Image
    const image_width = 256;
    const image_height = 256;

    // Render
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Progress Indicator
    const stderr_file = std.io.getStdErr().writer();
    var bw_err = std.io.bufferedWriter(stderr_file);
    const stderr = bw_err.writer();

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    var progress: u16 = 0;
    for (0..image_height) |j| {
        progress = image_height - @as(u16, @intCast(j));
        try stderr.print("\rScanlines remaining: {d}", .{progress});
        try bw_err.flush();
        for (0..image_width) |i| {
            const r: f64 = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(image_width - 1));
            const g: f64 = @as(f64, @floatFromInt(j)) / @as(f64, @floatFromInt(image_height - 1));
            const b: f64 = 0.0;

            var pixel_color: Color = Color.init(r, g, b);

            try V.writeColor(&stdout, &pixel_color);
        }
    }

    try stderr.print("\nDone.\n", .{});

    try bw.flush();
    try bw_err.flush();
}
