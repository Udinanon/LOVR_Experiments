local breathing = {}

function breathing:init()
    breathing.shader = lovr.graphics.newShader("Shaders/breathing/breathing.vert", "Shaders/breathing/breathing.frag")
    
end

function breathing:load(pass)
    pass:setShader(self.shader)
    pass:send("time", lovr.timer.getTime())
end


function breathing:demo(pass)
    pass:setShader(self.shader)
    pass:send("time", lovr.timer.getTime())
    pass:sphere(1, 1, 1)
    pass:setShader()
end

return breathing