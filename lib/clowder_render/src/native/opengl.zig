const cwl_window = @import("clowder_window");

const win_nat = cwl_window.native;

pub const GL_FALSE = 0;
pub const GL_TRUE = 1;

pub const GL_ARRAY_BUFFER = 0x8892;
pub const GL_COLOR_BUFFER_BIT = 0x0000_4000;
pub const GL_COMPILE_STATUS = 0x8B81;
pub const GL_DEPTH_BUFFER_BIT = 0x0000_0100;
pub const GL_DEPTH_TEST = 0x0B71;
pub const GL_FLOAT = 0x1406;
pub const GL_FRAGMENT_SHADER = 0x8D30;
pub const GL_INFO_LOG_LENGTH = 0x8B84;
pub const GL_LESS = 0x0201;
pub const GL_RENDERER = 0x1F01;
pub const GL_SHADING_LANGUAGE_VERSION = 0x8B8C;
pub const GL_STATIC_DRAW = 0x88E4;
pub const GL_STENCIL_BUFFER_BIT = 0x0000_0400;
pub const GL_TRIANGLES = 0x0004;
pub const GL_VENDOR = 0x1F00;
pub const GL_VERSION = 0x1F02;
pub const GL_VERTEX_SHADER = 0x8B31;

pub const GLbitfield = c_int;
pub const GLboolean = u8;
pub const GLchar = c_char;
pub const GLenum = c_uint;
pub const GLfloat = f32;
pub const GLint = c_int;
pub const GLsizei = c_int;
pub const GLsizeiptr = isize;
pub const GLubyte = u8;
pub const GLuint = c_uint;

pub const PFNWGLCHOOSEPIXELFORMATARBPROC = *const fn (hDC: win_nat.HDC, piAttribIList: ?[*]const c_int, pfAttribFList: ?[*]const win_nat.FLOAT, nMaxFormats: win_nat.UINT, piFormats: ?[*]c_int, nNumFormats: ?*win_nat.UINT) callconv(.C) win_nat.BOOL;
pub const PFNWGLCREATECONTEXTATTRIBSARBPROC = *const fn (hDC: win_nat.HDC, hShareContext: win_nat.HGLRC, attribList: [*]const c_int) callconv(.C) win_nat.HGLRC;
pub const PFNWGLGETEXTENSIONSSTRINGARBPROC = *const fn (hDC: win_nat.HDC) callconv(.C) [*:0]const u8;

pub const PFNGLATTACHSHADERPROC = *const fn (program: GLuint, shader: GLuint) callconv(.C) void;
pub const PFNGLBINDVERTEXARRAYPROC = *const fn (array: GLenum) void;
pub const PFNGLCOMPILESHADERARBPROC = *const fn (shader: GLuint) callconv(.C) void;
pub const PFNGLCREATEPROGRAMPROC = *const fn () callconv(.C) GLuint;
pub const PFNGLCREATESHADERPROC = *const fn (shader_type: GLenum) callconv(.C) GLuint;
pub const PFNGLDELETESHADERPROC = *const fn (shader: GLuint) callconv(.C) void;
pub const PFNGLGETSHADERIVPROC = *const fn (shader: GLuint, pname: GLenum, params: ?*GLint) callconv(.C) void;
pub const PFNGLGETSHADERINFOLOGPROC = *const fn (shader: GLuint, max_length: GLsizei, length: *GLsizei, info_log: [*]GLchar) callconv(.C) void;
pub const PFNGLLINKPROGRAMPROC = *const fn (program: GLuint) callconv(.C) void;
pub const PFNGLSHADERSOURCEPROC = *const fn (shader: GLuint, count: GLsizei, string: *const [*]const GLchar, length: ?*const GLint) callconv(.C) void;
pub const PFNGLUSEPROGRAMPROC = *const fn (program: GLuint) callconv(.C) void;

pub const Loader = *const fn (name: ?[*:0]const u8) callconv(.C) ?*anyopaque;

pub extern fn glBindBuffer(target: GLenum, buffer: GLuint) void;
pub extern fn glBufferData(target: GLenum, size: GLsizeiptr, data: ?[*]const anyopaque, usage: GLenum) void;
pub extern fn glClear(mask: GLbitfield) void;
pub extern fn glClearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void;
pub extern fn glDepthFunc(func: GLenum) void;
pub extern fn glDrawArrays(mode: GLenum, first: GLint, count: GLsizei) void;
pub extern fn glEnable(cap: GLenum) void;
pub extern fn glEnableVertexArray(index: GLuint) void;
pub extern fn glEnableVertexAttribArray(index: GLuint) void;
pub extern fn glGenBuffers(n: GLsizei, buffer: ?[*]GLuint) void;
pub extern fn glGenVertexArrays(n: GLsizei, arrays: ?[*]GLuint) void;
pub extern fn glGetError() GLenum;
pub extern fn glGetString(name: GLenum) ?[*:0]const GLubyte;
pub extern fn glVertexAttribPointer(index: GLuint, size: GLint, type: GLenum, normalized: GLboolean, stride: GLsizei, pointer: ?[*]const anyopaque) void;

pub var glAttachShader: PFNGLATTACHSHADERPROC = undefined;
pub var glBindVertexArray: PFNGLBINDVERTEXARRAYPROC = undefined;
pub var glCompileShader: PFNGLCOMPILESHADERARBPROC = undefined;
pub var glCreateProgram: PFNGLCREATEPROGRAMPROC = undefined;
pub var glCreateShader: PFNGLCREATESHADERPROC = undefined;
pub var glDeleteShader: PFNGLDELETESHADERPROC = undefined;
pub var glGetShaderiv: PFNGLGETSHADERIVPROC = undefined;
pub var glGetShaderInfoLog: PFNGLGETSHADERINFOLOGPROC = undefined;
pub var glLinkProgram: PFNGLLINKPROGRAMPROC = undefined;
pub var glShaderSource: PFNGLSHADERSOURCEPROC = undefined;
pub var glUseProgram: PFNGLUSEPROGRAMPROC = undefined;

pub fn load(loader: Loader) void {
    glAttachShader = @ptrCast(loader("glAttachShader"));
    glBindVertexArray = @ptrCast(loader("glBindVertexArray"));
    glCompileShader = @ptrCast(loader("glCompileShader"));
    glCreateProgram = @ptrCast(loader("glCreateProgram"));
    glCreateShader = @ptrCast(loader("glCreateShader"));
    glDeleteShader = @ptrCast(loader("glDeleteShader"));
    glGetShaderiv = @ptrCast(loader("glGetShaderiv"));
    glGetShaderInfoLog = @ptrCast(loader("glGetShaderInfoLog"));
    glLinkProgram = @ptrCast(loader("glLinkProgram"));
    glShaderSource = @ptrCast(loader("glShaderSource"));
    glUseProgram = @ptrCast(loader("glUseProgram"));
}
