const c = @import("../c.zig");

const Window = @import("../Window.zig");

const Event = Window.Event;

pub const Error = error{
    CouldNotGetInstance,
    CouldNotRegisterClass,
    CouldNotCreateWindow,
    CouldNotGetDeviceContext,
};

fn windowCallback(h_wnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.C) c.LRESULT {
    switch (msg) {
        c.WM_CLOSE => c.PostQuitMessage(0),
        else => return c.DefWindowProcA(h_wnd, msg, w_param, l_param),
    }

    return 0;
}

pub const Base = struct {
    const Self = @This();

    handle: c.HWND,
    device_context: c.HDC,

    pub fn init(
        title: [:0]const u8,
        x: i32,
        y: i32,
        width: u32,
        height: u32,
    ) Error!Self {
        const instance = c.GetModuleHandleA(null) orelse {
            return error.CouldNotGetInstance;
        };

        const window_class = c.WNDCLASS{
            .style = c.CS_HREDRAW | c.CS_VREDRAW | c.CS_OWNDC,
            .lpfnWndProc = windowCallback,
            .hInstance = instance,
            .hbrBackground = 0,
            .lpszClassName = "Clowder Window Class",
        };

        if (c.RegisterClassA(&window_class) == 0) {
            return error.CouldNotRegisterClass;
        }

        const window = c.CreateWindowExA(
            0,
            window_class.lpszClassName,
            title,
            c.WS_OVERLAPPEDWINDOW,
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

        _ = c.ShowWindow(window, c.SW_SHOW);

        const device_context = c.GetDC(window);

        return .{
            .handle = window,
            .device_context = device_context,
        };
    }

    pub fn deinit(self: Self) void {
        _ = c.ReleaseDC(self.handle, self.device_context);
        _ = c.DestroyWindow(self.handle);
    }

    pub fn pollEvent(self: Self) ?Event {
        _ = self;

        var msg = c.MSG{};

        if (c.PeekMessageA(&msg, null, 0, 0, c.PM_REMOVE) == c.TRUE) {
            _ = c.TranslateMessage(&msg);
            _ = c.DispatchMessageA(&msg);
        }

        return switch (msg.message) {
            c.WM_QUIT => .close,
            else => null,
        };
    }
};
