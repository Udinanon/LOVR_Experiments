---@diagnostic disable: deprecated, redundant-parameter



-- run on boot of the program, where all the setup happes
function lovr.load()
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  walls = 0
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal ()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end
  utah ={ 
    model = lovr.graphics.newModel("utah.stl"),
    position = lovr.math.newVec3(0.0),
    velocity = lovr.math.newVec3(0.0),
    k1 = 1.0,
    k2 = 2.0,
    k3 = 3.0,
    graph = nil
  }

  console = {
    position = lovr.math.newVec3(),
    visible = false,
    size = lovr.math.newVec3(.25, .1, .25),
    knob_offset = lovr.math.newVec3(0, 0, 0.1), 
    knob_size = lovr.math.newVec3(.1, .04, 10),
    knob_rotation = nil
  }

  board = {
    position = lovr.math.newVec3(),
    pose = lovr.math.newQuat(),
    visible = false,
    size = 1.0,
    material = lovr.graphics.newMaterial()
  }

  grab = { 
    active = false,
    hand = nil,
    offset = lovr.math.newVec3(),
    in_range = false,
    base_rot = lovr.math.newQuat()
  }
  shader = lovr.graphics.newShader('unlit', {})
  lovr.graphics.setShader(shader)
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

  -- geerate the step response graph
  if utah.graph == nil then
    -- working at 90 fps we approximate to 10ms a step
    -- so 1000 values is 10s of evolution
    
    local image = lovr.data.newImage(800, 600, "rgb", nil) -- empty image
    local x = 0
    local dx = 0
    local y = 0
    local dy = 0
    local ddy = 0

    local px_zero = 500
    local px_scale = 250
    dt = 0.1 -- 10 ms ????
    for i = 0, 799 do
      -- x
      if i < 300 then
        --before the step
        image:setPixel(i, px_zero, 1, 0, 0)
      else if i == 300 then
        -- draw a nice step
          for j = px_zero, px_zero-px_scale do
            image:setPixel(i, j, 1, 0, 0)
          end
        x = 1
        dx = 1
      else
        if dx == 1 then
          dx = 0
        end
        -- after
          image:setPixel(i, px_zero - px_scale, 1, 0, 0)
      end
      end
      -- compute y
      y = y + dy * dt
      ddy = (x + dx * utah.k3 - y - dy*utah.k1)/utah.k2
      dy = dy + ddy * dt
      
      -- 0 ==  px_zero
      -- 1 ==  px_zero - 1 * px_scale
      local px_y = px_zero - y * px_scale
      px_y = math.min(math.max(px_y, 0), 600)
      image:setPixel(i, px_y, 0, 1, 0)
    end
  local texture = lovr.graphics.newTexture(image, {format= "rgb", mipmaps = false})
  utah.graph = texture
  board.material:setTexture(texture)
    
  end

  if State:isNormal() then
    -- https://www.youtube.com/watch?v=KPoeNZZ6H4s
    -- semi implicit Euler thord to integrate y + y' * k1 + y'' * k2 = x + x' * k3
    -- x is hand, y is utah
    local hand_pos = vec3(lovr.headset.getPosition("hand/right"))
    local hand_speed = vec3(lovr.headset.getVelocity("hand/right"))
    utah.position = lovr.math.newVec3(utah.position + utah.velocity*dt)
    local acceleration = lovr.math.vec3(hand_pos + hand_speed * utah.k3 - utah.position - utah.velocity * utah.k1) / utah.k2
    utah.velocity = lovr.math.newVec3(utah.velocity + acceleration*dt)

    -- just use a fuking slider jesus
    if lovr.headset.wasPressed("right", "grip") and console.visible and not grab.active then
      local knob_pos = console.position + console.knob_offset
      local offset = (knob_pos - hand_pos):length()
      if offset < 0.15 then
        grab.active = true
        grab.hand = "right"
        grab.offset:set(offset)
        local v = vec3(0, 1, 0)
        hand_conj = lovr.math.newQuat(lovr.headset.getOrientation("right")):conjugate()
        v = hand_conj:mul(v)
        angle = math.atan2(v[3], v[1])
        print("v", v)
        print("angle", angle)
      end
    end

    if grab.active then
      
      local handRotation = quat(lovr.headset.getOrientation(grab.hand))
      handRotation:mul(grab.base_rot)

      if lovr.headset.wasReleased(grab.hand, 'grip') then
        grab.active = false
      end
      local hand_pos = vec3(lovr.headset.getPosition(grab.hand))
      local knob_pos = console.position + console.knob_offset
      local offset = (knob_pos - hand_pos):length()
      if offset > 0.3 then
        grab.active = false
      end
    end

    -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
      board.visible = not board.visible
      board.position = lovr.math.newVec3(lovr.headset.getPosition("hand/left"))
      board.pose = lovr.math.newQuat(lovr.headset.getOrientation("hand/left"))
    end
    -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "grip") then
      console.visible = not console.visible
      console.position = lovr.math.newVec3(lovr.headset.getPosition("hand/left"))
      console.pose = lovr.math.newQuat(lovr.headset.getOrientation("hand/left"))
    end
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
  utah.model:draw( utah.position, .01)
  
  if board.visible then
    lovr.graphics.plane(board.material, board.position, .8, .6, board.pose)
  end

  if console.visible then
    lovr.graphics.setColor(0.6, 0.6, 0.6)
    lovr.graphics.box("fill", console.position, console.size, quat(0, 0, 1, 0))
    lovr.graphics.setColor(0.7, 0.4, 0.4)
    lovr.graphics.cylinder(console.position + console.knob_offset, console.knob_size[1], quat(0, 0, 1, 0), console.knob_size[2], console.knob_size[2], true, console.knob_size[3])
    lovr.graphics.setColor(1, 1, 1)
  end

  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local hand_quat = quat(lovr.headset.getOrientation(hand))

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
---@diagnostic disable-next-line: missing-parameter
    if State.isNormal() then
      lovr.graphics.setColor(1, 1, 1)
      lovr.graphics.sphere(position, .01)
      
      
    elseif State["A"] then
      lovr.graphics.setColor(1, 0, 0)
      lovr.graphics.sphere(position, .01)

    end
  end
  
  


  -- draw axes
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
  lovr.graphics.box("line", width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", -width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", 0, 2, height/2, width, 4, 0.1)
  lovr.graphics.box("line", 0, 2, -height/2, width, 4, 0.1)
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