//Code based on "history-vs" https://github.com/greggman/vertexshaderart/blob/fa9fd45af8e5ec102ba7472357f0bb170f6aad9d/src/js/shaders.js#L304C26-L304C26


/*    
s.quadBufferInfo = twgl.createBufferInfoFromArrays(gl, {
  position: { numComponents: 2, data: [-1, -1, 1, -1, -1, 1, 1, 1] },
  texcoord: [0, 0, 1, 0, 0, 1, 1, 1],
  indices: [0, 1, 2, 2, 1, 3],
});
      */
//attribute vec2 texcoord;
//attribute vec4 position;

/*    
var _historyUniforms = {
  u_mix: 0,
  u_mult: 1,
  u_matrix: m4.identity(),
  u_texture: undefined,
};
*/
//uniform mat4 u_matrix;

// passed to frag_sahder
//varying vec2 v_texcoord;

vec4 lovrmain() {
  //v_texcoord = texcoord;
  return vec4(0, 0, 0, 0);
  //return u_matrix * position;
}