local edge_detector = {}

function edge_detector:init() 
    self.shader = lovr.graphics.newShader("Shaders/edge_detection/edge_detection.comp", {label = "edge_detector"})
    self.old = lovr.graphics.newTexture('Assets/gatt.jpg', {
        mipmaps = false,
        usage = { 'storage', 'sample', 'transfer' },
        linear = true -- srgb textures don't always support storage usage
    })
    self.texture = lovr.graphics.newTexture('Assets/gatt.jpg', {
        mipmaps = false,
        usage = { 'storage', 'sample', 'transfer' },
        linear = true -- srgb textures don't always support storage usage
    })
    local compute_pass = lovr.graphics.getPass("compute")
    compute_pass:setShader(self.shader)
    local tw, th = self.texture:getDimensions()
    local sx, sy = self.shader:getWorkgroupSize()
    local gx, gy = math.ceil(tw / sx), math.ceil(th / sy)
    compute_pass:send("image", self.old)
    compute_pass:send("out_image", self.texture)
    compute_pass:compute(gx, gy)
    lovr.graphics.submit(compute_pass)
end

function edge_detector:detect(pass)
    
    pass:setMaterial(self.texture)
    pass:plane(0, 1.7, -1)
    pass:setMaterial(self.old)
    pass:plane(0, 1.7, -2)
    pass:setMaterial()
    --print(pass:getType())
end


return edge_detector