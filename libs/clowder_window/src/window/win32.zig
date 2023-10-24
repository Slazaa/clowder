const c = @import("../c.zig");

fn wndProc(h_wnd: c.HWND, msg: c.UINT, wparam: c.WPARAM, lparam: c.LPARAM) callconv(.C) c.LRESULT {
    _ = h_wnd;
    _ = lparam;
    _ = wparam;
    _ = msg;
}

pub const WindowError = error{
    CouldNotGetHInstance,
    CouldNotRegisterClass,
    CouldNotCreateWindow,
};

pub const WindowBase = struct {
    const Self = @This();

    pub fn init(title: [:0]const u8, x: i32, y: i32, width: u32, height: u32) WindowError!Self {
        const h_instance = c.GetModuleHandle(null) orelse {
            return error.CouldNotGetHInstance;
        };

        const win_class = c.WNDCLASS{
            .lpfnWndProc = wndProc,
            .hInstance = h_instance,
            .lpszClassName = "Clowder Window Class",
        };

        if (c.RegisterClass(&win_class) == 0) {
            return error.CouldNotRegisterClass;
        }

        const h_wnd = c.CreateWindowEx(
            0,
            win_class,
            title,
            c.WS_OVERLAPPEDWINDOW,
            x,
            y,
            width,
            height,
            null,
            null,
            h_instance,
            null,
        ) orelse {
            return error.CouldNotCreateWindow;
        };

        c.ShowWindow(h_wnd, c.SW_SHOW);
    }

    pub fn deinit(self: Self) void {
        _ = self;

        @panic("Unimplemented");
    }
};
