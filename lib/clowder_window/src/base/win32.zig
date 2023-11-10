const std = @import("std");

const nat = @import("../native/win32.zig");

const Window = @import("../window.zig");

const Event = Window.Event;

pub const Error = error{
    CouldNotGetInstance,
    CouldNotRegisterClass,
    CouldNotCreateWindow,
    CouldNotGetDeviceContext,
};

fn windowCallback(h_wnd: nat.HWND, msg: nat.UINT, w_param: nat.WPARAM, l_param: nat.LPARAM) nat.LRESULT {
    switch (msg) {
        nat.WM_CLOSE => nat.PostQuitMessage(0),
        else => return nat.DefWindowProcA(h_wnd, msg, w_param, l_param),
    }

    return 0;
}

pub const Base = struct {
    const Self = @This();

    handle: nat.HWND,
    device_context: nat.HDC,

    pub fn init(
        title: [:0]const u8,
        x: i32,
        y: i32,
        width: u32,
        height: u32,
    ) Error!Self {
        const instance = nat.GetModuleHandleA(null) orelse {
            return error.CouldNotGetInstance;
        };

        const window_class = std.mem.zeroInit(nat.WNDCLASSA, .{
            .style = nat.CS_HREDRAW | nat.CS_VREDRAW | nat.CS_OWNDC,
            .lpfnWndProc = windowCallback,
            .hInstance = instance,
            .lpszClassName = "Clowder Window Class",
        });

        if (nat.RegisterClassA(&window_class) == 0) {
            return error.CouldNotRegisterClass;
        }

        const window = nat.CreateWindowExA(
            0,
            window_class.lpszClassName,
            title,
            nat.WS_OVERLAPPEDWINDOW,
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

        _ = nat.ShowWindow(window, nat.SW_SHOW);
        _ = nat.UpdateWindow(window);

        const device_context = nat.GetDC(window);

        return .{
            .handle = window,
            .device_context = device_context,
        };
    }

    pub fn deinit(self: Self) void {
        _ = nat.ReleaseDC(self.handle, self.device_context);
        _ = nat.DestroyWindow(self.handle);
    }

    pub fn pollEvent(self: Self) ?Event {
        _ = self;

        var msg = std.mem.zeroInit(nat.MSG, .{});

        if (nat.PeekMessageA(&msg, null, 0, 0, nat.PM_REMOVE) == nat.TRUE) {
            _ = nat.TranslateMessage(&msg);
            _ = nat.DispatchMessageA(&msg);

            return switch (msg.message) {
                nat.WM_QUIT => .close,
                else => null,
            };
        }

        return null;
    }
};