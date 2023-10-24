const c = @import("../c.zig");

const window = @import("../window.zig");

const Event = window.Event;

fn wndProc(h_wnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.C) c.LRESULT {
    switch (msg) {
        c.WM_CLOSE => _ = c.DestroyWindow(h_wnd),
        c.WM_DESTROY => c.PostQuitMessage(0),
        else => return c.DefWindowProcA(h_wnd, msg, w_param, l_param),
    }

    return 0;
}

pub const WindowError = error{
    CouldNotGetHInstance,
    CouldNotRegisterClass,
    CouldNotCreateWindow,
};

pub const WindowBase = struct {
    const Self = @This();

    handle: c.HWND,

    pub fn init(title: [:0]const u8, x: i32, y: i32, width: u32, height: u32) WindowError!Self {
        const h_instance = c.GetModuleHandleA(null) orelse {
            return error.CouldNotGetHInstance;
        };

        const win_class_name = "Clowder Window Class";

        const win_class = c.WNDCLASS{
            .lpfnWndProc = wndProc,
            .hInstance = h_instance,
            .lpszClassName = win_class_name,
        };

        if (c.RegisterClassA(&win_class) == 0) {
            return error.CouldNotRegisterClass;
        }

        const h_wnd = c.CreateWindowExA(
            0,
            win_class_name,
            title,
            c.WS_OVERLAPPEDWINDOW,
            x,
            y,
            @intCast(width),
            @intCast(height),
            null,
            null,
            h_instance,
            null,
        ) orelse {
            return error.CouldNotCreateWindow;
        };

        _ = c.ShowWindow(h_wnd, c.SW_SHOW);

        return .{
            .handle = h_wnd,
        };
    }

    pub fn deinit(self: Self) void {
        _ = self;
    }

    pub fn pollEvent(self: Self) ?Event {
        _ = self;

        var msg = c.MSG{};

        if (c.PeekMessageA(&msg, null, 0, 0, c.PM_REMOVE) != 0) {
            _ = c.TranslateMessage(&msg);
            _ = c.DispatchMessageA(&msg);
        }

        return switch (msg.message) {
            c.WM_QUIT => .close,
            else => null,
        };
    }
};
