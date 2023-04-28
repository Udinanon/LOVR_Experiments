# Notes

## Links

### LOVR
[Official Docs](https://lovr.org/docs/Getting_Started)
[LOVR GitHub](https://github.com/bjornbytes/lovr)
[LOVR Slack](https://app.slack.com/client/T59PJ1KCJ/C59QZ4V6Y)

## ADB
More info about ADB can be found at:
 - [Official ADB Docs](https://developer.android.com/studio/command-line/adb)
 - [ADB Cheat Sheet](https://www.automatetheplanet.com/wp-content/uploads/2019/08/Cheat_sheet_ADB.pdf)
 - [Oculus ADB Docs](https://developer.oculus.com/documentation/native/android/ts-adb/)
### Useful Commands
To identify all connected devices use 

    adb devices -l 

To go wireless:
connect via USB, give permission and give ADB permission

    $ adb tcpip 5555
    restarting in TCP mode port: 5555
    $ adb connect <ip>:5555
    connected to 192.168.1.193:5555


To update the code use

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.app/files

or for LODR

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.hotswap/files/.lodr


If your program contains print statements, you can view them with:

    adb logcat | grep -i lovr

or even better 
    
    adb logcat -s LOVR


To list all files in a folder use

    adb shell ls <folder>
like

    adb shell ls /sdcard/Android/data/org.lovr.hotswap/files/.lodr


To get a remote screenshot use

    adb exec-out screencap -p > Screenshots/screen_$(date +'%Y-%m-%d-%X').png


From [here](https://android.stackexchange.com/questions/7686/is-there-a-way-to-see-the-devices-screen-live-on-pc-through-adb/154328#154328) we get an ADB command to get a fluid, although delayed, video stream

    adb exec-out screenrecord --output-format=h264 - |   ffplay -framerate 60 -probesize 32 -sync video  -


we can launch any app via ADB, with

    adb shell monkey -p  <Package name> 1
with LODR being `org.lovr.hotswap` and LOVR being `org.lovr.app`


### Performance 
we can access the VrApi via ADB using 

    adb logcat -s VrApi
which we can use to read various data points on the state of the device

https://developer.oculus.com/documentation/native/android/po-per-frame-gpu/

https://developer.oculus.com/documentation/native/android/ts-logcat-stats/


We can also read GPU performance details using

    adb shell ovrgpuprofiler -m

https://developer.oculus.com/documentation/native/android/ts-ovrgpuprofiler/


performance profiling might want to keep in mind that the CPU and GPU of Oculus devices dynamically handle the workload

https://developer.oculus.com/documentation/native/android/mobile-power-overview/


OVRMetrics is also a powerful tool to access real-time performance information while inside the device, using an overlay or reporting results to CSV. 
It can be accessed via the Unknown Resources panel or via some ADB commands 

https://developer.oculus.com/documentation/native/android/ts-ovrmetricstool/

https://developer.oculus.com/documentation/native/android/ts-ovr-best-practices/


There are even more methods and tools to track real time performance

https://developer.oculus.com/documentation/native/android/po-book-performance/

## Controller

No support is available on Android right now. Only on Windows through the lovr-joystick library

## LOVR and LODR
These two versions are basically the same, with LODR being an official fork with hot swapping support, making for an even faster development cycle. No need to restart LOVR, LODR detects that the project files changed and restart automatically. 

Or you can just add the restart to your ADB command


## Math
Quaternions are used for rotation systems in LOVR.

They represent rotations, so they have also an axis of rotation 
you can also multiply a 3d vector by them and rotate it, if you multiply a coordinate vector you get that vector rotated by that quaternion, or inversely that direction in the coordinate system define by the quaternion.

Mat4 for rototranslations are "column-major 4x4 homogeneous transformation matrices"

### Mat4

Since v0.16, most operations and shapes are now focused more on using Matrices.
These can be scary at first, but are a great way to handle all geometric elaborations together instead of splitting them into different pieces and having to combine everything at the end

Matrices can store position, rotation and scaling all together.

These values can be set at initialization, but can also be set later.

Direction is set via `:translate()`, using raw values or a `vec3`

Scale is set using `:scale()`

Rotation is set using `:rotate()`, but here understanding how to use quaternions can make this much more useful

#### Quats and Mat4s

Quaternions can be used to rotate an element around an axis, arbitrarily. These rotations can also be chained to do come complex movements and rotations.

But to set the orientation of an object to a specific direction, this can become cumbersome, and even a simple approach requires a cross product and some 3D geometry

but if we have an idea of what direction we want the object to face, and we're starting from the object with rotation (0, 0, 0, 0), we can just use `:rotate(quat(desired_direction_vec3))` and the object will be facing the desired direction, barring rotation around the axis

This operation works only if the object has not been rotated yet, or the combined result will be hard to predict

#### Mat4

Mat4 should be conceptualized as not positions or rotations, but full reference frames. These can be moved, rotated and scaled, and these operations are applied sequentially, every time to the next version of the reference frame, so they are not order independent.  

## Graphics
rendering textures on 2d objects needs shaders, which is shit
BUT we can use canvases to generate the textures, apply the canvas to a Material, and then we don't need them!
Better

printing single color blobs didn0t work, maybe writing them to disk will be better
this can be done with
```lua
    lovr.filesystem.write("whatever.txt", blob)
```
and then 
```bash
    adb pull /sdcard/Android/data/org.lovr.hotswap/files/whatever.txt
```
`local points = lovr.headset.getBoundsGeometry()` returns an ungodly number of points

the standard shader admits only one light source

## Shaders

Shaders are a complex topic, fundamental for 3D rendering, and can also be used for parallel high performance computations

The system uses a `shader = lovr.graphics.newShader([[]],[[]])` function that reads raw GLSL and compiles a shader
this can then be loaded by `lovr.graphics.setShader(shader)`
These shaders will dictate the properties and color of pixels rendered

all shaders can access `uniform <type> <name>` values, given by LOVR with `shader:send(<name>, <value>)`

shaders can also use ShaderBlocks to pass back and forth more types of data, including arrays 
the code here is more complex, so make reference to the [New Shader Block Docs](https://lovr.org/docs/v0.15.0/lovr.graphics.newShaderBlock) and [Shader Block Docs](https://lovr.org/docs/v0.15.0/ShaderBlock)
According to the Devs, Mat4 and Vec3 are different to other data types and so some need to be unpacked and some don't

The shader can also be used on the entire eye image by more complex usage of canvases

Shaders can (and probably should) be loaded from files


### Vertex
This component of the Shader pipeline processes the 3D properties of the scene, applying perspectives and manipulations, cpmputing directions, moving vertices and more.
It has access to many infomration about vertices and materials, normals and projection matrices

The default is 
```glsl
    vec4 lovrmain() {
        return Projection * View * Transform * VertexPosition;
    }
```

Values can be exfiltrated to the Fragment shader by declaring a `out <type> <name>` variable and defining them in the shader code

The available internal values can be read at https://lovr.org/docs/Shaders

### Fragment
The fragment shader renders the pixel itself, getting the input from the Geometry Shader and computing from that, textures, diffuse and emissive textures, and other factors the color of the pixel

this is the default fragment shader
```glsl
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
  return graphicsColor * lovrDiffuseColor * lovrVertexColor * texture(image, uv);
}
```
with `uv` being the 2D coords of the face being rendered, normalized in a [0.0 1.0] range

the standard header is 
```glsl
in vec2 lovrTexCoord;
in vec4 lovrVertexColor;
in vec4 lovrGraphicsColor;
out vec4 lovrCanvas[gl_MaxDrawBuffers];
uniform float lovrMetalness;
uniform float lovrRoughness;
uniform vec4 lovrDiffuseColor;
uniform vec4 lovrEmissiveColor;
uniform sampler2D lovrDiffuseTexture;
uniform sampler2D lovrEmissiveTexture;
uniform sampler2D lovrMetalnessTexture;
uniform sampler2D lovrRoughnessTexture;
uniform sampler2D lovrOcclusionTexture;
uniform sampler2D lovrNormalTexture;
uniform samplerCube lovrEnvironmentTexture;
uniform int lovrViewportCount;
uniform int lovrViewID;
```

we can access shared values from the Vertex Shader with `in <type> <name>`


### 3D Shaders
So shaders that fully cover the rendering process, not passing by the normal lovr.graphics code but do the entire work themselves

To achieve this we need the shader to fully cover the user UI and eyes.
This is achieved by:
1. define a vertex shader with `return vertex` so that geometry transformation is applied
2. render the scene in the fragment shader, passing info from the vertex if needed
3. in lovr, activate the shader 
4. run `lovr.graphics.fill()` 
5. remove the shader

We probably also want the exact direction and position of the pixels we'll be filling in, for that:
``` glsl
out vec3 pos;
out vec3 dir;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
  vec4 ray = vec4(lovrTexCoord * 2. - 1., -1., 1.);
  pos = -lovrView[3].xyz * mat3(lovrView);
  dir = transpose(mat3(lovrView)) * (inverse(lovrProjection) * ray).xyz;
  return vertex;
}
```
Passes both values to the fragment shader from the vertex one.
[Code source](https://ifyouwannabemylovr.slack.com/archives/C59QZ4V6Y/p1659160201503029)

This allows us to do custom rendering techniques like 

#### Ray Marching 
A rendering technique that marches rays from the pixels inside the scene.
Useful for some effects seen in some videos like 
 - [Ray Marching for Dummies!](https://www.youtube.com/watch?v=PGtv-dBi2wE)
 - [Coding Adventure: Ray Marching](https://www.youtube.com/watch?v=Cp5WWtMoeKg)
 - [How to Make 3D Fractals](https://www.youtube.com/watch?v=svLzmFuSBhk)
 - [Ray marching In a nutshell - Signed Distance Function](https://www.youtube.com/watch?v=SdNb7-I1TtA)

These include 3D fractals and some other cool stuff

The merger sponge was very inefficient due to inefficiencies and not using the recursive space.
This means that more efficient fractals are perfectly possible, we just need to use a better method

Watching the code generated by PySpace, the idea is great, you can generate the needed GLSL code on the fly with Python, but the results are not fast enough on my laptop and I think the same will happen on the Headset, the code has options to be rendered not in live to make videos, so that's probably how he made the videos. Or maybe using a powerful GPU it could be done?

Union: min(a, b)
Intersect: max(a, b)
Difference: max(a, -b)

some codes for simple geometries can be found at 
 - https://www.shadertoy.com/view/wdf3zl
 - http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/
 - https://iquilezles.org/articles/
### Compute

Extremely useful to execute highly parallel computations on the GPU

They do not share many of the characteristics of Vertex and Fragments, they have no UVs or Vertices. The only inputs are Buffers, Constants, Uniforms and Textures loaded in memory, and some fundamental variables

```glsl
#define SubgroupCount gl_NumSubgroups
#define WorkgroupCount gl_NumWorkGroups // uvec3 total number of workgroups
#define WorkgroupSize gl_WorkGroupSize // uvec3 how many threads in a workgroup
#define WorkgroupID gl_WorkGroupID // uvec3 index in the global workgroup
#define GlobalThreadID gl_GlobalInvocationID // shorthand for WorkgroupID * WorkgroupSize + LocalThreadID
#define LocalThreadID gl_LocalInvocationID // uvec3 position inside the workgroup
#define LocalThreadIndex gl_LocalInvocationIndex // int 1D version of LocalThreadID
```

Workgroups are "small" groups of fully parallel threads, usually 32-64, these are defined at the beginning of the shader
Multiple workgroups are executed at the same time to do something usually, which might run at the same time.

Visualize position inside the local workgroup
    final_color = vec4(vec3(LocalThreadID)/ vec3(WorkgroupSize), 1);
Visualize position in the total compute shader
    final_color = vec4(vec3(GlobalThreadID)/ (vec3(WorkgroupCount)*vec3(WorkgroupSize)), 1);
Visualize the workgroup itself inside the total shader
    final_color = vec4(vec3(WorkgroupID)/ vec3(WorkgroupCount), 1);

https://www.taylorpetrick.com/blog/post/convolution-part1

## Network
### LuaJIT-requests

The [Library](https://github.com/LPGhatguy/luajit-request) relies upon libcurl, which needs to be compiled and added to the plugin folder of the APK file before installing, in `lib/arm64-v8a`

```lua
    request = require("luajit-request")
```

it supports GET and POST, file streams, custom headers and more

Documentation is scarce, and the best way is just reading the `init.lua` file to understand how to pass arguments.

You might also want to look up [HTTP specifications](https://developer.mozilla.org/en-US/docs/Web/HTTP) to correctly build the header 

User agent is passed via a custom header component:
```lua
    local head_table ={}
    head_table["User-Agent"]="MyUserAgent/0.1"
    local response = request.send(URL, { headers = head_table })
```

### JSON
Lua is not batteries included, so we need a JSON parsing library.

The fastest is [Lua-cJSON](https://github.com/bjornbytes/lua-cjson) which is a compiled plugin based on a C library, faster but also needs to be added to the APK.

For pure Lua we have [lunajson](https://github.com/grafi-tt/lunajson) and [json.lua](https://github.com/rxi/json.lua), both valid and quite efficient, with no need to compile or inject libraries, and fast enough for simple website API access


## OOP

Lua by itself has no OOP methods. Classes and Objects are not available. Some classes can implement this, but these can be easily built as needed by using Tables and Metatables


https://docs.otland.net/lua-guide/concepts/metatables
https://www.lua.org/pil/16.html
https://lua-users.org/wiki/ObjectOrientedProgramming
http://www.lua.org/pil/13.4.1.html

### Objects
Tables are the fundamental associative arrays of Lua. These can be used to build dictionaries, lists, vectors, arrays and objects.

Simply define a function as

```lua
obj={}
function obj.method(self)
    -- do stuff
end
```
And you have a valid object. 

### Classes
Here we need the metatables. These are advanced tables that can define more complex properties such as integration through operators like `+` or `==`, but also things like length, calling the table like a function, what to do when a certain value is called and what to do when a new value is defined.

The core question is defining standard keys and values for standard functions, those of the class, so each instance can call the same functions but with their values.
This function is covered by the `__index` metatable, which defines where else to go to check for unknown indices

This is achieved by defining the functions for the class on an empty or minimal table, then at initialization of the instance, we initialize a new table with the needed values, associate the instance with the class via the `__index` metatable and returning the instance. 
Each instance will access the methods of the class unless overridden and any usage of `self` will be in reference to the instance, not the class

```lua
Class = {}  -- empty table used by class

function Class.new(self, val1, val_2) --define generting method
    local instance = {
        key_1 = val_1,
        key_2 = val_2
    } -- crate table for instance and fill with datas
    setmetatable(instance, { __index = Class }) --associate the instance with the class object and inherit the methods and properties
    return instance -- return the instance, not the class
end
```

## Tasks

ADB commands obviously are key to any decently useful task

Pipes can be extremely useful to move data between commands and functions

`wait` can be used to wait for the previous command to finish

`sleep n` waits n seconds before moving to the next command

A very useful command to use in tasks is `play`. It can play audio files, but can also synthesize soundwaves from scratch
```bash
    play -q -n -c2 synth sin %-12 sin %-9 sin %-5 sin %-2 fade q 0.1 1 0.3
```
Gives a very nice Organ-like sound




## Moving to v0.16

texture and images do not support `rgb` anymore, either transparency or other methods are needed

Materials are now generated with a table of values, which are passed to the shader pipeline

texture filtering is no longer set via `:setFilter()`, it seems to be declared at creation only

Textures are associated with materials at creation, and updates are more complex. They can still be updated but a transfer pass to mode data from the CPU to the GPU is now needed.

`lovr.graphics` seems to have been downsized heavily, now using render passes, generated via `lovr.draw(pass)`

cylinders and cones have different geometric descriptions, and it's unclear

`graphics.print` is now `pass:text`

some draw commands have been remixed, values moved around

Operations that move data between CPU and GPU are now more complex, such as copying images into textures. These now require using a transfer pass, which has to be created and held until the end of the frame and submitted wit the draw pass. Submitting a pass ends the frame and any subsequent pass operations crashes LOVR.

Materials are set at the pass, not at draw

### Shaders
these have been reworked quite a lot
the now have their function endpoint at `lovrmain`, for both vertex and fragment
functions no longer require input args
the uniforms are much different, better documented, although some older entries seem to be missing
we'll have to get some basic understanding of 3D camera geometry

Buffers and Constants are now the main passageways between CPU and Shaders, with better documentation

There are some bugs regarding buffers, specifically using Vec3 causes weird errors if you don't use layout = 140, or just use Vec4



## Docs
using the recommended extensions you can write and compile useful documentation for your modules and functions
https://emmylua.github.io/annotations/param.html