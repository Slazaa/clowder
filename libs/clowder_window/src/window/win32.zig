const c = @import("../c.zig");

const Window = @import("../Window.zig");

const Event = Window.Event;
const RenderBackend = Window.RenderBackend;

pub const Error = error{
    CouldNotGetHInstance,
    CouldNotRegisterClass,
    CouldNotCreateWindow,
    CouldNotGetDeviceContext,
    CouldNotFindPixelFormat,
    CouldNotSetPixelFormat,
    CouldNotCreateContext,
    CouldNotMakeContextCurrent,
    CouldNotGetProcAddress,
    CouldNotGetExtension,
};

var wglCreateContextAttribARB: *const fn (c.HDC, c.HGLRC, [*c]const c_int) callconv(.C) c.HGLRC = undefined;
var wglChoosePixelFormatARB: *const fn (c.HDC, [*c]const c_int, [*c]const c.FLOAT, c.UINT, c_int, c.UINT) callconv(.C) c.BOOL = undefined;

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

    initContext: *const fn (self: Self) Error!c.HGLRC,

    pub fn init(
        title: [:0]const u8,
        x: i32,
        y: i32,
        width: u32,
        height: u32,
        comptime render_backend: RenderBackend,
    ) Error!Self {
        const instance = c.GetModuleHandleA(null) orelse {
            return error.CouldNotGetHInstance;
        };

        const window_class = c.WNDCLASS{
            .style = c.CS_HREDRAW | c.CS_VREDRAW | c.CS_OWNDC,
            .lpfnWndProc = windowCallback,
            .hInstance = instance,
            .hCursor = c.LoadCursor(0, c.IDC_ARROW),
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

        return .{
            .handle = window,

            .initContext = switch (render_backend) {
                .opengl => initOpenglContext,
            },
        };
    }

    pub fn deinit(self: Self) void {
        _ = c.DestroyWindow(self.handle);
    }

    fn initOpenglExtensions() Error!void {
        const instance = c.GetModuleHandleA(null) orelse {
            return error.CouldNotGetHInstance;
        };

        const window_class = c.WNDCLASS{
            .style = c.CS_HREDRAW | c.CS_VREDRAW | c.CS_OWNDC,
            .lpfnWndProc = c.DefWndProcA,
            .hInstance = instance,
            .lpszClassName = "Dummy Clowder Window Class",
        };

        if (c.RegisterClassA(&window_class) == 0) {
            return error.CouldNotRegisterClass;
        }

        const window = c.CreateWindowExA(
            0,
            window_class.lpszClassName,
            "Dummy Clowder Window",
            0,
            c.CW_USEDEFAULT,
            c.CW_USEDEFAULT,
            c.CW_USEDEFAULT,
            c.CW_USEDEFAULT,
            null,
            null,
            instance,
            null,
        ) orelse {
            return error.CouldNotCreateWindow;
        };

        const device_context = c.GetDC(window) orelse {
            return error.CouldNotGetDeviceContext;
        };

        var pixel_form_desc = c.PIXELFORMATDESCRIPTOR{
            .nSize = @sizeOf(c.PIXELFORMATDESCRIPTOR),
            .nVersion = 1,
            .iPixelType = c.PFD_TYPE_RGBA,
            .dwFlags = c.PFD_DRAW_TO_WINDOW | c.PFD_SUPPORT_OPENGL | c.PFD_DOUBLEBUFFER,
            .cColorBits = 32,
            .cAlphaBits = 8,
            .iLayerType = c.PFD_MAIN_PLANE,
            .cDepthBits = 24,
            .cStencilBits = 8,
        };

        const pixel_format = c.ChoosePixelFormat(device_context, &pixel_form_desc);

        if (pixel_format == 0) {
            return error.CouldNotFindPixelFormat;
        }

        if (c.SetPixelFormat(device_context, pixel_format, &pixel_form_desc) == c.FALSE) {
            return error.CouldNotSetPixelFormat;
        }

        const context = c.wglCreateContext(device_context) orelse {
            return error.CouldNotCreateContext;
        };

        if (c.wglMakeCurrent(device_context, context) != 0) {
            return error.CouldNotMakeContextCurrent;
        }

        wglCreateContextAttribARB = c.wglGetProcAddress("wglCreateContextAttribARB") orelse {
            return error.CouldNotGetProcAddress;
        };

        wglChoosePixelFormatARB = c.wglGetProcAddress("wglChoosePixelFormatARB") orelse {
            return error.CouldNotGetProcAddress;
        };

        c.wglMakeCurrent(device_context, null);
        c.wglDeleteContext(context);
        c.ReleaseDC(window, device_context);
        c.DestroyWindow(window);
    }

    fn initOpenglContext(self: Self) Error!c.HGLRC {
        try initOpenglExtensions();

        const context = c.wglCreateContext(self.device_context) orelse {
            return error.CouldNotCreateContext;
        };

        if (c.wglMakeCurrent(self.device_context, context) != 0) {
            return error.CouldNotMakeContextCurrent;
        }

        const wglGetExtensionsStringARB = c.wglGetProcAddress("wGetExtensionsStringARB") orelse {
            return error.CouldNotGetProcAddress;
        };
        _ = wglGetExtensionsStringARB;

        return context;
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
