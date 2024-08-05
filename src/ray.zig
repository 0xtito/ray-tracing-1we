const std = @import("std");

const V = @import("vec3.zig");
const Vec3 = V.Vec3;

pub const Ray = struct {
    _orig: *const Vec3,
    _dir: *const Vec3,

    pub fn init(_origin: *const Vec3, _direction: *const Vec3) Ray {
        return Ray{ ._orig = _origin, ._dir = _direction };
    }

    pub fn origin(self: *const Ray) *const Vec3 {
        return self._orig;
    }

    pub fn direction(self: *const Ray) *const Vec3 {
        return self._dir;
    }

    pub fn at(self: *const Ray, t: f64) Vec3 {
        return self._orig.add(&self._dir.mul(t));
    }
};
