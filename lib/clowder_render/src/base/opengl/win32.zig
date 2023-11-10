const std = @import("std");

const cwl_window = @import("clowder_window");

const win_nat = cwl_window.native;

const Window = cwl_window.Window;
const WindowError = cwl_window.WindowError;

const nat = @import("../../native/opengl.zig");

pub const Error = WindowError || error{
    CouldNotChoosePixelFormat,
    CouldNotFindPixelFormat,
    CouldNotDescribePixelFormat,
    CouldNotSetPixelFormat,
    CouldNotGetProcAddres,
    CouldNotCreateContext,
    CouldNotMakeContextCurrent,
};

var wglChoosePixelFormatARB: nat.PFNWGLCHOOSEPIXELFORMATARBPROC = undefined;
var wglCreateContextAttribsARB: nat.PFNWGLCREATECONTEXTATTRIBSARBPROC = undefined;

pub const Base = struct {
    const Self = @This();

    context: win_nat.HGLRC,

    pub fn init(window: Window) Error!Self {
        return .{
            .context = try initContenxt(window.base.device_context),
        };
    }

    fn initExtensions() Error!void {
        const instance = win_nat.GetModuleHandleA(null) orelse {
            return error.CouldNotGetInstance;
        };

        const window_class = std.mem.zeroInit(win_nat.WNDCLASSA, .{
            .style = win_nat.CS_HREDRAW | win_nat.CS_VREDRAW | win_nat.CS_OWNDC,
            .lpfnWndProc = win_nat.DefWindowProcA,
            .hInstance = instance,
            .lpszClassName = "Dummy Clowder Window Class",
        });

        if (win_nat.RegisterClassA(&window_class) == 0) {
            return error.CouldNotRegisterClass;
        }

        const window = win_nat.CreateWindowExA(
            0,
            window_class.lpszClassName,
            "Dummy Clowder Window",
            0,
            win_nat.CW_USEDEFAULT,
            win_nat.CW_USEDEFAULT,
            win_nat.CW_USEDEFAULT,
            win_nat.CW_USEDEFAULT,
            null,
            null,
            instance,
            null,
        ) orelse {
            return error.CouldNotCreateWindow;
        };

        const device_context = win_nat.GetDC(window) orelse {
            return error.CouldNotGetDeviceContext;
        };

        var pixel_form_desc = std.mem.zeroInit(win_nat.PIXELFORMATDESCRIPTOR, .{
            .nSize = @sizeOf(win_nat.PIXELFORMATDESCRIPTOR),
            .nVersion = 1,
            .iPixelType = win_nat.PFD_TYPE_RGBA,
            .dwFlags = win_nat.PFD_DRAW_TO_WINDOW | win_nat.PFD_SUPPORT_OPENGL | win_nat.PFD_DOUBLEBUFFER,
            .cColorBits = 32,
            .cAlphaBits = 8,
            .cDepthBits = 24,
            .cStencilBits = 8,
        });

        const pixel_format = win_nat.ChoosePixelFormat(device_context, &pixel_form_desc);

        if (pixel_format == 0) {
            return error.CouldNotFindPixelFormat;
        }

        if (win_nat.SetPixelFormat(device_context, pixel_format, &pixel_form_desc) == win_nat.FALSE) {
            return error.CouldNotSetPixelFormat;
        }

        const context = win_nat.wglCreateContext(device_context) orelse {
            return error.CouldNotCreateContext;
        };

        if (win_nat.wglMakeCurrent(device_context, context) == win_nat.FALSE) {
            return error.CouldNotMakeContextCurrent;
        }

        wglChoosePixelFormatARB = @as(nat.PFNWGLCHOOSEPIXELFORMATARBPROC, @ptrCast(win_nat.wglGetProcAddress("wglChoosePixelFormatARB") orelse {
            return error.CouldNotGetProcAddres;
        }));

        wglCreateContextAttribsARB = @as(nat.PFNWGLCREATECONTEXTATTRIBSARBPROC, @ptrCast(win_nat.wglGetProcAddress("wglCreateContextAttribsARB") orelse {
            return error.CouldNotGetProcAddres;
        }));

        _ = win_nat.wglMakeCurrent(device_context, null);
        _ = win_nat.wglDeleteContext(context);
        _ = win_nat.ReleaseDC(window, device_context);
        _ = win_nat.DestroyWindow(window);
    }

    fn initContenxt(device_context: win_nat.HDC) Error!win_nat.HGLRC {
        try initExtensions();

        const pixel_format_attribs = [_]c_int{
            win_nat.WGL_DRAW_TO_WINDOW_ARB, nat.GL_TRUE,
            win_nat.WGL_SUPPORT_OPENGL_ARB, nat.GL_TRUE,
            win_nat.WGL_DOUBLE_BUFFER_ARB,  nat.GL_TRUE,
            win_nat.WGL_PIXEL_TYPE_ARB,     win_nat.WGL_TYPE_RGBA_ARB,
            0,
        };

        var pixel_format: c_int = undefined;
        var num_formats: win_nat.UINT = undefined;

        if (wglChoosePixelFormatARB(device_context, &pixel_format_attribs, null, 512, &pixel_format, &num_formats) == win_nat.FALSE) {
            return error.CouldNotChoosePixelFormat;
        }

        var pixel_format_desc: win_nat.PIXELFORMATDESCRIPTOR = undefined;

        if (win_nat.DescribePixelFormat(device_context, pixel_format, @sizeOf(win_nat.PIXELFORMATDESCRIPTOR), &pixel_format_desc) == 0) {
            return error.CouldNotDescribePixelFormat;
        }

        if (win_nat.SetPixelFormat(device_context, pixel_format, &pixel_format_desc) == win_nat.FALSE) {
            return error.CouldNotSetPixelFormat;
        }

        const context_attribs = [_]c_int{
            win_nat.WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
            win_nat.WGL_CONTEXT_MINOR_VERSION_ARB, 5,
            win_nat.WGL_CONTEXT_PROFILE_MASK_ARB,  win_nat.WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
            0,
        };

        const context = wglCreateContextAttribsARB(device_context, null, &context_attribs) orelse {
            return error.CouldNotCreateContext;
        };

        return context;
    }

    pub fn display(window: Window) void {
        _ = win_nat.SwapBuffers(window.base.device_context);
    }
};
