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
