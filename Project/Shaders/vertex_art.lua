local vertex_art = {}

vertex_art.FFT = require("fft")

---TODO:
-- Preprocess shaders to ensure comatibility with minimal manual editing
-- Reorder code to minimize GPU actions
-- Setup dummy samplers for sound and touch
-- Make a trurly 3D shader
-- Showcase and share
-- Contact Gman

---Adapt WebGL shader to OpenGL
---@param shader_filename string
---@return string
function vertex_art:prepare_shader(shader_filename)
    local shader_code = lovr.filesystem.read(shader_filename)
    -- remmeber to escape ( in the match strings but not in the substitute strings!
    shader_code = shader_code:gsub("#define PI", "// #define PI") -- Pi is already defined\
    shader_code = shader_code:gsub("void main%(", "vec4 lovrmain(") -- change function main\
    shader_code = shader_code:gsub("texture2D%(", "getPixel(") -- texture2D is WebGL, not compatible
    shader_code = shader_code:gsub("varying ", "// varying") -- deprecated in 130 OpenGL
    shader_code = shader_code:gsub("}%s*$", "\treturn Projection * View * Transform * gl_Position;\n}") -- return position and add geometry transforms
    local header_shader = lovr.filesystem.read("Shaders/vertex_art/header.vert")
    return header_shader .. shader_code
end


function vertex_art:init()
    vertex_art.shader_file = "Shaders/vertex_art/wave_vs.vert"
    local prepared_shader = self:prepare_shader(vertex_art.shader_file)
    print(prepared_shader)
    lovr.filesystem.write("Shaders/vertex_art/processed.vert", prepared_shader) -- not working?
    vertex_art.shader = lovr.graphics.newShader(prepared_shader, "Shaders/vertex_art/vertex_art.frag", {})
    vertex_art.music = lovr.data.newSound(
        "Assets/digboy - Ed Wrecked (Ruined By digboy) - 02 Touch & Go & Rinse & Repeat.ogg",
        true)
    vertex_art.fft_samples = 1024
    vertex_art.time_samples = 240
    vertex_art.sample_rate = vertex_art.music:getSampleRate()
    vertex_art.frame_size = vertex_art.sample_rate / 60
    vertex_art.audio_offset = 0
    vertex_art.sound_image = lovr.data.newImage(vertex_art.time_samples, vertex_art.fft_samples, "r8")
    -- sound has values 0-255 linearly
    vertex_art.sound_texture = lovr.graphics.newTexture(vertex_art.sound_image,
        { format = "r8", linear = true, samples = 1, mipmaps = false, usage = { "sample", "render", "transfer" } })
end

function vertex_art:load(pass)
    vertex_art.audio_offset = vertex_art.audio_offset + lovr.headset.getDeltaTime()
    for x = 1, vertex_art.time_samples do 
        local sound_buf, _ = vertex_art.music:getFrames(vertex_art.fft_samples, vertex_art.audio_offset + vertex_art.frame_size*(x-1))
        local byte_fft = vertex_art.FFT.byte_real_fft(sound_buf)
        for y = 1, vertex_art.fft_samples do
            vertex_art.sound_image:setPixel(x-1, y-1, byte_fft[y])
        end
    end

-- empty image
    --local sound_texture = lovr.graphics.newTexture(fft_samples, 240,        { format = "r8", linear = true, samples = 1, mipmaps = false, usage = { "sample", "render", "transfer" } })
    -- floatSound instad uses negative decibels, which is bullshit
    local float_sound_texture = lovr.graphics.newTexture(vertex_art.fft_samples, 240,
        { format = "rgba32f", linear = true, samples = 1, mipmaps = false, usage = { "sample", "render", "transfer" } })
    local volume_texture = lovr.graphics.newTexture(4, 240,
        { format = "rgba8", linear = true, samples = 1, mipmaps = false, usage = { "sample", "render", "transfer" } })
    local touch_texture = lovr.graphics.newTexture(32, 240,
        { format = "rgba8", linear = true, samples = 1, mipmaps = false, usage = { "sample", "render", "transfer" } })
    pass:setShader(self.shader)
    pass:setColor(1, 1, 1, 1)
    pass:send("time", lovr.timer.getTime())
    pass:send("resolution", vec2(1000, 1000))
    pass:send("mouse", vec2(0, 0));
    pass:send("background", vec4(1, 1, 1, 1));
    pass:send("touch", touch_texture)
    pass:send("sound", vertex_art.sound_texture)
    pass:send("floatSound", float_sound_texture)
    pass:send("volume", volume_texture)
    pass:send("soundRes", vec2(1000, 1000));
    pass:send("_dontUseDirectly_pointSize", 1.);
end


function vertex_art.update_textures(transfer_pass)
    transfer_pass:copy(vertex_art.sound_image, vertex_art.sound_texture)
end


function vertex_art:demo(pass, transfer_pass)
    vertex_art:load(pass)
    vertex_art.update_textures(transfer_pass)
    local indexCount = 1000
    pass:send("vertexCount", indexCount);

    
    --- This creates what i think looks like the TRIANGLES, LINES and POINTS mode
    pass:setMeshMode("lines")

    --- Allows for arbitrary number of vertices with minimal work (and cost?)
    local buffer = lovr.graphics.getBuffer(indexCount, "vec3")
    pass:mesh(buffer)

    --- This creates the effect of LINE_STRIP
    --local points = {}
    --for i = 1, indexCount do
    --    points[i]= {vec3(0)}
    --end
    --pass:line(points)

   -- pass:plane(mat4(), "line", 10, 9)
    --- nothing different from line
    --pass:circle(mat4(vec3(1, 1, 1)), "line", 0, 2 * math.pi, indexCount)
    pass:setShader()
end

return vertex_art

