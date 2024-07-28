const std = @import("std");
const math = std.math;

pub const Vec3 = struct {
    e: [3]f64,

    pub fn init(e0: f64, e1: f64, e2: f64) Vec3 {
        return Vec3{ .e = .{ e0, e1, e2 } };
    }

    pub fn zero() Vec3 {
        return Vec3{ .e = .{ 0.0, 0.0, 0.0 } };
    }

    pub fn x(self: *Vec3) f64 {
        return self.e[0];
    }

    pub fn y(self: *Vec3) f64 {
        return self.e[1];
    }
    pub fn z(self: *Vec3) f64 {
        return self.e[2];
    }

    pub inline fn add(self: *Vec3, other: *Vec3) Vec3 {
        self.e[0] += other.e[0];
        self.e[1] += other.e[1];
        self.e[2] += other.e[2];
        return self;
    }

    pub inline fn sub(self: *Vec3, other: *Vec3) Vec3 {
        self.e[0] -= other.e[0];
        self.e[1] -= other.e[1];
        self.e[2] -= other.e[2];
        return self;
    }

    pub inline fn mul(self: *Vec3, t: f64) Vec3 {
        self.e[0] *= t;
        self.e[1] *= t;
        self.e[2] *= t;
        return self;
    }

    pub inline fn div(self: *Vec3, t: f64) Vec3 {
        return self.mul(1 / t);
    }

    pub inline fn len(self: *Vec3) f64 {
        return @sqrt(self.len_sq);
        // return @sqrt(self.e[0] ^ 2 + self.e[1] ^ 2 + self.e[2] ^ 2);
    }

    pub inline fn len_sq(self: *Vec3) f64 {
        return self.e[0] ^ 2 + self.e[1] ^ 2 + self.e[2] ^ 2;
    }

    pub inline fn dot(self: *Vec3, other: *Vec3) f64 {
        return (self.e[0] * other.e[0]) + (self.e[1] * other.e[1]) + (self.e[2] * other.e[2]);
    }

    pub inline fn cross(self: *Vec3, other: *Vec3) Vec3 {
        return Vec3{
            .e = .{
                self.e[1] * other.e[2] - self.e[2] * other.e[1], // x
                self.e[2] * other.e[0] - self.e[0] * other.e[2], // y
                self.e[0] * other.e[1] - self.e[1] * other.e[0], // z
            },
        };
    }

    pub inline fn unitVector(self: *Vec3) Vec3 {
        return self.div(self.len());
    }
};

pub const Color = Vec3;

// Writing the color to the PPM file
// - writer: anytype - the writer to write to, e.g. stdout
// - pixel_color: *Color - a pointer to the color to write
pub fn writeColor(writer: anytype, pixel_color: *Color) !void {
    const r: f64 = pixel_color.x();
    const g: f64 = pixel_color.y();
    const b: f64 = pixel_color.z();

    const r_byte: u64 = @intFromFloat(255.999 * r);
    const g_byte: u64 = @intFromFloat(255.999 * g);
    const b_byte: u64 = @intFromFloat(255.999 * b);

    try writer.print("{d} {d} {d}\n", .{ r_byte, g_byte, b_byte });
}
