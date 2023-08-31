local vertex_art = {}

---TODO:
-- Preprocess shaders to ensure comatibility with minimal manual editing
-- Reorder code to minimize GPU actions
-- Setup dummy samplers for sound and touch
-- Make a trurly 3D shader
-- Showcase and share
-- Contact Gman


function vertex_art:init()
    local headed_shader = lovr.filesystem.read("Shaders/vertex_art/header.vert") ..
    lovr.filesystem.read("Shaders/vertex_art/test.vert")
    vertex_art.shader = lovr.graphics.newShader(headed_shader, "Shaders/vertex_art/vertex_art.frag", {})
end

function vertex_art:load(pass)
    pass:setShader(self.shader)
    pass:setColor(1, 1, 1, 1)
    pass:send("time", lovr.timer.getTime())
    pass:send("resolution", vec2(1000, 1000))
    pass:send("mouse", vec2(0, 0));
    pass:send("background", vec4(1, 1, 1, 1));
    --pass:send(" sampler2D " "volume", );
    --pass:send(" sampler2D " "sound", );
    --pass:send(" sampler2D " "floatSound", );
    --pass:send(" sampler2D " "touch", );
    pass:send("soundRes", vec2(1000, 1000));
    pass:send("_dontUseDirectly_pointSize", 1.);
end



function vertex_art:demo(pass)
    vertex_art:load(pass)
    local indexCount = 100
    pass:send("vertexCount", indexCount);

    
    --- This creates what i think looks like the TRIANGLES, LINES and POINTS mode
    --pass:setMeshMode("triangles")

    --- Allows for arbitrary number of vertices with minimal work (and cost?)
    --local buffer = lovr.graphics.getBuffer(indexCount, "vec3")
    --pass:mesh(buffer)

    --- This creates the effect of LINE_STRIP
    local points = {}
    for i = 1, indexCount do
        points[i]= {vec3(0)}
    end
    --pass:line(points)

    pass:plane(mat4(), "line", 10, 9)
    --- nothing different from line
    --pass:circle(mat4(vec3(1, 1, 1)), "line", 0, 2 * math.pi, indexCount)
    pass:setShader()
end

return vertex_art

