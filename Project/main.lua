---@diagnostic disable: deprecated

Utils = require "Utils"
Graphs = require "Graphs"
Stereo = require("Stereo")
ANDROID = lovr.system.getOS() == 'Android'

-- run on boot of the program, where all the setup happes
function lovr.load()
  print("LODR LOAD")
  Stereo:init("3d")
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  lovr.graphics.setBackgroundColor(.1, .1, .1, 1)


  Graph = Graphs:new()
  Graph:setVisible()
  Graph:drawAxes()

  BlackBoard = Graphs:new(1, 4)
--  BlackBoard:drawPoint({1, 1}, {1, 1, 1, 1})
  BlackBoard:setVisible()
  BlackBoard:drawAxes()
  BlackBoard:setPose(mat4(vec3(0, 1.5, 1), quat(0, 0, 0, 1)))

end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  Stereo:setHeadPose(lovr.headset.getPose())
  -- update physics, like magic
  world:update(dt)

  if State:isNormal() then
    if lovr.headset.wasPressed("right", 'trigger') then
      local curr_color = Utils.shallowCopy(color)
      Utils.addVector(lovr.math.newVec3(lovr.headset.getPosition("right")), lovr.math.newVec3(lovr.headset.getVelocity("right")), curr_color, true)
      -- create cube there with color and shift it slightly
      color[1] = color[1]+40
      Utils.addBox(vec3(lovr.headset.getPosition("right")))
    end 
      
      -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
      print("Left Click")
      
      Graph:reposition()
    end
  end

  -- update blackboard
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = lovr.math.vec3(lovr.headset.getPosition(hand))
    Graph:drawPoint({position.x, position.z}, {10, 1, 1, 1})
  end

  


  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
    -- clear all
      Graph:clean()
      BlackBoard:clean()
      Utils.boxes = {}
  end

  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
    if State["A"] then

      
    end
  end
  if lovr.headset.wasPressed("right", "b") then
    State["B"] = not State["B"]
    if State["B"] then


    end
  end


end

-- this draws obv
function draw(pass)


  Utils.drawVectors(pass)
  --Utils.drawLabels(pass)

  
  -- draw hands
  if State:isNormal() then
    Utils.drawHands(pass, 0xffffff)
  end
  if State["A"] then
    Utils.drawHands(pass, 0x0000ff)
  end
  if State["B"] then
    Utils.drawHands(pass, 0x00ff00)
  end
  -- draw blackboard
  local transfer_pass = lovr.graphics.getPass("transfer")
  Graphs:drawAll(pass, transfer_pass)
  Utils.drawBounds(pass)
  Utils.drawAxes(pass)
  

  Utils.drawBoxes(pass)
  lovr.graphics.submit({ pass, transfer_pass })
end

function lovr.draw(pass)
  if ANDROID then
    return draw(pass)
  else
    return lovr.graphics.submit(Stereo:render(draw))
  end
end

function lovr.mirror(pass)
  if ANDROID then
    return true
  else
    Stereo:blit(pass)
  end
end
