MultiLight = {} -- For more complex shaders we use an object

-- initialization of lights and buffers and other basic properties
function MultiLight:init()
    local n_lights = 5
    local positions = {}
    for i = 1, n_lights do
        positions[i] = lovr.math.newVec4(0., 0., 0., 1)
    end
    positions[1] = lovr.math.newVec4(0.0, 2.0, 0.0, 1)
    positions[2] = lovr.math.newVec4(2., 2., 2., 1)

    -- the size of the buffer is computed automatically
    --- It could be interesting to use a struct here to have individual light colors
    local buffer = lovr.graphics.newBuffer(positions, "vec4")

    -- Load Shader code from disk
    --- using strinc concatenation we could have more dynamic code generation
    shader = lovr.graphics.newShader(lovr.filesystem.read("Shaders/multi_light/multi_light.vert"),
        lovr.filesystem.read("Shaders/multi_light/multi_light.frag"))

    
    self.buffer = buffer
    self.positions = positions
    self.n_lights = n_lights
    self.shader = shader
    self.index = 1
    self.ambiance = lovr.math.newVec3(0.01, 0.01, 0.01)
    self.color = lovr.math.newVec3(1., 1., 1.)
    self.changed = 1
    
    --setmetatable(MultiLight, { __index = MultiLight }) --associate the instance with the class object and inherit the methods and properties
end

---Calls shaders and updates internal values
---@param pass lovr.Pass
---@param transfer_pass lovr.Pass Transfer pass
function MultiLight:load(pass, transfer_pass)
    pass:setShader(self.shader)
    -- update data from table to buffer
    transfer_pass:copy(self.positions, self.buffer)
    -- send constant to shader 
    pass:send("n_lights", self.n_lights)
    pass:send("Positions", self.buffer)
    pass:send('ambience', self.ambiance)
    pass:send("lightColor", self.color)
    self.changed = 0
end

---Reposition light sources cyclically
---@param position lovr.Vec3 
function MultiLight:update(position)
    self.positions[self.index] = lovr.math.newVec4(position.x, position.y, position.z, 1)
    print(self.positions[self.index])
    -- Update use modulo and add 1 as arrays are 1 index
    self.index = ((self.index) % self.n_lights) + 1
    self.changed = 1
end


function MultiLight:draw_lights(pass)
    pass:setColor(0xFFFFFF)
    for i = 1, self.n_lights do
       pass:sphere(mat4(self.positions[i].xyz, vec3(0.01), quat())) 
    end
end

return MultiLight