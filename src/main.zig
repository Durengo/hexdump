const std = @import("std");

pub fn main() !u8 {
    // Ensure return
    var return_value: u8 = 0;
    defer {
        if (return_value != 0) {
            std.log.err("status: {d}", .{return_value});
        } else {
            std.log.debug("status: {d}", .{return_value});
        }
    }

    // Capture args
    const allocator = std.heap.page_allocator;
    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    // Make sure path is provided
    if (args.inner.count < 2) {
        std.log.err("Provide file location.", .{});
        return_value = 1;
        return return_value;
    }

    var i: usize = 0;
    var filePath: []const u8 = undefined;
    while (args.next()) |arg| : (i += 1) {
        std.log.debug("{s}", .{arg});
        if (i == 1) {
            filePath = arg;
            std.log.debug("path: {s}", .{filePath});
            break;
        }
    }

    // Validate the path
    const file = std.fs.openFileAbsolute(filePath, .{ .mode = .read_only }) catch |err|
        {
        switch (err) {
            else => {
                std.log.err("Unknown error {}", .{err});
                return_value = 1;
                return return_value;
            },
        }
    };
    defer file.close();

    // Read the file
    // create buffer with allocator 1MB
    const buffer_size: usize = 1024 * 1024; // 1MB
    const buffer = try allocator.alloc(u8, buffer_size);
    defer allocator.free(buffer);
    const bytesToRead = try file.readAll(buffer);
    const fileContents = buffer[0..bytesToRead];

    // Print the file contents in hex (grouped 16 bytes per line)
    var line: usize = 0;
    for (fileContents, 0..) |byte, index| {
        if (index % 16 == 0) {
            std.debug.print("\n", .{});
        }
        if (index % 16 == 0) {
            std.debug.print("[{d}] ", .{line});
            line += 1;
        }
        std.debug.print("0x{X:0>2} ", .{byte});

        // if last byte, print newline
        if (index == bytesToRead - 1) {
            std.debug.print("\n", .{});
        }
    }

    return return_value;
}

test "simple test" {
    try std.testing.expectEqual(1, 1);
}
