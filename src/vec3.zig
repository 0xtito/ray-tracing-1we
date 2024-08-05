const std = @import("std");
const math = std.math;

// NOTE: This is a simple implementation of a 3D vector
// I could have utilized `@Vector`, but in the spirit of the project, I implemented it myself.
pub const Vec3 = struct {
    e: [3]f64 = .{ 0.0, 0.0, 0.0 },

    pub inline fn init(e0: f64, e1: f64, e2: f64) Vec3 {
        return Vec3{ .e = .{ e0, e1, e2 } };
    }

    pub inline fn zero() Vec3 {
        return Vec3{ .e = .{ 0.0, 0.0, 0.0 } };
    }

    pub inline fn x(self: *const Vec3) f64 {
        return self.e[0];
    }

    pub inline fn y(self: *const Vec3) f64 {
        return self.e[1];
    }

    pub inline fn z(self: *const Vec3) f64 {
        return self.e[2];
    }

    pub inline fn add(self: *const Vec3, other: *const Vec3) Vec3 {
        return Vec3.init(self.e[0] + other.e[0], self.e[1] + other.e[1], self.e[2] + other.e[2]);
    }

    pub inline fn sub(self: *const Vec3, other: *const Vec3) Vec3 {
        return Vec3.init(self.e[0] - other.e[0], self.e[1] - other.e[1], self.e[2] - other.e[2]);
    }

    pub inline fn mul(self: *const Vec3, t: f64) Vec3 {
        return Vec3.init(self.e[0] * t, self.e[1] * t, self.e[2] * t);
    }

    pub inline fn div(self: *const Vec3, t: f64) Vec3 {
        return self.mul(1 / t);
    }

    pub fn len(self: *const Vec3) f64 {
        return @sqrt(self.len_sq());
    }

    pub fn len_sq(self: *const Vec3) f64 {
        return math.pow(f64, self.e[0], 2.0) + math.pow(f64, self.e[1], 2.0) + math.pow(f64, self.e[2], 2.0);
    }

    pub fn dot(self: *const Vec3, other: *const Vec3) f64 {
        return (self.e[0] * other.e[0]) + (self.e[1] * other.e[1]) + (self.e[2] * other.e[2]);
    }

    pub fn cross(self: *const Vec3, other: *const Vec3) Vec3 {
        return Vec3{
            .e = .{
                self.e[1] * other.e[2] - self.e[2] * other.e[1], // x
                self.e[2] * other.e[0] - self.e[0] * other.e[2], // y
                self.e[0] * other.e[1] - self.e[1] * other.e[0], // z
            },
        };
    }
};

pub inline fn unitVector(v: *const Vec3) Vec3 {
    return div(v, v.len());
}

pub fn add(v1: *const Vec3, v2: *const Vec3) Vec3 {
    return Vec3.init(v1.e[0] + v2.e[0], v1.e[1] + v2.e[1], v1.e[2] + v2.e[2]);
}

pub fn sub(v1: *const Vec3, v2: *const Vec3) Vec3 {
    return Vec3.init(v1.e[0] - v2.e[0], v1.e[1] - v2.e[1], v1.e[2] - v2.e[2]);
}

pub fn mul(v: *const Vec3, t: f64) Vec3 {
    return Vec3.init(v.e[0] * t, v.e[1] * t, v.e[2] * t);
}

pub fn div(v: *const Vec3, t: f64) Vec3 {
    return mul(v, 1 / t);
}

pub const Color = Vec3;
const Ray = @import("ray.zig").Ray;

// Writing the color to the PPM file
// - writer: anytype - the writer to write to, e.g. stdout
// - pixel_color: *Color - a pointer to the color to write
pub fn writeColor(writer: anytype, pixel_color: *const Color) !void {
    const r: f64 = pixel_color.x();
    const g: f64 = pixel_color.y();
    const b: f64 = pixel_color.z();

    const r_byte: u64 = @intFromFloat(255.999 * r);
    const g_byte: u64 = @intFromFloat(255.999 * g);
    const b_byte: u64 = @intFromFloat(255.999 * b);

    try writer.print("{d} {d} {d}\n", .{ r_byte, g_byte, b_byte });
}

const test_vector = Vec3.init(0.0, 0.0, -1.0);

pub fn rayColor(ray: *const Ray) Color {
    const v = Vec3.init(0.0, 0.0, -1.0);

    const t = hitSphere(&v, 0.5, ray);
    if (t > 0.0) {
        const N = unitVector(&ray.at(t).sub(&v));
        return Color.init(N.x() + 1.0, N.y() + 1.0, N.z() + 1.0).mul(0.5);
    }
    const ray_dir: *const Vec3 = ray.direction();
    const unit_dir: Vec3 = unitVector(ray_dir);
    const a: f64 = math.clamp(0.5 * (unit_dir.y() + 1.0), 0.0, 1.0);
    const color_1 = Color.init(1.0, 1.0, 1.0).mul(1.0 - a);
    const color_2 = Color.init(0.5, 0.7, 1.0).mul(a);

    return color_1.add(&color_2);
}

pub fn hitSphere(center: *const Vec3, radius: f64, ray: *const Ray) f64 {
    const oc = sub(center, ray.origin());
    const a = Vec3.dot(ray.direction(), ray.direction());
    const b = -2.0 * Vec3.dot(ray.direction(), &oc);
    const c = Vec3.dot(&oc, &oc) - radius * radius;
    const discriminant = (b * b) - (4 * a * c);
    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-b - math.sqrt(discriminant)) / (2.0 * a);
    }
}
