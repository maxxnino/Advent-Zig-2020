const std = @import("std");

pub fn main() !void {
    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    const path = "testdata/01.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var array = std.ArrayList(usize).init(std.heap.page_allocator);
    defer array.deinit();
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const number = try std.fmt.parseUnsigned(usize, line, 10);
        try array.append(number);
    }
    blk: for (array.items) |number| {
        for (array.items) |number1| {
            for (array.items) |number2| {
                if (number + number1 + number2 == 2020) {
                    std.debug.print("{}\n", .{number * number1 * number2});
                    break :blk;
                }
            }
        }
    }
}
