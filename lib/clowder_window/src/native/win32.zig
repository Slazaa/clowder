const builtin = @import("builtin");

pub fn MAKEINTRESOURCEA(i: anytype) LPSTR {
    return @ptrFromInt(i);
}

pub const FALSE = 0;
pub const TRUE = 1;

pub const CS_HREDRAW = 0x0002;
pub const CS_OWNDC = 0x0020;
pub const CS_VREDRAW = 0x0001;

pub const CW_USEDEFAULT = -0x8000_0000;

pub const IDC_ARROW = MAKEINTRESOURCEA(32512);

pub const PFD_DOUBLEBUFFER = 0x0000_0001;
pub const PFD_DRAW_TO_WINDOW = 0x0000_0004;
pub const PFD_SUPPORT_OPENGL = 0x0000_0020;
pub const PFD_TYPE_RGBA = 0;

pub const PM_REMOVE = 0x0001;

pub const SM_CXSCREEN = 0;
pub const SM_CYSCREEN = 1;

pub const SW_SHOW = 5;

pub const WGL_ACCELERATION_ARB = 0x2003;
pub const WGL_COLOR_BITS_ARB = 0x2014;
pub const WGL_CONTEXT_CORE_PROFILE_BIT_ARB = 0x00000001;
pub const WGL_CONTEXT_MAJOR_VERSION_ARB = 0x2091;
pub const WGL_CONTEXT_MINOR_VERSION_ARB = 0x2092;
pub const WGL_CONTEXT_PROFILE_MASK_ARB = 0x9126;
pub const WGL_DEPTH_BITS_ARB = 0x2022;
pub const WGL_DOUBLE_BUFFER_ARB = 0x2011;
pub const WGL_DRAW_TO_WINDOW_ARB = 0x2001;
pub const WGL_FULL_ACCELERATION_ARB = 0x2027;
pub const WGL_PIXEL_TYPE_ARB = 0x2013;
pub const WGL_RED_BITS_ARB = 0x2015;
pub const WGL_STENCIL_BITS_ARB = 0x2023;
pub const WGL_SUPPORT_OPENGL_ARB = 0x2010;
pub const WGL_TYPE_RGBA_ARB = 0x202B;

pub const WM_QUIT = 0x0012;

pub const WS_CAPTION = 0x000C_0000;
pub const WS_MAXIMIZEBOX = 0x0001_0000;
pub const WS_MINIMIZEBOX = 0x0002_0000;
pub const WS_OVERLAPPED = 0x0000_0000;
pub const WS_OVERLAPPEDWINDOW = WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX;
pub const WS_SYSMENU = 0x0008_0000;
pub const WS_THICKFRAME = 0x0004_0000;

pub const ATOM = WORD;
pub const BOOL = c_int;
pub const BYTE = u8;
pub const DWORD = c_ulong;
pub const FLOAT = f32;
pub const HANDLE = PVOID;
pub const HBRUSH = HANDLE;
pub const HCURSOR = HICON;
pub const HDC = HANDLE;
pub const HGLRC = HANDLE;
pub const HICON = HANDLE;
pub const HINSTANCE = HANDLE;
pub const HMENU = HANDLE;
pub const HMODULE = HINSTANCE;
pub const HWND = HANDLE;

pub const INT_PTR = switch (builtin.cpu.arch) {
    .x86_64 => i64,
    else => c_int,
};

pub const LONG = c_long;

pub const LONG_PTR = switch (builtin.cpu.arch) {
    .x86_64 => i64,
    else => c_long,
};

pub const LPARAM = LONG_PTR;
pub const LPCSTR = ?[*:0]const u8;
pub const LPSTR = ?[*:0]u8;
pub const LPVOID = ?*anyopaque;
pub const LRESULT = LONG_PTR;
pub const PROC = ?*const fn (...) callconv(.C) INT_PTR;
pub const PVOID = ?*anyopaque;
pub const UINT = c_uint;

pub const UINT_PTR = switch (builtin.cpu.arch) {
    .x86_64 => u64,
    else => c_uint,
};

pub const WNDPROC = ?*const fn (HWND, UINT, WPARAM, LPARAM) callconv(.C) LRESULT;
pub const WORD = c_ushort;
pub const WPARAM = UINT_PTR;

pub const struct_tagMSG = extern struct {
    hWnd: HWND,
    message: UINT,
    wParam: WPARAM,
    lParam: LPARAM,
    time: DWORD,
    pt: POINT,
    lPrivate: DWORD,
};

pub const MSG = struct_tagMSG;
pub const PMSG = *struct_tagMSG;
pub const NPMSG = *struct_tagMSG;
pub const LPMSG = *struct_tagMSG;

pub const struct_tagPIXELFORMATDESCRIPTOR = extern struct {
    nSize: WORD,
    nVersion: WORD,
    dwFlags: DWORD,
    iPixelType: BYTE,
    cColorBits: BYTE,
    cRedBits: BYTE,
    cRedShift: BYTE,
    cGreenBits: BYTE,
    cGreenShift: BYTE,
    cBlueBits: BYTE,
    cBlueShift: BYTE,
    cAlphaBits: BYTE,
    cAlphaShift: BYTE,
    cAccumBits: BYTE,
    cAccumRedBits: BYTE,
    cAccumGreenBits: BYTE,
    cAccumBlueBits: BYTE,
    cAccumAlphaBits: BYTE,
    cDepthBits: BYTE,
    cStencilBits: BYTE,
    cAuxBuffers: BYTE,
    iLayerType: BYTE,
    bReserved: BYTE,
    dwLayerMask: DWORD,
    dwVisibleMask: DWORD,
    dwDamageMask: DWORD,
};

pub const PIXELFORMATDESCRIPTOR = struct_tagPIXELFORMATDESCRIPTOR;
pub const PPIXELFORMATDESCRIPTOR = *struct_tagPIXELFORMATDESCRIPTOR;
pub const LPPIXELFORMATDESCRIPTOR = *struct_tagPIXELFORMATDESCRIPTOR;

pub const struct_tagPOINT = extern struct {
    x: LONG,
    y: LONG,
};

pub const POINT = struct_tagPOINT;
pub const PPOINT = *struct_tagPOINT;
pub const NPPOINT = *struct_tagPOINT;
pub const LPPOINT = *struct_tagPOINT;

pub const struct_tagWNDCLASSA = extern struct {
    style: UINT,
    lpfnWndProc: WNDPROC,
    cbClsExtra: c_int,
    cbWndExtra: c_int,
    hInstance: HINSTANCE,
    hIcon: HICON,
    hCursor: HCURSOR,
    hbrBackground: HBRUSH,
    lpszMenuName: LPCSTR,
    lpszClassName: LPCSTR,
};

pub const WNDCLASSA = struct_tagWNDCLASSA;
pub const PWNDCLASSA = *struct_tagWNDCLASSA;
pub const NPWNDCLASSA = *struct_tagWNDCLASSA;
pub const LPWNDCLASSA = *struct_tagWNDCLASSA;

pub const WM_CLOSE = 0x0010;

pub extern fn ChoosePixelFormat(hdc: HDC, ppfd: ?*const PIXELFORMATDESCRIPTOR) c_int;
pub extern fn CreateWindowExA(dwExStyle: DWORD, lpClassName: LPCSTR, lpWindowName: LPCSTR, dwStyle: DWORD, X: c_int, Y: c_int, nWidth: c_int, nHeight: c_int, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID) HWND;
pub extern fn DefWindowProcA(hWnd: HWND, Msg: UINT, wParam: WPARAM, lParam: LPARAM) LRESULT;
pub extern fn DescribePixelFormat(hdc: HDC, iPixelFormat: c_int, nBytes: UINT, ppfd: LPPIXELFORMATDESCRIPTOR) c_int;
pub extern fn DestroyWindow(hWnd: HWND) BOOL;
pub extern fn DispatchMessageA(lpMsg: ?*const MSG) LRESULT;
pub extern fn GetDC(hWnd: HWND) HDC;
pub extern fn GetLastError() DWORD;
pub extern fn GetModuleHandleA(lpModuleName: LPCSTR) HMODULE;
pub extern fn GetSystemMetrics(nIndex: c_int) c_int;
pub extern fn LoadCursorA(hInstance: HINSTANCE, lpCursorName: LPCSTR) HCURSOR;
pub extern fn PeekMessageA(lpMsg: LPMSG, hWnd: HWND, wMsgFilterMin: UINT, wMsgFilterMax: UINT, wRemoveMsg: UINT) BOOL;
pub extern fn PostQuitMessage(nExitCode: c_int) void;
pub extern fn RegisterClassA(lpWndClass: ?*const WNDCLASSA) ATOM;
pub extern fn ReleaseDC(hWnd: HWND, hDC: HDC) c_int;
pub extern fn SetPixelFormat(hdc: HDC, format: c_int, ppfd: ?*const PIXELFORMATDESCRIPTOR) BOOL;
pub extern fn ShowWindow(hWnd: HWND, nCmdShow: c_int) BOOL;
pub extern fn SwapBuffers(HDC) BOOL;
pub extern fn TranslateMessage(lpMsg: ?*const MSG) BOOL;
pub extern fn UpdateWindow(hWnd: HWND) BOOL;

pub extern fn wglCreateContext(HDC) HGLRC;
pub extern fn wglDeleteContext(HGLRC) BOOL;
pub extern fn wglGetProcAddress(LPCSTR) PROC;
pub extern fn wglMakeCurrent(HDC, HGLRC) BOOL;
