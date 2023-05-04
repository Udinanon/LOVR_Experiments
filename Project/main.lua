local Stereo = require("Stereo")
---
ANDROID = lovr.system.getOS() == 'Android'

local function draw(pass)
  pass:setShader('normal')
  pass:monkey(0, 1.7, -2)
  pass:cube(1,1, 1)
end

function lovr.load()
  Stereo:init()
end

function lovr.update(dt)
  Stereo:setHeadPose(lovr.headset.getPose())
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
