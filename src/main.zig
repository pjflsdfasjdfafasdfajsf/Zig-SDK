const std = @import("std");
const sdk = @import("sdk");

const mod = @import("mod");

pub const std_options: std.Options = .{
    .logFn = sdk.log,
};

comptime {
    _ = mod;
}

var state: sdk.State = undefined;
var render_command_buffer_backing_memory: [128 * 1024]u8 = @splat(0);
var render_command_buffer: sdk.RenderCommandBuffer = .{
    .memory = .{ .ptr = &render_command_buffer_backing_memory },
    .capacity = render_command_buffer_backing_memory.len,
};

export fn guest_get_state() *sdk.State {
    return &state;
}

export fn guest_get_buffer() *sdk.RenderCommandBuffer {
    return &render_command_buffer;
}

export fn guest_initialize() void {
    mod.init() catch |err| handleError(err);
}

export fn guest_update() void {
    mod.update(&state, &render_command_buffer) catch |err| handleError(err);
}

fn handleError(err: anyerror) void {
    state.ok = false;
    sdk.log(.err, .default, "{t}", .{err});
}
