const std = @import("std");

const clw_window = @import("clowder_window");

const win_nat = clw_window.native;

const Color = @import("../../Color.zig");
const nat = @import("../../native/opengl.zig");

const opengl = @import("../opengl.zig");

const Window = clw_window.Window(.win32);

pub const Error = Window.Error || error{
    CouldNotChoosePixelFormat,
    CouldNotDescribePixelFormat,
    CouldNotSetPixelFormat,
    CouldNotGetProcAddress,
    CouldNotFindExtension,
    CouldNotLoadExtension,
    CouldNotCreateContext,
    CouldNotMakeContextCurrent,
};

var wglChoosePixelFormatARB: nat.PFNWGLCHOOSEPIXELFORMATARBPROC = undefined;
var wglCreateContextAttribsARB: nat.PFNWGLCREATECONTEXTATTRIBSARBPROC = undefined;
var wglGetExtensionsStringARB: nat.PFNWGLGETEXTENSIONSSTRINGARBPROC = undefined;

pub const Base = struct {
    const Self = @This();

    context: win_nat.HGLRC,

    fn initExtensions() Error!void {
        const window = win_nat.CreateWindowExA(
            0,
            "STATIC",
            "Dummy Clowder Window",
            0,
            win_nat.CW_USEDEFAULT,
            win_nat.CW_USEDEFAULT,
            win_nat.CW_USEDEFAULT,
            win_nat.CW_USEDEFAULT,
            null,
            null,
            null,
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
            .dwFlags = win_nat.PFD_DRAW_TO_WINDOW | win_nat.PFD_SUPPORT_OPENGL | win_nat.PFD_DOUBLEBUFFER,
            .iPixelType = win_nat.PFD_TYPE_RGBA,
            .cColorBits = 24,
        });

        const pixel_format = win_nat.ChoosePixelFormat(device_context, &pixel_form_desc);

        if (pixel_format == 0) {
            return error.CouldNotChoosePixelFormat;
        }

        if (win_nat.DescribePixelFormat(device_context, pixel_format, @sizeOf(win_nat.PIXELFORMATDESCRIPTOR), &pixel_form_desc) == 0) {
            return error.CouldNotDescribePixelFormat;
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

        wglGetExtensionsStringARB = @as(nat.PFNWGLGETEXTENSIONSSTRINGARBPROC, @ptrCast(win_nat.wglGetProcAddress("wglGetExtensionsStringARB") orelse {
            return error.CouldNotGetProcAddress;
        }));

        const raw_extensions_string = wglGetExtensionsStringARB(device_context);

        const raw_extensions_string_len = blk: {
            var i: usize = 0;

            while (true) : (i += 1) {
                if (raw_extensions_string[i] == 0) {
                    break :blk i;
                }
            }
        };

        const extensions_string = raw_extensions_string[0..raw_extensions_string_len];

        if (!std.mem.containsAtLeast(u8, extensions_string, 1, "WGL_ARB_pixel_format") or
            !std.mem.containsAtLeast(u8, extensions_string, 1, "WGL_ARB_create_context"))
        {
            return error.CouldNotFindExtension;
        }

        wglChoosePixelFormatARB = @as(nat.PFNWGLCHOOSEPIXELFORMATARBPROC, @ptrCast(win_nat.wglGetProcAddress("wglChoosePixelFormatARB") orelse {
            return error.CouldNotLoadExtension;
        }));

        wglCreateContextAttribsARB = @as(nat.PFNWGLCREATECONTEXTATTRIBSARBPROC, @ptrCast(win_nat.wglGetProcAddress("wglCreateContextAttribsARB") orelse {
            return error.CouldNotLoadExtension;
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
            win_nat.WGL_COLOR_BITS_ARB,     24,
            win_nat.WGL_DEPTH_BITS_ARB,     24,
            win_nat.WGL_STENCIL_BITS_ARB,   8,
            0,
        };

        var pixel_formats: [1]c_int = undefined;
        var num_formats: win_nat.UINT = undefined;

        if (wglChoosePixelFormatARB(device_context, &pixel_format_attribs, null, 1, &pixel_formats, &num_formats) == win_nat.FALSE or num_formats == 0) {
            return error.CouldNotChoosePixelFormat;
        }

        var pixel_format_desc: win_nat.PIXELFORMATDESCRIPTOR = undefined;

        if (win_nat.DescribePixelFormat(device_context, pixel_formats[0], @sizeOf(win_nat.PIXELFORMATDESCRIPTOR), &pixel_format_desc) == 0) {
            return error.CouldNotDescribePixelFormat;
        }

        if (win_nat.SetPixelFormat(device_context, pixel_formats[0], &pixel_format_desc) == win_nat.FALSE) {
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

        if (win_nat.wglMakeCurrent(device_context, context) == win_nat.FALSE) {
            return error.CouldNotMakeContextCurrent;
        }

        return context;
    }

    pub fn init(window_context: Window.Context) Error!Self {
        return .{
            .context = try initContenxt(window_context.base.device_context),
        };
    }

    pub fn deinit(_: Self) void {}

    pub fn clear(color: Color) void {
        opengl.clear(color);
    }

    pub fn swap(window_context: Window.Context) void {
        _ = win_nat.SwapBuffers(window_context.base.device_context);
    }
};
