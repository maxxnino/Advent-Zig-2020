const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const hashString = std.array_hash_map.hashString;
const eqlString = std.array_hash_map.eqlString;
const BagCount = struct {
    hash_bag: u64,
    count: usize,
};
pub fn findGoldBag(color_map: std.AutoHashMap(u64, ArrayList(u64)), parent_hash: u64, shiny_hash: u64) bool {
    var count: usize = 0;
    const parent_list = color_map.getEntry(parent_hash).?;
    for (parent_list.value.items) |child_hash| {
        if (child_hash == shiny_hash) {
            return true;
        } else if (findGoldBag(color_map, child_hash, shiny_hash)) {
            return true;
        }
    }
    return false;
}
pub fn countGoldBag(color_map: std.AutoHashMap(u64, ArrayList(BagCount)), parent_hash: u64) usize {
    var count: usize = 0;
    const parent_list = color_map.getEntry(parent_hash).?;
    for (parent_list.value.items) |bag| {
       count += bag.count; 
       count += bag.count * countGoldBag(color_map, bag.hash_bag);
    }
    return count;
}
pub fn part1() !void {
    const path = "testdata/07.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var color_map = std.AutoHashMap(u64, ArrayList(u64)).init(test_allocator);
    defer color_map.deinit();
    var current_color = ArrayList(u8).init(test_allocator);
    defer current_color.deinit();
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try current_color.resize(0);
        var it = std.mem.tokenize(line, " ,.");
        try current_color.appendSlice(it.next().?);
        try current_color.appendSlice(it.next().?);
        var parentHash: u64 = hashString(current_color.items);
        _ = it.next().?; //bag
        _ = it.next().?; //containt
        try current_color.resize(0);
        var list = ArrayList(u64).init(test_allocator);
        while (it.next()) |no_or_number| {
            if (!eqlString(no_or_number, "no")) {
                var number = std.fmt.parseInt(u32, no_or_number, 10);
                try current_color.appendSlice(it.next().?);
                try current_color.appendSlice(it.next().?);
                const child_hash = hashString(current_color.items);
                try list.append(child_hash);
                try current_color.resize(0);
                _ = it.next(); //skip bag
                continue;
            }
            _ = it.next();
            _ = it.next();
        }
        try color_map.put(parentHash, list);
    }
    const shiny_hash = hashString("shinygold");
    var count_shiny: usize = 0;
    var it = color_map.iterator();
    while (it.next()) |kv| {
        if (findGoldBag(color_map, kv.key, shiny_hash)) {
            count_shiny += 1;
        }
    }
    print("Shiny Gold: {}\n", .{count_shiny});
}
pub fn part2() !void {
    const path = "testdata/07.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    var color_map = std.AutoHashMap(u64, ArrayList(BagCount)).init(test_allocator);
    defer color_map.deinit();
    var current_color = ArrayList(u8).init(test_allocator);
    defer current_color.deinit();
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try current_color.resize(0);
        var it = std.mem.tokenize(line, " ,.");
        try current_color.appendSlice(it.next().?);
        try current_color.appendSlice(it.next().?);
        var parentHash: u64 = hashString(current_color.items);
        _ = it.next().?; //bag
        _ = it.next().?; //containt
        try current_color.resize(0);
        var list = ArrayList(BagCount).init(test_allocator);
        while (it.next()) |no_or_number| {
            if (!eqlString(no_or_number, "no")) {
                var number = std.fmt.parseInt(u32, no_or_number, 10) catch unreachable;
                try current_color.appendSlice(it.next().?);
                try current_color.appendSlice(it.next().?);
                const child_hash = hashString(current_color.items);
                try list.append(BagCount{
                    .hash_bag = child_hash,
                    .count = number,
                });
                try current_color.resize(0);
                _ = it.next(); //skip bag
                continue;
            }
            _ = it.next();
            _ = it.next();
        }
        try color_map.put(parentHash, list);
    }
    const shiny_hash = hashString("shinygold");
    var it = color_map.iterator();
    const count_shiny = countGoldBag(color_map, shiny_hash);
    print("Total Bag in shiny Gold: {}\n", .{count_shiny});
}
pub fn main() !void {
    try part1();
    try part2();
}
