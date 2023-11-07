const c = @import("../../c.zig");

const cwl_window = @import("clowder_window");

const Window = cwl_window.Window;

const WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
const WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
const WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;

const WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;

const WGL_DRAW_TO_WINDOW_ARB = 0x2001;
const WGL_ACCELERATION_ARB = 0x2003;
const WGL_SUPPORT_OPENGL_ARB = 0x2010;
const WGL_DOUBLE_BUFFER_ARB = 0x2011;
const WGL_PIXEL_TYPE_ARB = 0x2013;
const WGL_COLOR_BITS_ARB = 0x2014;
const WGL_DEPTH_BITS_ARB = 0x2022;
const WGL_STENCIL_BITS_ARB = 0x2023;

const WGL_FULL_ACCELERATION_ARB = 0x2027;
const WGL_TYPE_RGBA_ARB = 0x202B;

const PFNWGLCHOOSEPIXELFORMATARBPROC = *const fn (c.HDC, [*c]const c_int, ?*c.FLOAT, c.UINT, ?*c_int, ?*c.UINT) callconv(.C) c.BOOL;
const PFNWGLCREATECONTEXTATTRIBSARBPROC = *const fn (c.HDC, c.HGLRC, [*c]const c_int) callconv(.C) c.HGLRC;

pub const Error = Window.Error || error{
    CouldNotChoosePixelFormat,
    CouldNotFindPixelFormat,
    CouldNotSetPixelFormat,
    CouldNotGetProcAddres,
    CouldNotCreateContext,
    CouldNotMakeContextCurrent,
};

var wglChoosePixelFormatARB: PFNWGLCHOOSEPIXELFORMATARBPROC = undefined;
var wglCreateContextAttribsARB: PFNWGLCREATECONTEXTATTRIBSARBPROC = undefined;

pub const Base = struct {
    const Self = @This();

    context: c.HGLRC,

    pub fn init(window: Window) Error!Self {
        return .{
            .context = try initContenxt(window.base.device_context),
        };
    }

    fn initExtensions() Error!void {
        const instance = c.GetModuleHandleA(null) orelse {
            return error.CouldNotGetInstance;
        };

        const window_class = c.WNDCLASS{
            .style = c.CS_HREDRAW | c.CS_VREDRAW | c.CS_OWNDC,
            .lpfnWndProc = c.DefWindowProcA,
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

        if (c.wglMakeCurrent(device_context, context) == c.FALSE) {
            return error.CouldNotMakeContextCurrent;
        }

        wglChoosePixelFormatARB = @as(PFNWGLCHOOSEPIXELFORMATARBPROC, @ptrCast(c.wglGetProcAddress("wglChoosePixelFormatARB") orelse {
            return error.CouldNotGetProcAddres;
        }));

        wglCreateContextAttribsARB = @as(PFNWGLCREATECONTEXTATTRIBSARBPROC, @ptrCast(c.wglGetProcAddress("wglCreateContextAttribsARB") orelse {
            return error.CouldNotGetProcAddres;
        }));

        _ = c.wglMakeCurrent(device_context, null);
        _ = c.wglDeleteContext(context);
        _ = c.ReleaseDC(window, device_context);
        _ = c.DestroyWindow(window);
    }

    fn initContenxt(device_context: c.HDC) Error!c.HGLRC {
        try initExtensions();

        const pixel_format_attribs = [_]c_int{
            WGL_DRAW_TO_WINDOW_ARB, c.GL_TRUE,
            WGL_SUPPORT_OPENGL_ARB, c.GL_TRUE,
            WGL_DOUBLE_BUFFER_ARB,  c.GL_TRUE,
            WGL_ACCELERATION_ARB,   WGL_FULL_ACCELERATION_ARB,
            WGL_PIXEL_TYPE_ARB,     WGL_TYPE_RGBA_ARB,
            WGL_COLOR_BITS_ARB,     32,
            WGL_DEPTH_BITS_ARB,     24,
            WGL_STENCIL_BITS_ARB,   8,
            0,
        };

        var pixel_format: c_int = undefined;
        var num_formats: c.UINT = undefined;

        _ = wglChoosePixelFormatARB(device_context, &pixel_format_attribs, null, 1, &pixel_format, &num_formats);

        if (num_formats == 0) {
            return error.CouldNotChoosePixelFormat;
        }

        var pixel_format_desc: c.PIXELFORMATDESCRIPTOR = undefined;

        _ = c.DescribePixelFormat(device_context, pixel_format, @sizeOf(c.PIXELFORMATDESCRIPTOR), &pixel_format_desc);

        if (c.SetPixelFormat(device_context, pixel_format, &pixel_format_desc) == 0) {
            return error.CouldNotSetPixelFormat;
        }

        const context_attribs = [_]c_int{
            WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
            WGL_CONTEXT_MINOR_VERSION_ARB, 5,
            WGL_CONTEXT_PROFILE_MASK_ARB,  WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
            0,
        };

        const context = wglCreateContextAttribsARB(device_context, 0, &context_attribs) orelse {
            return error.CouldNotCreateContext;
        };

        return context;
    }

    pub fn display(window: Window) void {
        _ = c.SwapBuffers(window.base.device_context);
    }
};
