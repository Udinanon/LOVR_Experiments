-- Class for generic grabbable points
local icosphere = require 'icosphere'

GrabPoint = {} -- empty table used by class

function GrabPoint.new(self, pos, radius) --define generting method
    local vertices, indices = icosphere(2)
    local instance = {
        pos = pos,
        radius = radius,
        active = false,
        mesh = lovr.graphics.newMesh(vertices, "lines"),
        collider = world:newMeshCollider(vertices, indices)
        
    } -- crate table for instance and fill with datas
    instance.mesh:setVertexMap(indices)
    local shapes= instance.collider:getShapes()
    for k, v in ipairs(shapes) do
        print(k, v)
    end
    setmetatable(instance, { __index = GrabPoint }) --associate the instance with the class object and inherit the methods and properties
    instance.collider:setTag("grabpoint")
    return instance -- return the instance, not the class
end

function GrabPoint.draw(self)
    if self.active then
        lovr.graphics.setColor(0.8, 0.7, .2)
    else
    end
    
    
    lovr.graphics.setWireframe(true)
    self.mesh:draw(self.pos, .06)
    --lovr.graphics.sphere(self.pos, self.radius)
    lovr.graphics.setWireframe(false)
    lovr.graphics.setColor(1, 1, 1)
end

function GrabPoint.set_pos(self, pos)
    self.pos = lovr.math.newVec3(pos)
end