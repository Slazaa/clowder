const std = @import("std");

const nat = @import("../native/win32.zig");
const root = @import("../root.zig");

const math = @import("clowder_math");

const Vec2u = math.Vec2u;

const Window = @import("../window.zig");

pub const Error = error{
    CouldNotGetInstance,
    CouldNotRegisterClass,
    CouldNotCreateWindow,
    CouldNotGetDeviceContext,
};

var event: ?root.Event = null;

fn keyCodeFromNative(code: nat.WPARAM) ?root.Event.KeyCode {
    return switch (code) {
        'A' => .a,
        'B' => .b,
        'C' => .c,
        'D' => .d,
        'E' => .e,
        'F' => .f,
        'G' => .g,
        'H' => .h,
        'I' => .i,
        'J' => .j,
        'K' => .k,
        'L' => .l,
        'M' => .m,
        'N' => .n,
        'O' => .o,
        'P' => .p,
        'Q' => .q,
        'R' => .r,
        'S' => .s,
        'T' => .t,
        'U' => .u,
        'V' => .v,
        'W' => .w,
        'X' => .x,
        'Y' => .y,
        'Z' => .z,
        nat.VK_SPACE => .space,
        else => null,
    };
}

fn windowCallback(h_wnd: nat.HWND, msg: nat.UINT, w_param: nat.WPARAM, l_param: nat.LPARAM) callconv(.C) nat.LRESULT {
    switch (msg) {
        nat.WM_CLOSE => event = .close,
        nat.WM_KEYDOWN => {
            if (keyCodeFromNative(w_param)) |key_code| {
                event = .{ .key = .{
                    .code = key_code,
                    .state = .down,
                } };
            }
        },
        nat.WM_KEYUP => {
            if (keyCodeFromNative(w_param)) |key_code| {
                event = .{ .key = .{
                    .code = key_code,
                    .state = .released,
                } };
            }
        },
        else => return nat.DefWindowProcA(h_wnd, msg, w_param, l_param),
    }

    return 0;
}

pub const Base = struct {
    const Self = @This();

    handle: nat.HWND,
    device_context: nat.HDC,

    pub fn init(title: [:0]const u8, x: i32, y: i32, width: u32, height: u32, config: root.Config) Error!Self {
        const instance = nat.GetModuleHandleA(null) orelse {
            return error.CouldNotGetInstance;
        };

        const window_class = std.mem.zeroInit(nat.WNDCLASSEXA, .{
            .cbSize = @sizeOf(nat.WNDCLASSEXA),
            .style = nat.CS_HREDRAW | nat.CS_VREDRAW | nat.CS_OWNDC,
            .lpfnWndProc = windowCallback,
            .hInstance = instance,
            .hCursor = nat.LoadCursorA(null, nat.IDC_ARROW),
            .lpszClassName = "Clowder Window Class",
        });

        if (nat.RegisterClassExA(&window_class) == 0) {
            return error.CouldNotRegisterClass;
        }

        var flags: nat.DWORD = nat.WS_OVERLAPPED | nat.WS_SYSMENU;

        if (config.resizable) flags |= nat.WS_THICKFRAME;
        if (config.maximize_box) flags |= nat.WS_MAXIMIZEBOX;
        if (config.minimize_box) flags |= nat.WS_MINIMIZEBOX;

        const window = nat.CreateWindowExA(
            0,
            window_class.lpszClassName,
            title,
            flags,
            x,
            y,
            @intCast(width),
            @intCast(height),
            null,
            null,
            instance,
            null,
        ) orelse {
            return error.CouldNotCreateWindow;
        };

        const device_context = nat.GetDC(window);

        _ = nat.ShowWindow(window, nat.SW_SHOW);
        _ = nat.UpdateWindow(window);

        return .{
            .handle = window,
            .device_context = device_context,
        };
    }

    pub fn deinit(self: Self) void {
        _ = nat.ReleaseDC(self.handle, self.device_context);
        _ = nat.DestroyWindow(self.handle);
    }

    pub fn getSize(self: Self) Vec2u {
        var rect: nat.RECT = undefined;
        _ = nat.GetWindowRect(self.handle, &rect);

        return Vec2u{ @intCast(rect.right - rect.left), @intCast(rect.bottom - rect.top) };
    }

    pub fn setTitle(self: Self, title: [:0]const u8) void {
        _ = nat.SetWindowTextA(self.handle, title);
    }

    pub fn pollEvent(_: Self) ?root.Event {
        var msg: nat.MSG = undefined;

        if (nat.PeekMessageA(&msg, null, 0, 0, nat.PM_REMOVE) == nat.TRUE) {
            _ = nat.TranslateMessage(&msg);
            _ = nat.DispatchMessageA(&msg);
        }

        const event_ = event;

        if (event != null) {
            event = null;
        }

        return event_;
    }
};
