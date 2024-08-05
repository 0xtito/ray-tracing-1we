const std = @import("std");
const print = std.debug.print;

const V = @import("vec3.zig");
const Vec3 = V.Vec3;
const Color = V.Color;

const R = @import("ray.zig");
const Ray = R.Ray;

pub fn main() !void {
    const aspect_ratio = 16.0 / 9.0;

    // Image
    const image_width = 400;
    const image_width_f = @as(f64, @floatFromInt(image_width));

    // var image_height: f64 = image_width / aspect_ratio;
    var image_height_f: f64 = image_width_f / aspect_ratio;
    var image_height: u32 = @intFromFloat(image_height_f);

    image_height = if (image_height < 1) 1 else image_height;
    image_height_f = @as(f64, @floatFromInt(image_height));

    // Camera
    const focal_length: f64 = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (image_width_f / image_height_f);
    const camera_center = Vec3.zero();

    // Calculating the vectors across the horizontal and down the verical viewport edges
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    // Calculating the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.div(image_width_f);
    const pixel_delta_v = viewport_v.div(image_height_f);

    const eye_to_viewport = Vec3.init(0, 0, focal_length);

    // Calculate the location of the upper left pixel
    const viewport_upper_left = camera_center.sub(&eye_to_viewport).sub(&viewport_u.mul(0.5)).sub(&viewport_v.mul(0.5));
    var pixel_00_location = V.add(&pixel_delta_u, &pixel_delta_v);
    pixel_00_location = pixel_00_location.mul(0.5).add(&viewport_upper_left);

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
    for (0..@intFromFloat(image_height_f)) |j| {
        const x: f64 = @as(f64, @floatFromInt(j));
        progress = @as(u16, @intFromFloat(image_height_f)) - @as(u16, @intCast(j));
        try stderr.print("\rScanlines remaining: {d}", .{progress});
        try bw_err.flush();
        for (0..image_width) |i| {
            const y: f64 = @as(f64, @floatFromInt(i));
            const delta_u = pixel_delta_u.mul(y);
            const delta_v = pixel_delta_v.mul(x);
            const pixel_center = pixel_00_location.add(&delta_u).add(&delta_v);
            const ray_dir = V.sub(&pixel_center, &camera_center);

            const ray = Ray.init(&camera_center, &ray_dir);

            const pixel_color = V.rayColor(&ray);

            try V.writeColor(&stdout, &pixel_color);
        }
    }

    try stderr.print("\nDone.\n", .{});

    try bw.flush();
    try bw_err.flush();
}
