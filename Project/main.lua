local mirror = {}

function mirror:init()
  self.head = lovr.math.newMat4()
  self.views = 2
  self.width = lovr.system.getWindowWidth() * .5
  self.height = lovr.system.getWindowHeight()
  self.ipd = .063
  self.fovy = .6
  self.fovx = self.fovy * (self.width / self.height)
  self.canvas = lovr.graphics.newTexture(self.width, self.height, self.views, {
    type = 'array',
    usage = { 'render', 'sample' },
    mipmaps = false
  })

  self.stereoShader = lovr.graphics.newShader('fill', [[
    layout(set = 2, binding = 0) uniform texture2DArray canvas;
    vec4 lovrmain() {
      vec2 eyeUV = UV * vec2(2, 1);
      float eyeIndex = floor(UV.x * 2.);
      return Color * getPixel(canvas, eyeUV, eyeIndex);
    }
  ]])
end

function mirror:setHeadPose(...)
  self.head:set(...)
end

function mirror:render(fn)
  local pass = lovr.graphics.getPass('render', self.canvas)

  local offset = vec3(self.ipd * .5, 0, 0)
  pass:setViewPose(1, mat4(self.head):translate(-offset))
  pass:setViewPose(2, mat4(self.head):translate(offset))

  local projection = mat4():fov(self.fovx, self.fovx, self.fovy, self.fovy, .01)
  pass:setProjection(1, projection)
  pass:setProjection(2, projection)

  fn(pass)

  return pass
end

function mirror:blit(pass)
  pass:push('state')
  pass:setShader(self.stereoShader)
  pass:send('canvas', self.canvas)
  pass:fill()
  pass:pop('state')
end

---

local function draw(pass)
  pass:setShader('normal')
  pass:monkey(0, 1.7, -2)
  pass:cube(1,1, 1)
end

function lovr.load()
  ANDROID = lovr.system.getOS() == 'Android'
  mirror:init()
end

function lovr.update(dt)
  mirror:setHeadPose(lovr.headset.getPose())
end

function lovr.draw(pass)
  if ANDROID then
    return draw(pass)
  else
    return lovr.graphics.submit(mirror:render(draw))
  end
end

function lovr.mirror(pass)
  if ANDROID then
    return true
  else
    mirror:blit(pass)
  end
end
