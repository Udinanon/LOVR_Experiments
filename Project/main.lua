---@diagnostic disable: deprecated, undefined-field, lowercase-global


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
    local r, g, b, a = HSVToRGB(unpack(color))
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

  -- draw axes
  drawAxesAndBounds()
end

-- utility function for the rainbow thing
function HSVToRGB(h, s, v, a)
  local c = v*s
  local x = c*(1-math.abs((h/60)%2-1))
  local m = v-c
  h = h % 360
  if h < 60 then
    return c, x, 0, a
  elseif h < 120 then
    return x, c, 0, a
  elseif h < 180 then
    return 0, c, x, a
  elseif h < 240 then
    return 0, x, c, a
  elseif h < 300 then
    return x, 0, c, a
  else
    return c, 0, x, a
  end
end

-- useful as LUA does the Python thing of not copying stuff
function shallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function drawHands(color)
  -- draw colored spheres for the hands
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local hand_quat = quat(lovr.headset.getOrientation(hand))
    lovr.graphics.setColor(color)
    lovr.graphics.sphere(position, .01)

    local x_axis = lovr.math.newVec3(-1, 0, 0)
    local y_axis = lovr.math.newVec3(0, -1, 0)
    local z_axis = lovr.math.newVec3(0, 0, -1)

    x_axis = hand_quat:mul(x_axis)
    y_axis = hand_quat:mul(y_axis)
    z_axis = hand_quat:mul(z_axis)

    lovr.graphics.setColor(1, 0, 0)
    lovr.graphics.line(position, position + z_axis * .05)
    lovr.graphics.setColor(0, 1, 0)
    lovr.graphics.line(position, position + x_axis * .05)
    lovr.graphics.setColor(0, 0, 1)
    lovr.graphics.line(position, position + y_axis * .05)

  end
end

function addVolumes()
  -- get hand positions
  local r_pos = vec3(lovr.headset.getPosition("right"))
  local l_pos = vec3(lovr.headset.getPosition("left"))

  -- draw connecting line
  lovr.graphics.setColor(1, 1, 0)
  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.line(0, 0, 0, 1, 0, 0)
  lovr.graphics.setColor(0, 0, 1)
  lovr.graphics.line(0, 0, 0, 0, 1, 0)
  lovr.graphics.setColor(1, 0, 0)
  lovr.graphics.line(0, 0, 0, 0, 0, 1)

  local width, height = lovr.headset.getBoundsDimensions()
  lovr.graphics.setColor(0.1, 0.1, 0.11)
  lovr.graphics.box("line", 0, 0, 0, width, .05, height)

  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.box("line", width / 2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", -width / 2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", 0, 2, height / 2, width, 4, 0.1)
  lovr.graphics.box("line", 0, 2, -height / 2, width, 4, 0.1)

  lovr.graphics.line({ r_pos, l_pos })

  -- get average point
  local avg_point = r_pos:add(l_pos):div(2)
  local avg_point_2 = vec3(avg_point)
  local height = avg_point[2]
  -- this edits r_pos
  -- draw average point
  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.sphere(avg_point, .01)

  -- get depth vector
  local r_pos = vec3(lovr.headset.getPosition("right"))
  local diff_vec = r_pos:sub(l_pos)
  local diff_bckp = vec3(diff_vec)

  --r_pos is no longer the same
  local depth_vec = diff_vec:cross(vec3(0, -1, 0)):normalize()
  local depth_point = avg_point_2:add(depth_vec:mul(0.5))

  lovr.graphics.setColor(1, 0, 1)
  lovr.graphics.line({ avg_point, depth_point })

  -- use raycast to find depth
  avg_point_2 = vec3(avg_point)
  depth_vec:normalize() -- reset depth_vec to have module 1
  local max_dim = math.max(lovr.headset.getBoundsDimensions())
  local end_point = avg_point_2:add(depth_vec:mul(max_dim))
  local collision_point = lovr.math.newVec3()
  local closest = math.huge
  avg_point_2 = vec3(avg_point)
  world:raycast(avg_point, end_point,
    function(shape, x, y, z, nx, ny, nz)
      closest = math.min(closest, avg_point_2:distance(vec3(x, y, z)))
      collision_point:set(x, y, z)
    end)
  local depth = collision_point:distance(avg_point)
  -- calculate volume center
  local volume_center = lovr.math.newVec3()
  avg_point_2 = vec3(avg_point)
  depth_vec:normalize()
  local rotation = quat(depth_vec)
  avg_point_2:add(depth_vec:mul(depth / 2))
  volume_center = avg_point_2:mul(vec3(1, .5, 1)) -- set volume centerbto be avg_p_2 with half the height


  lovr.graphics.setColor(0, 1, 1)
  lovr.graphics.sphere(volume_center, 0.03)
  local width = diff_bckp:length()

  lovr.graphics.box("line", volume_center, width, height, depth, rotation)
  if lovr.headset.wasPressed("right", 'trigger') then
    local volume = world:newBoxCollider((volume_center), width, height, depth)
    volume:setKinematic(true)
    volume:setOrientation(rotation)
    table.insert(volumes, volume)
  end

end

function drawAxesAndBounds()
  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.line(0, 0, 0, 1, 0, 0)
  lovr.graphics.setColor(0, 0, 1)
  lovr.graphics.line(0, 0, 0, 0, 1, 0)
  lovr.graphics.setColor(1, 0, 0)
  lovr.graphics.line(0, 0, 0, 0, 0, 1)

  local width, height = lovr.headset.getBoundsDimensions()
  lovr.graphics.setColor(0.1, 0.1, 0.11)
  lovr.graphics.box("line", 0, 0, 0, width, .05, height)

  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.box("line", width / 2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", -width / 2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", 0, 2, height / 2, width, 4, 0.1)
  lovr.graphics.box("line", 0, 2, -height / 2, width, 4, 0.1)

end