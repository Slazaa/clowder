# Clowder 🐱
> [!WARNING]
> This project is still in early developpment.

A simple, ECS based framework for graphical applications.

## Mindset 🧠
I want to keep Clowder simple, and I want the source code to be easy to read.
That's why I try to use a lot of comments. I also want to emphasize on the
use of examples, which I hope could be the main source of documentation.

I do not plan on adding a GUI for Clowder. I think it would go against that
simplicity and lightweight mindset.

## What's ECS ? 🤔
ECS is a way of writing your applications where entities are given components,
wich represent data. You can then apply logic to them through systems.

Let's see an example. I want a player that has health and that heals over time.
First, we will spawn a new entity that represents our player.

```zig
const player = app.spawn();
```

Then, we need to create our health component. Note that components are just
structs.

```zig
const Health = struct {
    max: u32,
    value: u32,
};
```

Now that we have our health component, we can add it to our player entity.

```zig
try app.addComponent(entity, Health{
    .max = 20,
    .value = 15,
});
```

Our player now has health, hurray! 🎉 We now need logic for entities that have
our health component. For that, we need to create a system.

```zig
fn healSystem(app: *clw.App) !void {
    // The query will give us all the entities that respect the predicate.
    // In our case, we're asking for all entities with a health component.
    var health_query = app.query(.{Health}, .{});

    // We can then iterate over our entities.
    while (health_query.next()) |entity| {
        // Here we get the health component of our entity.
        var health = app.getComponentPtr(entity, Health).?;
        health.value += 1;

        if (health.value > health.max) {
            health.value = health.max;
        }
    }
}
```

Finally, we can add our system to the app.

```zig
var app = try clw.init(allocator, .{
    // ...
    // Our system will be called each cycle.
    .systems = &.{healSystem},
});

defer app.deinit();

// Don't forget to run the app!
try app.run();
```

That's it! Now you know what ECS is.

## Examples 📝
All available examples are in the `examples` directory.

To run an example, you first need to clone the repo and you can then run it
by writting `zig build example-<example_name>`.For example,
`zig build example-triangle` will run the triangle example.

## Install ⚙️
You can install Clowder using the `zig fetch`.
```
zig fetch --save https://github.com/Slazaa/clowder/archive/<last-commit-hash>.tar.gz
```

And then import it in your project by adding this line in your `build.zig`.
```zig
_ = @import("clowder").link(b, exe);
```

## Support Me ❤️
This framework is open source and free to use. For that reason, donations would
be greatly appreciated. Thank you. ❤

My Patreon: https://www.patreon.com/Slazaa