local Graphs = {
    all_graphs = {}
}

---Create new Graphs object instance
---@param size number Board size, meters
---@param scale number Internal scale
---@param resolution number Resolution of board image
---@param graph_type string Type, "center"|"positive"
---@param hand lovr.headset.Device Device board is linked to 
---@return table
function Graphs:new(size, scale, resolution, graph_type, hand)
    local graph_type = graph_type or "center"
    local hand = hand or "left"
    local resolution = resolution or 1000
    local scale = scale or 2
    
    local position = lovr.math.newVec3(lovr.headset.getPosition(hand))
    local orientation = lovr.math.newQuat(lovr.headset.getOrientation(hand))
    local size = size or 1
    local transform = lovr.math.newMat4(position, vec3(size), orientation)

    local image = lovr.data.newImage(resolution, resolution, "rgba8") -- empty image
    for x = 1, resolution-1 do
        for y = 1, resolution-1 do
            image:setPixel(x, y, 0, 0, 0, 1)
        end
    end
    local texture = lovr.graphics.newTexture(image, { mipmaps = false, usage={"sample", "transfer"}})
    local material = lovr.graphics.newMaterial({texture = texture})
    local instance = {
        transform = transform,
        scale = scale, -- internal scale in meters
        resolution = resolution,
        image = image,
        graph_type = graph_type, -- zero center or BL corner
        hand = hand, -- hand to reference
        visible = false, --if board is drawn 
        material = material,
        texture = texture
    }
    setmetatable(instance, { __index = Graphs }) --associate the instance with the class object and inherit the methods and properties
    local key = #Graphs.all_graphs + 1
    Graphs.all_graphs[key] = instance
    instance.key = key
    return instance
end

---Draw point at coordinates, (0,0) depending on graph_type
---@param coords table 2-table ints
---@param color table HSVA format
function Graphs:drawPoint(coords, color)
    local x, y = unpack(coords)
    if self.graph_type == "center" then
        -- clamp values
        x = Utils.clamp(x, -self.scale, self.scale)
        y = Utils.clamp(y, -self.scale, self.scale)
        --convert ot pixel coordinates
        x = (self.resolution/2) + ((x / self.scale) * (self.resolution - 1) / 2)
        y = (self.resolution/2) - ((y / self.scale) * (self.resolution - 1) / 2)

    elseif self.graph_type == "positive" then
        -- clamp values
        x = Utils.clamp(x, 0, self.scale)
        y = Utils.clamp(y, 0, self.scale)
        -- convert to pixel coords, invert y axis
        x = (x / self.scale) * (self.resolution-1)
        y = self.resolution - ((y / self.scale) * (self.resolution-1))
        
    end 
    self:drawPixel({ x, y }, color)
end

---Draw in specific pixel, (0,0) at TL
---@param coords table 2 int table
---@param color table HSVA
function Graphs:drawPixel(coords, color)
    local x, y = unpack(coords)
    x = Utils.clamp(x, 0, self.resolution - 1)
    y = Utils.clamp(y, 0, self.resolution - 1)
    self.image:setPixel(x, y, Utils.HSVAToRGBA(color))
end

---Draw axes based on internal settings
function Graphs:drawAxes()
    if self.graph_type == "center" then
        for i=0, self.resolution-1 do
            self:drawPixel({ (self.resolution / 2) - 1, i }, {180, 1, 100, 1})
            self:drawPixel({ i, (self.resolution / 2) - 1}, { 180, 1, 100, 1 })
        end
    elseif self.graph_type == "positive" then
        for i = 0, self.resolution - 1 do
            self:drawPixel({ 0, i }, { 1, 0, 100, 1 })
            self:drawPixel({ i, 0 }, { 1, 0, 100, 1 })
        end
    end
end

---Update the board textures
function Graphs:update_textures(transfer_pass)
    if not self.visible then
        return
    end
    transfer_pass:copy(self.image, self.texture)
end


---Draw the board in VR
function Graphs:draw(pass)
    if not self.visible then
        return
    end
    pass:setMaterial(self.material)
    pass:plane(self.transform)    
end

---Move board position and orientation to hand, rotated to have plane facing userù
function Graphs:reposition()
    local transform = lovr.math.mat4()
    transform:translate(vec3(lovr.headset.getPosition(self.hand)))
    transform:rotate(quat(lovr.headset.getOrientation(self.hand)))
    transform:rotate(math.pi / 2, 1, 0, 0)
    self:setPose(transform)
end

---Set position and orientation
---@param transform mat4 transofmr
function Graphs:setPose(transform)
    self.transform:set(transform)
end

---Toggle board.visible
function Graphs:toggleVisibility()
    self.visible = not self.visible
end

---Set board,visible = true
function Graphs:setVisible()
    self.visible = true
end

---Reset graph to blank image
function Graphs:clean()
    self.image = lovr.data.newImage(self.resolution, self.resolution) -- empty image
end

---Destroy graph
function Graphs:destroy()
    Graphs.all_graphs[self.key] = nil
    self = nil
end

-- Class functions

---Call Graph:draw() on all Graphs
function Graphs:drawAll(pass, transfer_pass)
    
    
    for _, graph in ipairs(Graphs.all_graphs) do
        graph:update_textures(transfer_pass)
    end

    --lovr.graphics.submit(transfer_pass)
    pass:setColor(1, 1, 1, 1)
    for _, graph in ipairs(Graphs.all_graphs) do
        graph:draw(pass)
    end
    pass:setMaterial()
end

return Graphs