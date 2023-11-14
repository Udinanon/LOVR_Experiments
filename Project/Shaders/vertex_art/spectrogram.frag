// //Code based on "history-fs" https://github.com/greggman/vertexshaderart/blob/fa9fd45af8e5ec102ba7472357f0bb170f6aad9d/src/js/shaders.js#L320

precision mediump float;
/*
 * Copyright 2014, Gregg Tavares.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Gregg Tavares. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

 // thanks gregg this is very cool

//  "vs-header": `

// Header for the vertex shaders
// might want to make one for the fragment
// also how do i avoid the issue of PI being redesigned? maybe a custom lovr.glsl? would need a custom compile funciton tho
/*

attribute float vertexId;

uniform vec2 mouse;
uniform vec2 resolution;
uniform vec4 background;
uniform float time;
uniform float vertexCount;
uniform sampler2D volume;
uniform sampler2D sound;
uniform sampler2D floatSound;
uniform sampler2D touch;
uniform vec2 soundRes;
uniform float _dontUseDirectly_pointSize;

varying vec4 v_color;
*/
  // ===========================================================

//layout(location = 0) out vec4 v_color; // To push it to the fragment

// these are passed from Lua
Constants {
    uniform vec2 mouse;
    uniform vec2 resolution;
    uniform vec4 background;
    uniform float time;
    uniform float vertexCount;
    uniform vec2 soundRes;
    uniform float _dontUseDirectly_pointSize;

};

//layout(set = 2, binding = 0) uniform sampler touch;
layout(set = 2, binding = 0) uniform texture2D touch;
layout(set = 2, binding = 1) uniform texture2D volume;
layout(set = 2, binding = 2) uniform texture2D sound;
layout(set = 2, binding = 3) uniform texture2D floatSound;

// this is to make it compatible in syntax
//float vertexId = gl_VertexIndex;

/*    
var _historyUniforms = {
  u_mix: 0,
  u_mult: 1,
  u_matrix: m4.identity(),
  u_texture: undefined,
};
*/
//uniform float u_mix;
//uniform float u_mult;

// sound texture ????
// uniform sampler2D u_texture;
//layout(set = 2, binding = 2) uniform texture2D sound;

// passed from vertex_shader 
//varying vec2 v_texcoord;
//layout(location = 0) in vec2 v_texcoord;

vec4 lovrmain() {
    return getPixel(sound, UV).aaaa;
    
}