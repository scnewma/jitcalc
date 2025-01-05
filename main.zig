const std = @import("std");

const SIZE: usize = 8192;
const NLOOPS: usize = 10_000_000;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    var args = std.process.args();
    _ = args.skip();
    const prg = args.next() orelse {
        std.debug.print("Usage: jitcalc \"PROGRAM\"\n", .{});
        std.process.exit(1);
    };

    var jit = try JitCalc.init();
    defer jit.deinit();
    for (prg) |token| {
        if (token == ' ') {
            continue;
        }
        jit.compile(token);
    }
    jit.emit_instructions(&.{0xc3}); // ret

    var result: isize = 0;
    for (0..NLOOPS) |_| {
        result = jit.execute(1);
    }
    try stdout.print("{} N={}\n", .{ result, NLOOPS });
}

const BufferSize = 8 * 1024;

const JitCalc = struct {
    buffer: []align(std.mem.page_size) u8,
    offset: usize = 0,

    pub fn init() !@This() {
        const buffer = try std.posix.mmap(null, BufferSize, std.posix.PROT.READ | std.posix.PROT.WRITE | std.posix.PROT.EXEC, .{ .TYPE = .PRIVATE, .ANONYMOUS = true }, -1, 0);
        var r: @This() = .{
            .buffer = buffer,
        };
        // mov %rdi, $rax
        r.emit_instructions(&.{ 0x48, 0x89, 0xf8 });
        return r;
    }

    pub fn deinit(self: *@This()) void {
        std.posix.munmap(self.buffer);
    }

    pub fn compile(self: *@This(), token: u8) void {
        const instr: []const u8 = switch (token) {
            // add %rax, $1
            '+' => &.{ 0x48, 0x83, 0xc0, 0x01 },
            // sub %rax, $1
            '-' => &.{ 0x48, 0xff, 0xc8 },
            // add %rax, %rax
            '*' => &.{ 0x48, 0x01, 0xc0 },
            // sar rax, $1
            '/' => &.{ 0x48, 0xd1, 0xf8 },
            else => return,
        };
        self.emit_instructions(instr);
    }

    fn emit_instructions(self: *@This(), instr: []const u8) void {
        std.mem.copyForwards(u8, self.buffer[self.offset..], instr);
        self.offset += instr.len;
    }

    pub fn execute(self: *@This(), initialValue: isize) isize {
        return @as(*const fn (isize) isize, @ptrCast(self.buffer))(initialValue);
    }
};
