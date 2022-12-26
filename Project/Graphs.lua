
local Graphs = {
    all_graphs = {}
}
---Create new Graphs object instance
---@param size Meters of board size
---@param scale Internal scale
---@param resolution Resolution of board image
---@param graph_type Type of centering
---@param hand Device board is linked to 
---@return table
function Graphs:new(size, scale, resolution, graph_type, hand)
    local graph_type = graph_type or "center"
    local hand = hand or "left"
    local resolution = resolution or 1000
    local scale = scale or 10
    local size = size or 1
    local position = lovr.math.newVec3(lovr.headset.getPosition(hand))
    local orientation = lovr.math.newQuat(lovr.headset.getOrientation(hand))
    local image = lovr.data.newImage(resolution, resolution, "rgb", nil) -- empty image
    local texture = lovr.graphics.newTexture(image, { format = "rgb", mipmaps = false })
    local material = lovr.graphics.newMaterial()
    texture:setFilter("nearest")
    material:setTexture(texture)
    local instance = {
        position = position,
        orientation = orientation,
        size = size, -- meters in size
        scale = scale, -- how big the graph is internally
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
---@param coords 2-table ints
---@param color HSV table
function Graphs:drawPoint(coords, color)
    local x, y = unpack(coords)
    if self.graph_type == "center" then
        -- clamp values
        x = Utils.clamp(x, -self.scale, self.scale)
        y = Utils.clamp(y, -self.scale, self.scale)
        --convert ot pixel coordinates
        x = (self.resolution/2) + (x / self.scale) * (self.resolution - 1)
        y = self.resolution/2 - ((y / self.scale) * (self.resolution - 1))

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

-- Draw in specific pixel, (0,0) at TL
function Graphs:drawPixel(coords, color)
    local x, y = unpack(coords)
    x = Utils.clamp(x, 0, self.resolution - 1)
    y = Utils.clamp(y, 0, self.resolution - 1)
    self.image:setPixel(x, y, Utils.HSVAToRGBA(color))
end

-- Draw the board in VR
function Graphs:draw()
    if not self.visible then
        return
    end
    self.texture:replacePixels(self.image)
    lovr.graphics.plane(self.material, self.position, self.size, self.size, self.orientation)
    
end

-- Move board position and orientation to hand
function Graphs:reposition()
    self.position:set(lovr.headset.getPosition(self.hand))
    self.orientation:set(lovr.headset.getOrientation(self.hand))
end

function Graphs:toggleVisibility()
    self.visible = not self.visible
end

function Graphs:setVisible()
    self.visible = true
end

-- reset graph to blank image
function Graphs:clean()
    self.image = lovr.data.newImage(self.resolution, self.resolution, "rgb", nil) -- empty image
    local texture = lovr.graphics.newTexture(self.image, { format = "rgb", mipmaps = false })
    self.material:setTexture(texture)
end

-- Class functions

-- remove graph 
function Graphs:destroy()
    Graphs.all_graphs[self.key] = nil
    self = nil
end

-- utiliy function
function Graphs:drawAll()
    for _, graph in ipairs(Graphs.all_graphs) do
        graph:draw()
    end
    
end

return Graphs