Shaders are structured in a specific way:
a `<shader>.lua` file to manage the code and needed variables
a `<shader>` folder containing the `.vert` and `.frag`


Shaders are prepared by
``` lua
    <shader> = require "<shader>"
```

The shader object is expected to have some functions:
 - `:init()` that prepares internal values and systems. To be called in `load`
 - `:update(values)` updates any relevant internal values. To be called on `draw` or `update`
 - `:load(pass)` load the shader and relevant constants and values. To be called in `draw` 

