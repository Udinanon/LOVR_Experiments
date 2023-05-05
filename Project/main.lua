---@diagnostic disable: deprecated

Utils = require "Utils"
Graphs = require "Graphs"
Breathing = require "Shaders/breathing"

function lovr.load()
  
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal()
    -- check if no state is normals
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  lovr.graphics.setBackgroundColor(.1, .1, .1, 1)

  Breathing:init()

end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  world:update(dt)
  
  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
    -- clear all
      Utils.boxes = {}
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

  if lovr.system.isKeyDown("space") then
    print("SPACE")
    Breathing:update(vec3(lovr.headset.getPosition("left")))
  end


end

-- this draws obv
function lovr.draw(pass)
  --Lights:draw_lights(pass)
  local transfer = lovr.graphics.getPass("transfer")
  --Lights:load(pass, transfer)
  Breathing:load(pass)
  pass:cube(vec3(2, 0, 1), .3, quat(), "fill")
  pass:sphere(.3, .3, .3)
  pass:setShader()
  Utils.drawHands(pass, 0xffffff)
  Utils.drawBounds(pass)
  Utils.drawAxes(pass)

  return lovr.graphics.submit({ pass, transfer })
end
