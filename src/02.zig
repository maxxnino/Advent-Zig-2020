const std = @import("std");

pub fn main() !void {
    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //defer arena.deinit();
    const path = "testdata/02.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var bad: usize = 0;
    var good: usize = 0;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenize(line, "-: ");
        const min = try std.fmt.parseUnsigned(usize, it.next().?, 10);
        const max = try std.fmt.parseUnsigned(usize, it.next().?, 10);
        const char = it.next().?[0];
        const password = it.next().?;
        var isGood: bool = (char == password[min - 1] and char != password[max - 1]) or
            (char != password[min - 1] and char == password[max - 1]);
        if (isGood) {
            //std.debug.print("good - {s}\n", .{line});
            good += 1;
        } else {
            //std.debug.print("bad - {s}\n", .{line});
            bad += 1;
        }
    }
    std.debug.print("good: {} - bad: {}", .{ good, bad });
}
