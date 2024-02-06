# Swift lib
This is a std library for Zig that's focused on performance and minimalism. It currently only supports x86_64 and aarch64 Linux. This project is open for contribution and extending this project to other operating systems. However, 32bit architectures will never be supported.

### Usage
#### 1. Add swift_lib to your `build.zig.zon`
```zig
.{
    .name = "<your_apps_name>",
    .version = "<your_apps_vesion>",
    .dependencies = .{
        // swift_lib v0.3.0
        .swift_lib = .{
            .url = "https://github.com/devraymondsh/swift_lib/archive/refs/tags/v0.3.0.tar.gz",
            .hash = "12201501ad4ac2d6827b2a293219ec8a49d7d12239895f17ad00c6209b0418dad3fe",
        },
    },
}
```
#### 2. Add swift_lib to your `build.zig`
```zig
const swift_lib = b.dependency("swift_lib", .{
    .target = target,
    .optimize = optimize,
});
exe.addModule("swift_lib", swift_lib.module("swift_lib"));
```

### License
This library is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
