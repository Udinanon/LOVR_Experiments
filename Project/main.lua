---@diagnostic disable: deprecated

local Utils = require "Utils"


-- run on boot of the program, where all the setup happes
function lovr.load()
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  local width, depth = lovr.headset.getBoundsDimensions()
  print("LODR LOAD")
  print(width)
  print(depth)
  --world:newBoxCollider(0, 0, 0, 55, .05, 55):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  boxes = {}
  cubes = {}
  volumes = {}
  walls = 1
  
  
  require "Bodies"
  
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end
  


  to_draw={}
  vec_color = {0, 1, 1, 1}
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  world:update(dt)

  if walls == 0 then
      local width, depth = lovr.headset.getBoundsDimensions()
      world:newBoxCollider(width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(-width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(0, 2, depth/2, width, 4, 0.1):setKinematic(true)
      world:newBoxCollider(0, 2, -depth/2, width, 4, 0.1):setKinematic(true)
      walls = 1
  end
  
  if not State["B"]then
    local sun_pos = lovr.math.newVec3(sun.collider:getPosition())
    for i, this_body in ipairs(bodies) do
      this_body:apply_force(sun_pos)
    end

  end

  if State:isNormal() then
    if lovr.headset.wasPressed("right", 'trigger') then
      local curr_color = shallowCopy(color)
      body = Body:new(curr_color, lovr.math.newVec3(lovr.headset.getPosition("right")),
        lovr.math.newVec3(lovr.headset.getVelocity("right")))
      Utils.addVector(lovr.math.newVec3(lovr.headset.getPosition("right")),
        lovr.math.newVec3(lovr.headset.getVelocity("right")), curr_color, true)
        -- create cube there with color and shift it slightly
        color[1] = color[1]+40
        
        table.insert(bodies, body)
      end 
      
      -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
      print("HERE")
      local sun_pos = lovr.math.newVec3(sun.collider:getPosition())
      local hand_pos = vec3(lovr.headset.getPosition("left"))
      local hand_quat = quat(lovr.headset.getOrientation("left"))
      local x_axis = lovr.math.newVec3(-1, 0, 0)

      x_axis = hand_quat:mul(x_axis):normalize()
      local distance_vec = (sun_pos-hand_pos):normalize()
      local speed_vec = distance_vec:cross(x_axis)
      local speed_mod = math.sqrt(.01 * (sun.mass + 1) / distance_vec:length()) 
      local curr_color = shallowCopy(color)
      
      body = Body:new(curr_color, lovr.math.newVec3(lovr.headset.getPosition("left")),
        speed_vec:mul(speed_mod))
      body.draw_force = false
      body:compute_orbit(x_axis)
      body.draw_orbit = true

      print("HERE")
      color[1] = color[1] + 40

      table.insert(bodies, body)
      Utils.addLabel("HERE", lovr.math.newVec3(lovr.headset.getPosition("left")))

    end
  end

  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
      -- remove all boxes and cubes
      cubes = {}
      boxes = {}
      bodies = {}
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
function lovr.draw()
  Utils.drawVectors()
  Utils.drawLabels()

  -- draw sun
  lovr.graphics.setColor(sun.color)
  lovr.graphics.sphere(vec3(sun.collider:getPosition()), 0.08)
  lovr.graphics.setColor(1, 1, 1)

  if not State["A"] then
    for i, elem in ipairs(to_draw) do
      print("drawing elem ")
      print(elem.start)
      print(elem.fin)
      local elem_color = elem.color
      local r, g, b, a = HSVToRGB(unpack(elem_color))
      lovr.graphics.setColor(r, g, b, a) 
      lovr.graphics.line(elem.start, elem.fin) 
    end
  end
  to_draw = {}
  vec_color[1] = 0
  lovr.graphics.setColor(1, 1, 1)

  -- draw the bodies
  local sun_position = vec3(sun.collider:getPosition())
  for i, body in ipairs(bodies) do
    body:draw(sun_position)
  end

  if State:isNormal() then
    drawHands(0xffffff)
  end
  if State["A"] then
    drawHands(0x0000ff)
  end
  if State["B"] then
    drawHands(0x00ff00)
  end

  -- A state, add collider volumes mode
  if State["A"] then
   --addVolumes()
  end

  -- draw the boxes
  for i, box in ipairs(boxes) do
    local x, y, z = box:getPosition()
    lovr.graphics.setColor(0.8, 0.8, 0.8)
    lovr.graphics.cube('fill', x, y, z, .1, box:getOrientation())
  end

  -- draw the bodies
  for i, body in ipairs(bodies) do
    local color = body["color"]
    local r, g, b, a = Utils.HSVToRGB(unpack(color))
    lovr.graphics.setColor(r, g, b, a)
    lovr.graphics.sphere(vec3(body.collider:getPosition()), 0.02)


  end

  -- draw collider volumes
  for i, volume in ipairs(volumes) do
    local x, y, z = volume:getPosition()
    local vol_shape = volume:getShapes()[1]
    local width, height, depth = vol_shape:getDimensions()
    lovr.graphics.setColor(0, 0.1, 0.12)
    lovr.graphics.box('fill', x, y, z, width, height, depth, volume:getOrientation())
  end

  Utils.drawAxes()
  Utils.drawBounds()
end
