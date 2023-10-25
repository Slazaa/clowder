const c = @import("../c.zig");

const window = @import("../window.zig");

const Event = window.Event;

fn wndProc(h_wnd: c.HWND, msg: c.UINT, w_param: c.WPARAM, l_param: c.LPARAM) callconv(.C) c.LRESULT {
    switch (msg) {
        c.WM_CLOSE => c.PostQuitMessage(0),
        else => return c.DefWindowProcA(h_wnd, msg, w_param, l_param),
    }

    return 0;
}

pub const WindowError = error{
    CouldNotGetHInstance,
    CouldNotRegisterClass,
    CouldNotCreateWindow,
    CouldNotGetDeviceContext,
    CouldNotFindPixelFormat,
    CouldNotDescribePixelFormat,
    CouldNotSetPixelFormat,
};

pub const WindowBase = struct {
    const Self = @This();

    handle: c.HWND,
    device_context: c.HDC,

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
            c.WS_OVERLAPPEDWINDOW | c.WS_CLIPSIBLINGS | c.WS_CLIPCHILDREN,
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

        const device_context = c.GetDC(h_wnd) orelse {
            return error.CouldNotGetDeviceContext;
        };

        var pixel_form_desc = c.PIXELFORMATDESCRIPTOR{
            .nSize = @sizeOf(c.PIXELFORMATDESCRIPTOR),
            .nVersion = 1,
            .dwFlags = c.PFD_DRAW_TO_WINDOW | c.PFD_SUPPORT_OPENGL | c.PFD_DOUBLEBUFFER,
            .iPixelType = c.PFD_TYPE_RGBA,
            .cColorBits = 24,
        };

        const pixel_format = c.ChoosePixelFormat(device_context, &pixel_form_desc);

        if (pixel_format == 0) {
            return error.CouldNotFindPixelFormat;
        }

        if (c.DescribePixelFormat(device_context, pixel_format, @sizeOf(c.PIXELFORMATDESCRIPTOR), &pixel_form_desc) == 0) {
            return error.CouldNotDescribePixelFormat;
        }

        if (c.SetPixelFormat(device_context, pixel_format, &pixel_form_desc) == c.FALSE) {
            return error.CouldNotSetPixelFormat;
        }

        _ = c.ShowWindow(h_wnd, c.SW_SHOW);

        return .{
            .handle = h_wnd,
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
