pub const ContextError = error{};

pub const ContextBase = struct {
    const Self = @This();

    pub fn init() ContextError!Self {}
};
