---@diagnostic disable: deprecated

Utils = require "Utils"
Graphs = require "Graphs"
require "Shaders/multi_light/multi_light"
-- run on boot of the program, where all the setup happes
function lovr.load()
  print("LODR LOAD")
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  lovr.graphics.setBackgroundColor(.1, .1, .1, 1)

  lovr.graphics.setShader(shader)
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  --shader:send('viewPos', {lovr.headset.getPosition("head")})
  --shader:send("time", lovr.timer.getTime())
  -- update physics, like magic
  world:update(dt)

  if State:isNormal() then
    if lovr.headset.wasPressed("right", 'trigger') then
 

    end 
      
      -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
    end
  end
 
  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
  end
  if lovr.headset.wasPressed("right", "b") then
    State["B"] = not State["B"]
  end
  if lovr.headset.wasPressed("right", "b") then
    State["B"] = not State["B"]
    if State["B"] then


    end
  end

  local start_point = lovr.math.newVec3(1, 1, 1)
  local x_axis = lovr.math.newVec3(1, 0, 0)
  Utils.addVector(start_point, x_axis, { 0, 1, 1, 1 })
  local quaternion = lovr.math.newQuat()
  Utils.addVector(start_point, quaternion:direction(), { .5, .1, 1, 1 })

end

-- this draws obv
function lovr.draw()
  
  -- draw hands
  if State:isNormal() then
    Utils.drawHands(0xffffff)
  end
  if State["A"] then
    Utils.drawHands(0x0000ff)
  end
  if State["B"] then
    Utils.drawHands(0x00ff00)
  end

  Utils.drawAxes()
  Utils.drawBounds()
end
