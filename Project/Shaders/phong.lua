Phong = {}

---Initilaize shader 
function Phong:init()
    self.shader = lovr.graphics.newShader("Shaders/phong/phong.vert", "Shaders/phong/phong.frag", {})
    self.lightPos = lovr.math.newVec3(10, 10, 10)
end

---Update shader's light source
---@param lightPos lovr.Vec3 
function Phong:update(lightPos)
    self.lightPos = lightPos
end

function Phong:load(pass)
    pass:setShader(self.shader)
    pass:send('lightColor', { 1.0, 1.0, 1.0, 1.0 })
    pass:send('lightPos', { 2.0, 5.0, 0.0 })
    pass:send('ambience', { 0.1, 0.1, 0.1, 1.0 })
    pass:send('specularStrength', 0.5)
    pass:send('metallic', 32.0)
end

---Load Phong shader
---@param pass lovr.Pass Drawing pass
function Phong:broken_load(pass)
    pass:setShader(self.shader)
    pass:send('mode', 1)
    pass:send('Ka', 0.1)
    pass:send('Kd', 0.8)
    pass:send('Ks', 0.1)
    pass:send('shininessVal', 0.2)
    pass:send('ambientColor', { 1, 1, 1 })
    pass:send('diffuseColor', { 0.5, 0.5, 0.5 })
    pass:send('specularColor', { 0, 0, 0 })
    pass:send('lightPos', {2, 2, 2})
end

return Phong