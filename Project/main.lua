---@diagnostic disable: deprecated

Utils = require "Utils"
Graphs = require "Graphs"

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
  -- update physics, like magic
  world:update(dt)

  if State:isNormal() then
    if lovr.headset.wasPressed("right", 'trigger') then
      local curr_color = Utils.shallowCopy(color)
      Utils.addVector(lovr.math.newVec3(lovr.headset.getPosition("right")), lovr.math.newVec3(lovr.headset.getVelocity("right")), curr_color, true)
      -- create cube there with color and shift it slightly
      color[1] = color[1]+40
    end 
      
      -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
      print("Left Click")
      
      Graph:reposition()
    end
  end

  -- update blackboard
  local time = lovr.timer.getTime()
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = lovr.math.vec3(lovr.headset.getPosition(hand))
    Graph:drawPoint({position.x, position.z}, {10, 1, 1, 1})
  end

  


  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
    -- clear all
      Graph:clean()
      BlackBoard:clean()
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
function lovr.draw(pass)
  local start_point = lovr.math.newVec3(-0, .5, .5)
  Utils.addLabel("start_point", start_point)

  local quaternion = lovr.math.newQuat()
  Utils.addVector(start_point, quaternion:direction(), { .5, .1, 1, 1 })
  Utils.addLabel("empty_quat", start_point + quaternion:direction())

  local hand_quat = quat(lovr.headset.getOrientation("hand/right"))
  
  local x_axis = lovr.math.newVec3(-1, 0, 0)
  local rotated_vec = hand_quat:mul(x_axis)
  Utils.addVector(start_point, rotated_vec, { .5, .2, 1, 1 })
  Utils.addLabel("hand_quat_x", start_point + rotated_vec)

  local y_axis = lovr.math.newVec3(0, -1, 0)
  local rotated_vec = hand_quat:mul(y_axis)
  Utils.addVector(start_point, rotated_vec, { .5, .2, 1, 1 })
  Utils.addLabel("hand_quat_y", start_point + rotated_vec)

  local q2 = lovr.math.newQuat(vec3(0, -1, 0))
  local tmp = lovr.math.newVec3(1, 0, 0)
  local tmp = q2:mul(tmp)
  --local tmp = hand_quat:mul(tmp)
  Utils.addVector(start_point, tmp, {.5, .3, .8, 1})
  Utils.addLabel("double_quat", start_point + tmp)

  local vec1 = vec3(1, 1, 1):normalize()
  local transform = mat4(vec3(0, 0, 0), vec3(1, 1, 1), quat(0, 0, 1, 0))
  local rott = quat(vec1)

  transform:rotate(rott)
  pass:plane(transform)

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
  local transfer_pass = nil
  transfer_pass = Graphs:drawAll(pass)

  Utils.drawBoxes(pass)
  Utils.drawVolumes(pass)
  Utils.drawAxes(pass)
  Utils.drawBounds(pass)
  lovr.graphics.submit({ pass, transfer_pass })
end
