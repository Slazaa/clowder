const cwl_window = @import("clowder_window");

const win_nat = cwl_window.native;

pub const GL_TRUE = 1;

pub const GL_COLOR_BUFFER_BIT = 0x0000_4000;
pub const GL_DEPTH_BUFFER_BIT = 0x0000_0100;

pub const GLfloat = f32;

pub const PFNWGLCHOOSEPIXELFORMATARBPROC = *const fn (hDC: win_nat.HDC, piAttribIList: [*c]const c_int, pfAttribFList: ?*const win_nat.FLOAT, nMaxFormats: win_nat.UINT, piFormats: ?*c_int, nNumFormats: ?*win_nat.UINT) win_nat.BOOL;
pub const PFNWGLCREATECONTEXTATTRIBSARBPROC = *const fn (hDC: win_nat.HDC, hShareContext: win_nat.HGLRC, attribList: [*c]const c_int) win_nat.HGLRC;

pub extern fn glClearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void;
