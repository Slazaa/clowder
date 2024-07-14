pub const Colormap = ID;
pub const Display = opaque {};
pub const GC = ?*opaque {};
pub const VisualID = c_ulong;
pub const Window = ID;
pub const ID = c_ulong;
pub const Pointer = ?[*]u8;

pub const Depth = extern struct {
    depth: c_int,
    nvisuals: c_int,
    visuals: ?[*]Visual,
};

pub const ExtData = extern struct {
    number: c_int,
    next: ?[*]ExtData,
    free_private: ?*const fn (?[*]ExtData) c_int,
    private_data: Pointer,
};

pub const Screen = extern struct {
    ext_data: ?[*]ExtData,
    display: ?*Display,
    root: Window,
    width: c_int,
    height: c_int,
    mwidth: c_int,
    mheight: c_int,
    ndepths: c_int,
    depths: ?[*]Depth,
    root_depth: c_int,
    root_visual: ?[*]Visual,
    default_gc: GC,
    cmap: Colormap,
    white_pixel: c_ulong,
    black_pixel: c_ulong,
    max_maps: c_int,
    min_maps: c_int,
    backing_store: c_int,
    save_unders: c_int,
    root_input_mask: c_long,
};

pub const Visual = extern struct {
    ext_data: ?[*]ExtData,
    visualid: VisualID,
    class: c_int,
    red_mask: c_ulong,
    green_mask: c_ulong,
    blue_mask: c_ulong,
    bits_per_rgb: c_int,
    map_entries: c_int,
};

pub const WindowAttributes = extern struct {
    x: c_int,
    y: c_int,
    width: c_int,
    height: c_int,
    border_width: c_int,
    depth: c_int,
    visual: ?[*]Visual,
    root: Window,
    class: c_int,
    bit_gravity: c_int,
    win_gravity: c_int,
    backing_store: c_int,
    backing_planes: c_ulong,
    backing_pixel: c_ulong,
    save_under: c_int,
    colormap: Colormap,
    map_installed: c_int,
    map_state: c_int,
    all_event_masks: c_long,
    your_event_mask: c_long,
    do_not_propagate_mask: c_long,
    override_redirect: c_int,
    screen: ?[*]Screen,
};

pub extern fn XBlackPixel(display: ?*Display, screen_number: c_int) c_ulong;
pub extern fn XCloseDisplay(display: ?*Display) c_int;
pub extern fn XCreateSimpleWindow(display: ?*Display, parent: Window, x: c_int, y: c_int, width: c_uint, height: c_uint, border_width: c_uint, border: c_ulong, background: c_ulong) Window;
pub extern fn XDefaultScreen(display: ?*Display) c_int;
pub extern fn XDestroyWindow(display: ?*Display, window: Window) c_int;
pub extern fn XDefaultRootWindow(display: ?*Display) Window;
pub extern fn XGetWindowAttributes(display: ?*Display, window: Window, window_attributes_return: *WindowAttributes) c_int;
pub extern fn XHeightOfScreen(screen: Screen) c_int;
pub extern fn XMapWindow(display: ?*Display, window: Window) c_int;
pub extern fn XOpenDisplay(dispaly_name: ?[*]const u8) ?*Display;
pub extern fn XScreenOfDisplay(display: ?*Display, screen_number: c_int) ?[*]Screen;
pub extern fn XSelectInput(display: ?*Display, window: Window, event_mask: c_long) c_int;
pub extern fn XStoreName(displat: ?*Display, window: Window, name: ?[*]const u8) c_int;
pub extern fn XWhitePixel(display: ?*Display, screen_number: c_int) c_ulong;
pub extern fn XWidthOfScreen(screen: Screen) c_int;

pub const NoEventMask = 0;
pub const KeyPressMask = 1 << 0;
pub const KeyReleaseMask = 1 << 1;
pub const ButtonPressMask = 1 << 2;
pub const ButtonReleaseMask = 1 << 3;
pub const EnterWindowMask = 1 << 4;
pub const LeaveWindowMask = 1 << 5;
pub const PointerMotionMask = 1 << 6;
pub const PointerMotionHintMask = 1 << 7;
pub const Button1MotionMask = 1 << 8;
pub const Button2MotionMask = 1 << 9;
pub const Button3MotionMask = 1 << 10;
pub const Button4MotionMask = 1 << 11;
pub const Button5MotionMask = 1 << 12;
pub const ButtonMotionMask = 1 << 13;
pub const KeymapStateMask = 1 << 14;
pub const ExposureMask = 1 << 15;
pub const VisibilityChangeMask = 1 << 16;
pub const StructureNotifyMask = 1 << 17;
pub const ResizeRedirectMask = 1 << 18;
pub const SubstructureNotifyMask = 1 << 19;
pub const SubstructureRedirectMask = 1 << 20;
pub const FocusChangeMask = 1 << 21;
pub const PropertyChangeMask = 1 << 22;
pub const ColormapChangeMask = 1 << 23;
pub const OwnerGrabButtonMask = 1 << 24;
