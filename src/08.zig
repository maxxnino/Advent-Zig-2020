const std = @import("std");
const print = std.debug.print;
const ArrayList = std.ArrayList;
const test_allocator = std.testing.allocator;
const eqlString = std.array_hash_map.eqlString;
pub fn main() !void {
    try part1();
    try part2();
}
const Intruction = union(enum) {
    nop: i32,
    acc: i32,
    jmp: i32,
};
const Step = struct {
    instruction: Intruction,
    numberRun: usize = 0,
    isChange: bool = false,
};
pub fn getData(program: *ArrayList(Step)) !void {
    const path = "testdata/08.txt";
    const input = try std.fs.cwd().openFile(path, .{});
    var buf: [std.mem.page_size]u8 = undefined;
    while (try input.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var it = std.mem.tokenize(line, " ");
        const ops = it.next().?;
        const value = try std.fmt.parseInt(i32, it.next().?, 10);
        const tag_intruction = std.meta.stringToEnum(std.meta.Tag(Intruction), ops).?;
        switch (tag_intruction) {
            .nop => try program.append(Step{
                .instruction = Intruction{ .nop = value },
            }),
            .acc => try program.append(Step{
                .instruction = Intruction{ .acc = value },
            }),
            .jmp => try program.append(Step{
                .instruction = Intruction{ .jmp = value },
            }),
        }
    }
}
pub fn part2() !void {
    var program = ArrayList(Step).init(test_allocator);
    defer program.deinit();
    try getData(&program);
    var instruction_index: i32 = 0;
    var items = program.items;
    var current_acc: i32 = 0;
    const end_index = program.items.len;
    var test_time: usize = 1;
    var is_fixed: bool = false;
    while (true) {
        if (instruction_index == end_index) {
            break;
        }
        var current_intruction = &items[@intCast(usize, instruction_index)];
        if (current_intruction.*.numberRun == test_time) {
            test_time += 1;
            instruction_index = 0;
            current_acc = 0;
            is_fixed = false;
            continue;
        }
        current_intruction.*.numberRun = test_time;
        switch (current_intruction.instruction) {
            .acc => |value| {
                current_acc += value;
                instruction_index += 1;
            },
            .jmp => |value| {
                if (!current_intruction.isChange and is_fixed == false) {
                    is_fixed = true;
                    instruction_index += 1;
                    current_intruction.*.isChange = true;
                } else {
                    instruction_index += value;
                }
            },
            .nop => |value| {
                if (!current_intruction.isChange and is_fixed == false) {
                    is_fixed = true;
                    instruction_index += value;
                    current_intruction.*.isChange = true;
                } else {
                    instruction_index += 1;
                }
            },
        }
    }
    print("Part2: {}\n", .{current_acc});
}
pub fn part1() !void {
    var program = ArrayList(Step).init(test_allocator);
    defer program.deinit();
    try getData(&program);
    var instruction_index: i32 = 0;
    var items = program.items;
    var current_acc: i32 = 0;
    while (true) {
        var current_intruction = &items[@intCast(usize, instruction_index)];
        if (current_intruction.*.numberRun == 1) {
            break;
        }
        current_intruction.*.numberRun += 1;
        switch (current_intruction.instruction) {
            .acc => |value| {
                current_acc += value;
                instruction_index += 1;
            },
            .jmp => |value| instruction_index += value,
            .nop => instruction_index += 1,
        }
    }
    print("Accumulate: {}\n", .{current_acc});
}
