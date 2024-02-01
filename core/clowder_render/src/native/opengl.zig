const builtin = @import("builtin");

const cwl_window = @import("clowder_window");

const win_nat = cwl_window.native;

pub const GL_FALSE = 0;
pub const GL_TRUE = 1;

pub const GL_ARRAY_BUFFER = 0x8892;
pub const GL_COLOR_BUFFER_BIT = 0x0000_4000;
pub const GL_COMPILE_STATUS = 0x8B81;
pub const GL_CULL_FACE = 0x0B44;
pub const GL_DEPTH_BUFFER_BIT = 0x0000_0100;
pub const GL_DEPTH_TEST = 0x0B71;
pub const GL_ELEMENT_ARRAY_BUFFER = 0x8893;
pub const GL_FLOAT = 0x1406;
pub const GL_FRAGMENT_SHADER = 0x8B30;
pub const GL_INFO_LOG_LENGTH = 0x8B84;
pub const GL_LESS = 0x0201;
pub const GL_NEAREST = 0x2600;
pub const GL_REPEAT = 0x2901;
pub const GL_RENDERER = 0x1F01;
pub const GL_RGBA = 0x1908;
pub const GL_SHADING_LANGUAGE_VERSION = 0x8B8C;
pub const GL_STATIC_DRAW = 0x88E4;
pub const GL_STENCIL_BUFFER_BIT = 0x0000_0400;
pub const GL_TEXTURE_MAG_FILTER = 0x2800;
pub const GL_TEXTURE_MIN_FILTER = 0x2801;
pub const GL_TEXTURE_WRAP_S = 0x2802;
pub const GL_TEXTURE_WRAP_T = 0x2803;
pub const GL_TEXTURE0 = 0x84C0;
pub const GL_TEXTURE_2D = 0x0DE1;
pub const GL_TRIANGLES = 0x0004;
pub const GL_UNSIGNED_BYTE = 0x1401;
pub const GL_UNSIGNED_INT = 0x1405;
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

pub const PFNGLACTIVETEXTUREPROC = *const fn (texture: GLenum) callconv(.C) void;
pub const PFNGLATTACHSHADERPROC = *const fn (program: GLuint, shader: GLuint) callconv(.C) void;
pub const PFNGLBINDBUFFERPROC = *const fn (target: GLenum, buffer: GLuint) callconv(.C) void;
pub const PFNGLBINDTEXTUREPROC = *const fn (target: GLenum, texture: GLuint) callconv(.C) void;
pub const PFNGLBINDVERTEXARRAYPROC = *const fn (array: GLenum) void;
pub const PFNGLBUFFERDATAPROC = *const fn (target: GLenum, size: GLsizeiptr, data: *const anyopaque, usage: GLenum) callconv(.C) void;
pub const PFNGLCOMPILESHADERARBPROC = *const fn (shader: GLuint) callconv(.C) void;
pub const PFNGLCREATEPROGRAMPROC = *const fn () callconv(.C) GLuint;
pub const PFNGLCREATESHADERPROC = *const fn (shader_type: GLenum) callconv(.C) GLuint;
pub const PFNGLDELETESHADERPROC = *const fn (shader: GLuint) callconv(.C) void;
pub const PFNGLDISABLEPROC = *const fn (cap: GLenum) callconv(.C) void;
pub const PFNGLENABLEVERTEXATTRIBARRAYPROC = *const fn (index: GLuint) callconv(.C) void;
pub const PFNGLGENBUFFERSPROC = *const fn (n: GLsizei, buffers: [*]GLuint) callconv(.C) void;
pub const PFNGLGENTEXTURESPROC = *const fn (n: GLsizei, textures: [*]GLuint) callconv(.C) void;
pub const PFNGLGENVERTEXARRAYSPROC = *const fn (n: GLsizei, arrays: ?[*]GLuint) callconv(.C) void;
pub const PFNGLGETSHADERIVPROC = *const fn (shader: GLuint, pname: GLenum, params: ?*GLint) callconv(.C) void;
pub const PFNGLGETSHADERINFOLOGPROC = *const fn (shader: GLuint, max_length: GLsizei, length: *GLsizei, info_log: [*]GLchar) callconv(.C) void;
pub const PFNGLLINKPROGRAMPROC = *const fn (program: GLuint) callconv(.C) void;
pub const PFNGLSHADERSOURCEPROC = *const fn (shader: GLuint, count: GLsizei, string: *const [*]const GLchar, length: ?*const GLint) callconv(.C) void;
pub const PFNGLTEXIMAGE2DPROC = *const fn (target: GLenum, level: GLint, internalformat: GLint, width: GLsizei, height: GLsizei, border: GLint, format: GLenum, type: GLenum, pixels: ?*const anyopaque) callconv(.C) void;
pub const PFNGLTEXPARAMETERIPROC = *const fn (target: GLenum, pname: GLenum, param: GLint) callconv(.C) void;
pub const PFNGLUSEPROGRAMPROC = *const fn (program: GLuint) callconv(.C) void;
pub const PFNGLVALIDATEPROGRAMPROC = *const fn (program: GLuint) callconv(.C) void;
pub const PFNGLVERTEXATTRIBPOINTERPROC = *const fn (index: GLuint, size: GLint, type: GLenum, normalized: GLboolean, stride: GLsizei, pointer: ?*const anyopaque) callconv(.C) void;
pub const PFNGLVIEWPORTPROC = *const fn (x: GLint, y: GLint, width: GLsizei, height: GLsizei) callconv(.C) void;

pub const Loader = *const fn (name: ?[*:0]const u8) callconv(.C) ?*anyopaque;

pub extern fn glClear(mask: GLbitfield) void;
pub extern fn glClearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void;
pub extern fn glDepthFunc(func: GLenum) void;
pub extern fn glDrawArrays(mode: GLenum, first: GLint, count: GLsizei) void;
pub extern fn glDrawElements(mode: GLenum, count: GLsizei, type: GLenum, indices: ?*const anyopaque) void;
pub extern fn glEnable(cap: GLenum) void;
pub extern fn glEnableVertexArray(index: GLuint) void;
pub extern fn glGetError() GLenum;
pub extern fn glGetString(name: GLenum) ?[*:0]const GLubyte;

pub var glActiveTexture: PFNGLACTIVETEXTUREPROC = undefined;
pub var glAttachShader: PFNGLATTACHSHADERPROC = undefined;
pub var glBindBuffer: PFNGLBINDBUFFERPROC = undefined;
pub var glBindTexture: PFNGLBINDTEXTUREPROC = undefined;
pub var glBindVertexArray: PFNGLBINDVERTEXARRAYPROC = undefined;
pub var glBufferData: PFNGLBUFFERDATAPROC = undefined;
pub var glCompileShader: PFNGLCOMPILESHADERARBPROC = undefined;
pub var glCreateProgram: PFNGLCREATEPROGRAMPROC = undefined;
pub var glCreateShader: PFNGLCREATESHADERPROC = undefined;
pub var glDeleteShader: PFNGLDELETESHADERPROC = undefined;
pub var glDisable: PFNGLDISABLEPROC = undefined;
pub var glEnableVertexAttribArray: PFNGLENABLEVERTEXATTRIBARRAYPROC = undefined;
pub var glGenBuffers: PFNGLGENBUFFERSPROC = undefined;
pub var glGenTextures: PFNGLGENTEXTURESPROC = undefined;
pub var glGenVertexArrays: PFNGLGENVERTEXARRAYSPROC = undefined;
pub var glGetShaderiv: PFNGLGETSHADERIVPROC = undefined;
pub var glGetShaderInfoLog: PFNGLGETSHADERINFOLOGPROC = undefined;
pub var glLinkProgram: PFNGLLINKPROGRAMPROC = undefined;
pub var glShaderSource: PFNGLSHADERSOURCEPROC = undefined;
pub var glTexImage2D: PFNGLTEXIMAGE2DPROC = undefined;
pub var glTexParameteri: PFNGLTEXPARAMETERIPROC = undefined;
pub var glUseProgram: PFNGLUSEPROGRAMPROC = undefined;
pub var glValidateProgram: PFNGLVALIDATEPROGRAMPROC = undefined;
pub var glVertexAttribPointer: PFNGLVERTEXATTRIBPOINTERPROC = undefined;
pub var glViewport: PFNGLVIEWPORTPROC = undefined;

pub fn load(loader: Loader) void {
    glActiveTexture = @ptrCast(loader("glActiveTexture"));
    glAttachShader = @ptrCast(loader("glAttachShader"));
    glBindBuffer = @ptrCast(loader("glBindBuffer"));
    glBindVertexArray = @ptrCast(loader("glBindVertexArray"));
    glBufferData = @ptrCast(loader("glBufferData"));
    glCompileShader = @ptrCast(loader("glCompileShader"));
    glCreateProgram = @ptrCast(loader("glCreateProgram"));
    glCreateShader = @ptrCast(loader("glCreateShader"));
    glDeleteShader = @ptrCast(loader("glDeleteShader"));
    glEnableVertexAttribArray = @ptrCast(loader("glEnableVertexAttribArray"));
    glGenBuffers = @ptrCast(loader("glGenBuffers"));
    glGenTextures = @ptrCast(loader("glGenTextures"));
    glGenVertexArrays = @ptrCast(loader("glGenVertexArrays"));
    glGetShaderiv = @ptrCast(loader("glGetShaderiv"));
    glGetShaderInfoLog = @ptrCast(loader("glGetShaderInfoLog"));
    glLinkProgram = @ptrCast(loader("glLinkProgram"));
    glShaderSource = @ptrCast(loader("glShaderSource"));
    glUseProgram = @ptrCast(loader("glUseProgram"));
    glValidateProgram = @ptrCast(loader("glValidateProgram"));
    glVertexAttribPointer = @ptrCast(loader("glVertexAttribPointer"));

    switch (builtin.os.tag) {
        .windows => loadWin32(),
        else => {
            glDisable = @ptrCast(loader("glDisable"));
            glTexImage2D = @ptrCast(loader("glTexImage2D"));
            glTexParameteri = @ptrCast(loader("glTexParameteri"));
            glViewport = @ptrCast(loader("glViewport"));
        },
    }
}

pub fn loadWin32() void {
    const module = win_nat.LoadLibraryA("OpenGL32.dll");

    glDisable = @ptrCast(win_nat.GetProcAddress(module, "glDisable"));
    glTexImage2D = @ptrCast(win_nat.GetProcAddress(module, "glTexImage2D"));
    glTexParameteri = @ptrCast(win_nat.GetProcAddress(module, "glTexParameteri"));
    glViewport = @ptrCast(win_nat.GetProcAddress(module, "glViewport"));
}
