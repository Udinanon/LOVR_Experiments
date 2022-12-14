---@diagnostic disable: deprecated

require "Utils"


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
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  boxes = {}
  cubes = {}
  volumes = {}
  walls = 0
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

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

  if State:isNormal() then
    if lovr.headset.wasPressed("right", 'trigger') then
      -- create cube there with color and shift it slightly
      local th_x, th_y = lovr.headset.getAxis('right', 'thumbstick')
      local x, y, z, angle, ax, ay, az = lovr.headset.getPose("right")
      local curr_color = shallowCopy(color)
      local cube = {["pos"] = {x, y, z, .10, angle, ax, ay, az}, ["color"] = curr_color}
      color[1] = color[1]+2

      -- the th_x gives us multiple cube sizes
      if th_x >= 0.75 then
        cube["pos"][4]=.20
        table.insert(cubes, cube)
      elseif th_x <= -0.75 then
        cube["pos"][4]=.05
        table.insert(cubes, cube)
      else 
        table.insert(cubes, cube)
      end

    end 

    -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
      -- generate a physics box there
      local x, y, z = lovr.headset.getPosition("left")
      local box = world:newBoxCollider(x, y, z, .10)
      -- the velocity thing feels weird but tehre is no headset.getAccelleration
      -- maybe making a custom function but eh
      local vx, vy, vz = lovr.headset.getVelocity("left")
      box:setLinearVelocity(vx, vy, vz)
      table.insert(boxes, box)
    end
  end

  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') and lovr.headset.wasPressed("right", 'grip') then
      -- remove all boxes and cubes
      cubes = {}
      boxes = {}
  end

  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
    if State["A"] then

      
    end
  end
end

-- this draws obv
function lovr.draw()
  -- draw white spheres for the hands
  if State:isNormal() then
    drawHands(0xffffff)
  end
  if State["A"] then
    drawHands(0x0000ff)
  end
  if State["B"] then
    drawHands(0x00ff00)
  end

  -- draw the boxes
  for i, box in ipairs(boxes) do
    local x, y, z = box:getPosition()
    lovr.graphics.setColor(0.8, 0.8, 0.8)
    lovr.graphics.cube('fill', x, y, z, .1, box:getOrientation())
  end

  -- draw the cubes
  for i, cube in ipairs(cubes) do
    local cube_color=cube["color"]
    local position=cube["pos"]
    local r, g, b, a=HSVToRGB(unpack(cube_color))
    lovr.graphics.setColor(r, g, b, a)
    lovr.graphics.cube("line", unpack(position))
  end



  -- draw collider volumes
  for i, volume in ipairs(volumes) do
    local x, y, z = volume:getPosition()
    local vol_shape = volume:getShapes()[1]
    local width, height, depth = vol_shape:getDimensions()
    lovr.graphics.setColor(0, 0.1, 0.12)
    lovr.graphics.box('fill', x, y, z, width, height, depth, volume:getOrientation())
  end
  
  -- A state, add collider volumes mode
  if State["A"] then
    addVolumes()
  end

  drawAxes()
  drawBounds()
end
