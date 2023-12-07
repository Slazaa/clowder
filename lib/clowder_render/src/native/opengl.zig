const cwl_window = @import("clowder_window");

const win_nat = cwl_window.native;

pub const GL_TRUE = 1;

pub const GL_COLOR_BUFFER_BIT = 0x0000_4000;
pub const GL_DEPTH_BUFFER_BIT = 0x0000_0100;
pub const GL_RENDERER = 0x1F01;
pub const GL_SHADING_LANGUAGE_VERSION = 0x8B8C;
pub const GL_STENCIL_BUFFER_BIT = 0x0000_0400;
pub const GL_VENDOR = 0x1F00;
pub const GL_VERSION = 0x1F02;

pub const GLbitfield = c_int;
pub const GLenum = c_uint;
pub const GLfloat = f32;
pub const GLubyte = u8;

pub const PFNWGLCHOOSEPIXELFORMATARBPROC = *const fn (hDC: win_nat.HDC, piAttribIList: ?[*]const c_int, pfAttribFList: ?[*]const win_nat.FLOAT, nMaxFormats: win_nat.UINT, piFormats: ?[*]c_int, nNumFormats: ?*win_nat.UINT) callconv(.C) win_nat.BOOL;
pub const PFNWGLCREATECONTEXTATTRIBSARBPROC = *const fn (hDC: win_nat.HDC, hShareContext: win_nat.HGLRC, attribList: [*]const c_int) callconv(.C) win_nat.HGLRC;
pub const PFNWGLGETEXTENSIONSSTRINGARBPROC = *const fn (hDC: win_nat.HDC) callconv(.C) [*:0]const u8;

pub extern fn glClear(mask: GLbitfield) void;
pub extern fn glClearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void;
pub extern fn glGetError() GLenum;
pub extern fn glGetString(name: GLenum) ?[*:0]const GLubyte;
