out vec4 v_color;

Constants {
  uniform float vertexCount;
  uniform float time;
  uniform vec2 resolution;
};

#define NUM_SEGMENTS 2.0
#define NUM_POINTS (NUM_SEGMENTS * 2.0)
#define STEP 1.0

vec4 lovrmain() {
  float vertexId = gl_VertexIndex;

  float point = mod(floor(vertexId / 2.0) + mod(vertexId, 2.0) * STEP, NUM_SEGMENTS);
  float count = floor(vertexId / NUM_POINTS);
  float offset = count * sin(time * 0.01) + 5.0;
  float angle = point * PI * 2.0 / NUM_SEGMENTS + offset;
  float radius = pow(count * 0.00014, 1.0);
  float c = cos(angle + time) * radius;
  float s = sin(angle + time) * radius;
  float orbitAngle =  pow(count * 0.025, 0.8);
  float innerRadius = pow(count * 0.0005, 1.2);
  float oC = cos(orbitAngle + count * 0.0001) * innerRadius;
  float oS = sin(orbitAngle + count * 0.0001) * innerRadius;

  vec2 aspect = vec2(1, resolution.x / resolution.y);
  vec2 xy = vec2(
      oC + c,
      oS + s);

  float b = 1.0 - pow(sin(count * 0.4) * 0.5 + 0.5, 10.0);
  b = 0.0;mix(0.0, 0.7, b);
  v_color = vec4(b, b, b, 1);
  vec4 position = vec4(xy * aspect, 0, 1);
  return position;
}

/*
for some reason the result is in screenspace, maybe we need to take the result and do some trasformation on it

the original code seems to be pretty think on WebGL, so if itìs compatible with OpenGL as it seems we might have not too much work left
the code is split between the shaders.js, the mian.js and the twgl.js files, hidden and shittified by unclear commands. a lot of it us just oushing stuff to openGL
i still don't know how many vertices it uses aor needs and how to supply them exactly, but it works and that's alredy good
*/