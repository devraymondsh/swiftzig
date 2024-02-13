# Swift lib
This is a std library for Zig that's focused on performance and minimalism. It currently only supports x86_64 and aarch64 Linux. This project is open for contribution and extending this project to other operating systems. However, 32bit architectures will never be supported.

### Usage
#### 1. Add swiftzig to your `build.zig.zon`
```zig
.{
    .name = "<your_apps_name>",
    .version = "<your_apps_vesion>",
    .dependencies = .{
        // swiftzig v0.4.0
        .swiftzig = .{
            .url = "https://github.com/devraymondsh/swiftzig/archive/refs/tags/v0.4.0.tar.gz",
            .hash = "12201501ad4ac2d6827b2a293219ec8a49d7d12239895f17ad00c6209b0418dad3fe",
        },
    },
}
```
#### 2. Add swiftzig to your `build.zig`
```zig
const swiftzig = b.dependency("swiftzig", .{
    .target = target,
    .optimize = optimize,
});
exe.addModule("swiftzig", swiftzig.module("swiftzig"));
```

### License
This library is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.
