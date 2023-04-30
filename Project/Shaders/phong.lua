Phong = {}

---Initilaize shader 
function Phong:init()
    self.shader = lovr.graphics.newShader("Shaders/phong/phong.vert", "Shaders/phong/phong.frag", {})
    self.lightPos = lovr.math.newVec3(2, 2, 2)
end

---Update shader's light source
---@param lightPos lovr.Vec3 
function Phong:update(lightPos)
    self.lightPos = lovr.math.newVec3(lightPos)
end

function Phong:load(pass)
    pass:setShader(self.shader)
    pass:send('lightColor', { 1.0, 1.0, 1.0, 1.0 })
    pass:send('ambience', { 0.1, 0.1, 0.1, 1.0 })
    pass:send('specularStrength', 0.5)
    pass:send('metallic', 32.0)
    pass:send('lightPos', self.lightPos)
end

---Load Phong shader
---@param pass lovr.Pass Drawing pass
function Phong:broken_load(pass)
    pass:setShader(self.shader)
    pass:send('mode', 1)
    pass:send('Ka', 1)
    pass:send('Kd', 1)
    pass:send('Ks', 1)
    pass:send('shininessVal', 1)
    pass:send('ambientColor', { 1, 1, 1 })
    pass:send('diffuseColor', { 1,1, 1 })
    pass:send('specularColor', { 1, 1, 1 })
    pass:send('lightPos', self.lightPos)
end

return Phong