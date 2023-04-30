local breathing = {}

function breathing:init()
    breathing.shader = lovr.graphics.newShader("Shaders/breathing/breathing.vert", "Shaders/breathing/breathing.frag", {})
    
end

function breathing:load(pass)

    pass:setShader(self.shader)
    pass:send("time", lovr.timer.getTime())
    pass:send('lightColor', { 1.0, 1.0, 1.0, 1.0 })
    pass:send('ambience', { 0.1, 0.1, 0.1, 1.0 })
    pass:send('specularStrength', 0.5)
    pass:send('metallic', 32.0)
    pass:send('lightPos', {2, 2, 2})
end


function breathing:demo(pass)
    pass:setShader(self.shader)
    pass:send("time", lovr.timer.getTime())
    pass:sphere(1, 1, 1)
    pass:setShader()
end

return breathing