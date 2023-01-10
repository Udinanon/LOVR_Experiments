block = lovr.graphics.newShaderBlock('uniform', {
    lightPos = { 'vec4', 2 }
}, { usage = 'static' })
light_pos = vec3(0.0, 1.0, 0.0)
local positions = {}
positions[1] = { 1.0, light_pos:unpack() }
positions[2] = { 1.0, 1.0, 5.0, 1.0 }
--for i = 3, 10 do
--positions[i] = lovr.math.vec4(0.0)
--end
block:send("lightPos", positions)
-- concatenate block:getShaderCode("lightBlock") with fragment
shader = lovr.graphics.newShader(lovr.filesystem.read("Shaders/multi_light/multi_light.vert"),
    block:getShaderCode("lightBlock") .. lovr.filesystem.read("Shaders/multi_light/multi_light.frag"))
shader:send('ambience', { 0.01, 0.0, 0.01, 1.0 })
--light_table = { {1.0, 1.0, 1.0, 1.}, {1.0, 1.0, 5.0, 1.0} }
--shader:send("lightPos", light_table)

shader:sendBlock("lightBlock", block)
shader:send("lightColor", { 0.2, 0.2, 0.2, })
