pub const Event = union(enum) {
    pub const KeyCode = enum {
        a,
        b,
        c,
        d,
        e,
        f,
        g,
        h,
        i,
        j,
        k,
        l,
        m,
        n,
        o,
        p,
        q,
        r,
        s,
        t,
        u,
        v,
        w,
        x,
        y,
        z,

        escape,
        space,
    };

    pub const KeyState = enum {
        down,
        released,
    };

    pub const Key = struct {
        code: KeyCode,
        state: KeyState,
        tick: u32 = 0,
    };

    close,
    key: Key,
};
