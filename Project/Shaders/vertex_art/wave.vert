vec3 hsv2rgb(vec3 c) {
  c = vec3(c.x, clamp(c.yz, 0.0, 1.0));
  vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
  vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
  return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float select(float v, float t) {
  return step(t * 0.9, v) * step(v, t * 1.1);
}

void main() {
  float GRID_YOFF = 1./40.;
  float GRID_DOWN = 17.;
  float GRID_ACROSS = 64.0;
  float NUM_PER_DOWN = GRID_DOWN * 2.;
  float NUM_PER_ACROSS = GRID_ACROSS * 2.;
  float NUM_PER_GRID = NUM_PER_DOWN + NUM_PER_ACROSS;
  float NUM_GRIDS = 4.;
  float NUM_GRID_TOTAL = NUM_PER_GRID * NUM_GRIDS;
  float NUM_POINTS = (vertexCount - NUM_GRID_TOTAL) / 4.;
  float NUM_SEGMENTS = NUM_POINTS / 2.;


  float id = vertexId - NUM_GRID_TOTAL;

  // produces 0,1, 1,2, 2,3, ...
  float point = floor(mod(id, NUM_POINTS) / 2.0) + mod(id, 2.0);
  // line count
  float grid = floor(id / NUM_POINTS);

  float u = point / (NUM_SEGMENTS - 1.);    // 0 <-> 1 across line
  float v = grid / NUM_GRIDS;      // 0 <-> 1 by line

  float snd0 = texture2D(sound, vec2(u * 1., 0)).a;
  float snd1 = texture2D(sound, vec2(u * 0.5, 0)).a;
  float snd2 = texture2D(sound, vec2(u * 0.25, 0)).a;
  float snd3 = texture2D(sound, vec2(u * 0.125, 0)).a;

  float s =
    snd0 * select(grid, 0.) +
    snd1 * select(grid, 1.) +
    snd2 * select(grid, 2.) +
    snd3 * select(grid, 3.) +
    0.;

  float x = u * 2.0 - 1.0;
  float y = v * 2.0 - 1.0;
  vec2 xy = vec2(
      x,
      s * 0.4 + y + GRID_YOFF);
  gl_Position = vec4(xy, 0, 1);

  float hue = grid * 0.25;
  float sat = 1.0;
  float val = 1.0;

  if (id < 0.0) {
    if (vertexId < NUM_PER_DOWN * NUM_GRIDS) {
      float hgx = mod(vertexId, 2.0);
      float hgy = mod(floor(vertexId / 2.), GRID_DOWN);
      float hgId = floor(vertexId / NUM_PER_DOWN);
      gl_Position = vec4(
        hgx * 2. - 1.,
        hgy / (GRID_DOWN - 1.) * 0.4 +
        (hgId / NUM_GRIDS * 2. - 1.) + GRID_YOFF,
        0.1,
        1);

      hue = hgId * 0.25;
      sat = 0.5;
      val = 0.3;
    } else {
      float vid = vertexId - NUM_PER_DOWN * NUM_GRIDS;
      float vgy = mod(vid, 2.0);
      float vgx = mod(floor(vid / 2.), GRID_ACROSS);
      float vgId = floor(vid / NUM_PER_ACROSS);
      gl_Position = vec4(
        ((vgx / GRID_ACROSS) * 2. - 1.) * pow(2., vgId),
        vgy * 0.4 +
        (vgId / NUM_GRIDS * 2. - 1.) + GRID_YOFF,
        0.1,
        1);

      hue = vgId * 0.25;
      sat = 0.5;
      val = 0.3;

    }
  }

  v_color = vec4(hsv2rgb(vec3(hue, sat, val)), 1);
}
