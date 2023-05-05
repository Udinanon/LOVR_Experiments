local Stereo = {}

function Stereo:init(mode, fov, ipd)
    self.head = lovr.math.newMat4()
    if ANDROID then return end
    self.mode = mode or "stereo"
    self.ipd = ipd or 0.063
    self.fovy = fov or 0.45
    if self.mode == "stereo" then
        self.width = lovr.system.getWindowWidth() *.5
        self.stereoShader = lovr.graphics.newShader('fill', "Stereo.glsl")
    elseif self.mode == "3d" then        
        self.width = lovr.system.getWindowWidth()
        self.stereoShader = lovr.graphics.newShader('fill', "Dubois.glsl")
    end
    self.views = 2
    self.height = lovr.system.getWindowHeight()
    self.fovx = self.fovy * (self.width / self.height)
    self.canvas = lovr.graphics.newTexture(self.width, self.height, self.views, {
        type = 'array',
        usage = { 'render', 'sample' },
        mipmaps = false
    })

end

function Stereo:setHeadPose(...)
    self.head:set(...)
end

function Stereo:render(fn)
    local pass = lovr.graphics.getPass('render', self.canvas)

    local offset = vec3(self.ipd * .5, 0, 0)
    pass:setViewPose(1, mat4(self.head):translate(-offset))
    pass:setViewPose(2, mat4(self.head):translate(offset))

    local projection = mat4():fov(self.fovx, self.fovx, self.fovy, self.fovy, .01)
    pass:setProjection(1, projection)
    pass:setProjection(2, projection)

    fn(pass)

    return pass
end

function Stereo:blit(pass)
    pass:push('state')
    pass:setShader(self.stereoShader)
    pass:send('canvas', self.canvas)
    pass:fill()
    pass:pop('state')
end


return Stereo