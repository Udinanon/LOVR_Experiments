
#define VERTEX VERTEX 
#define MAX_BONES 48 
#define MAX_DRAWS 256 
#define lovrView lovrViews[lovrViewID] 
#define lovrProjection lovrProjections[lovrViewID] 
#define lovrModel lovrModels[lovrDrawID] 
#define lovrTransform (lovrView * lovrModel) 
#ifdef FLAG_uniformScale 
#define lovrNormalMatrix mat3(lovrModel) 
#else 
#define lovrNormalMatrix mat3(transpose(inverse(lovrModel))) 
#endif 
#define lovrPoseMatrix (
  lovrPose[lovrBones[0]] * lovrBoneWeights[0] +
  lovrPose[lovrBones[1]] * lovrBoneWeights[1] +
  lovrPose[lovrBones[2]] * lovrBoneWeights[2] +
  lovrPose[lovrBones[3]] * lovrBoneWeights[3]
  ) 
#ifdef FLAG_animated 
  #define lovrVertex (lovrPoseMatrix * vec4(lovrPosition, 1.)) 
#else 
  #define lovrVertex vec4(lovrPosition, 1.) 
#endif 

precision highp float; 
precision highp int; 
in vec3 lovrPosition; 
in vec3 lovrNormal; 
in vec2 lovrTexCoord; 
in vec4 lovrVertexColor; 
in vec4 lovrTangent; 
in uvec4 lovrBones; 
in vec4 lovrBoneWeights; 
in uint lovrDrawID; 
out vec2 texCoord; 
out vec4 vertexColor; 
out vec4 lovrGraphicsColor; 

layout(std140) uniform lovrModelBlock { mat4 lovrModels[MAX_DRAWS]; }; 
layout(std140) uniform lovrColorBlock { vec4 lovrColors[MAX_DRAWS]; }; 
layout(std140) uniform lovrFrameBlock { mat4 lovrViews[2]; mat4 lovrProjections[2]; }; 

uniform mat3 lovrMaterialTransform; 
uniform float lovrPointSize; 
uniform mat4 lovrPose[MAX_BONES]; 
uniform lowp int lovrViewportCount; 

#if defined MULTIVIEW 
  layout(num_views = 2) in; 
  #define lovrViewID (int(gl_ViewID_OVR)) 
  #define lovrInstanceID gl_InstanceID 
#elif defined INSTANCED_STEREO 
  #define lovrViewID gl_ViewportIndex 
  #define lovrInstanceID (gl_InstanceID / lovrViewportCount) 
#else 
  uniform lowp int lovrViewID; 
  #define lovrInstanceID gl_InstanceID 
#endif 

#line 0 

// lovrShaderVertexSuffix 
void main() { 
  texCoord = (lovrMaterialTransform * vec3(lovrTexCoord, 1.)).xy; 
  vertexColor = lovrVertexColor; 
  lovrGraphicsColor = lovrColors[lovrDrawID]; 
#if defined INSTANCED_STEREO 
  gl_ViewportIndex = gl_InstanceID % lovrViewportCount; 
#endif 
  gl_PointSize = lovrPointSize; 
  gl_Position = position(lovrProjection, lovrTransform, lovrVertex); 
};

// lovrShaderFragmentPrefix 
#define PIXEL PIXEL 
#define FRAGMENT FRAGMENT 
#define lovrTexCoord texCoord 
#define lovrVertexColor vertexColor 
#ifdef FLAG_highp 
precision highp float; 
precision highp int; 
#else 
precision mediump float; 
precision mediump int; 
#endif 
in vec2 texCoord; 
in vec4 vertexColor; 
in vec4 lovrGraphicsColor; 
out vec4 lovrCanvas[gl_MaxDrawBuffers]; 
uniform float lovrMetalness; 
uniform float lovrRoughness; 
uniform vec4 lovrDiffuseColor; 
uniform vec4 lovrEmissiveColor; 
uniform sampler2D lovrDiffuseTexture; 
uniform sampler2D lovrEmissiveTexture; 
uniform sampler2D lovrMetalnessTexture; 
uniform sampler2D lovrRoughnessTexture; 
uniform sampler2D lovrOcclusionTexture; 
uniform sampler2D lovrNormalTexture; 
uniform lowp int lovrViewportCount; 
#if defined MULTIVIEW 
#define lovrViewID gl_ViewID_OVR 
#elif defined INSTANCED_STEREO 
#define lovrViewID gl_ViewportIndex 
#else 
uniform lowp int lovrViewID; 
#endif 
#ifdef MULTIVIEW 
#define sampler2DMultiview sampler2DArray 
vec4 textureMultiview(sampler2DMultiview t, vec2 uv) { 
  return texture(t, vec3(uv, lovrViewID)); 
} 
#else 
#define sampler2DMultiview sampler2D 
vec4 textureMultiview(sampler2DMultiview t, vec2 uv) { 
  uv = clamp(uv, 0., 1.) * vec2(.5, 1.) + vec2(lovrViewID) * vec2(.5, 0.); 
  return texture(t, uv); 
} 
#endif 
#line 0 ;

// lovrShaderFragmentSuffix 
void main() { 
#if defined(MULTICANVAS) || defined(FLAG_multicanvas) 
  colors(lovrGraphicsColor, lovrDiffuseTexture, texCoord); 
#else 
  lovrCanvas[0] = color(lovrGraphicsColor, lovrDiffuseTexture, lovrTexCoord); 
#ifdef FLAG_alphaCutoff 
  if (lovrCanvas[0].a < FLAG_alphaCutoff) { 
    discard; 
  } 
#endif 
#if defined(LOVR_WEBGL) || defined(LOVR_USE_PICO)
  lovrCanvas[0].rgb = pow(lovrCanvas[0].rgb, vec3(.4545)); 
#endif
#endif 
};

#ifdef LOVR_GLES
// lovrShaderComputePrefix 
#version 310 es 
#line 0 
#else
// lovrShaderComputePrefix 
#version 330 
#extension GL_ARB_compute_shader : enable 
#extension GL_ARB_shader_storage_buffer_object : enable 
#extension GL_ARB_shader_image_load_store : enable 
#line 0 
#endif

// lovrShaderComputeSuffix
void main() { 
  compute(); 
};

// lovrUnlitVertexShader
vec4 position(mat4 projection, mat4 transform, vec4 vertex) { 
  return lovrProjection * lovrTransform * lovrVertex; 
};

// lovrUnlitFragmentShader
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) { 
  return lovrGraphicsColor * lovrVertexColor * lovrDiffuseColor * texture(lovrDiffuseTexture, lovrTexCoord); 
};

// lovrStandardVertexShader
out vec3 vVertexPositionWorld; 
out vec3 vCameraPositionWorld; 
#ifdef FLAG_normalMap 
out mat3 vTangentMatrix; 
#else 
out vec3 vNormal; 
#endif 

vec4 position(mat4 projection, mat4 transform, vec4 vertex) { 
  vVertexPositionWorld = vec3(lovrModel * lovrVertex); 
  vCameraPositionWorld = -lovrView[3].xyz * mat3(lovrView); 
#ifdef FLAG_normalMap 
  vec3 normal = normalize(lovrNormalMatrix * lovrNormal); 
  vec3 tangent = normalize(lovrNormalMatrix * lovrTangent.xyz); 
  vec3 bitangent = cross(normal, tangent) * lovrTangent.w; 
  vTangentMatrix = mat3(tangent, bitangent, normal); 
#else 
  vNormal = normalize(lovrNormalMatrix * lovrNormal); 
#endif 
  return lovrProjection * lovrTransform * lovrVertex; 
};

// lovrStandardFragmentShader 
#define PI 3.14159265358979 
#if defined(GL_ES) && !defined(FLAG_highp) 
#define EPS 1e-4 
#else 
#define EPS 1e-8 
#endif 

in vec3 vVertexPositionWorld; 
in vec3 vCameraPositionWorld; 
#ifdef FLAG_normalMap 
in mat3 vTangentMatrix; 
#else 
in vec3 vNormal; 
#endif 

uniform vec3 lovrLightDirection; 
uniform vec4 lovrLightColor; 
uniform samplerCube lovrEnvironmentMap; 
uniform vec3 lovrSphericalHarmonics[9]; 
uniform float lovrExposure; 

float D_GGX(float NoH, float roughness); 
float G_SmithGGXCorrelated(float NoV, float NoL, float roughness); 
vec3 F_Schlick(vec3 F0, float VoH); 
vec3 E_SphericalHarmonics(vec3 sh[9], vec3 n); 
vec2 prefilteredBRDF(float NoV, float roughness); 
vec3 tonemap_ACES(vec3 color); 

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) { 
  vec3 result = vec3(0.); 

// Parameters
  vec3 baseColor = texture(lovrDiffuseTexture, lovrTexCoord).rgb * lovrDiffuseColor.rgb; 
  float metalness = texture(lovrMetalnessTexture, lovrTexCoord).b * lovrMetalness; 
  float roughness = max(texture(lovrRoughnessTexture, lovrTexCoord).g * lovrRoughness, .05); 
#ifdef FLAG_normalMap 
  vec3 N = normalize(vTangentMatrix * (texture(lovrNormalTexture, lovrTexCoord).rgb * 2. - 1.)); 
#else 
  vec3 N = normalize(vNormal); 
#endif 
  vec3 V = normalize(vCameraPositionWorld - vVertexPositionWorld); 
  vec3 L = normalize(-lovrLightDirection); 
  vec3 H = normalize(V + L); 
  vec3 R = normalize(reflect(-V, N)); 
  float NoV = abs(dot(N, V)) + EPS; 
  float NoL = clamp(dot(N, L), 0., 1.); 
  float NoH = clamp(dot(N, H), 0., 1.); 
  float VoH = clamp(dot(V, H), 0., 1.); 

// Direct lighting
  vec3 F0 = mix(vec3(.04), baseColor, metalness); 
  float D = D_GGX(NoH, roughness); 
  float G = G_SmithGGXCorrelated(NoV, NoL, roughness); 
  vec3 F = F_Schlick(F0, VoH); 
  vec3 specularDirect = vec3(D * G * F); 
  vec3 diffuseDirect = (vec3(1.) - F) * (1. - metalness) * baseColor; 
  result += (diffuseDirect / PI + specularDirect) * NoL * lovrLightColor.rgb * lovrLightColor.a; 

// Indirect lighting
#ifdef FLAG_indirectLighting 
  vec2 lookup = prefilteredBRDF(NoV, roughness); 
  float mipmapCount = log2(float(textureSize(lovrEnvironmentMap, 0).x)); 
  vec3 specularIndirect = (F0 * lookup.r + lookup.g) * textureLod(lovrEnvironmentMap, R, roughness * mipmapCount).rgb; 
  vec3 diffuseIndirect = diffuseDirect * E_SphericalHarmonics(lovrSphericalHarmonics, N); 
#ifdef FLAG_occlusion  // Occlusion only affects indirect diffuse light
  diffuseIndirect *= texture(lovrOcclusionTexture, lovrTexCoord).r; 
#endif 
  result += diffuseIndirect + specularIndirect; 
#endif 

// Emissive
#ifdef FLAG_emissive  // Currently emissive texture and color have to be used together
  result += texture(lovrEmissiveTexture, lovrTexCoord).rgb * lovrEmissiveColor.rgb; 
#endif 

// Tonemap
#ifndef FLAG_skipTonemap 
  result = tonemap_ACES(result * lovrExposure); 
#endif 

  return lovrGraphicsColor * vec4(result, 1.); 
}

// Helpers
float D_GGX(float NoH, float roughness) { 
  float alpha = roughness * roughness; 
  float alpha2 = alpha * alpha; 
  float denom = (NoH * NoH) * (alpha2 - 1.) + 1.; 
  return alpha2 / max(PI * denom * denom, EPS); 
} 

float G_SmithGGXCorrelated(float NoV, float NoL, float roughness) { 
  float alpha = roughness * roughness; 
  float alpha2 = alpha * alpha; 
  float GGXV = NoL * sqrt(alpha2 + (1. - alpha2) * (NoV * NoV)); 
  float GGXL = NoV * sqrt(alpha2 + (1. - alpha2) * (NoL * NoL)); 
  return .5 / max(GGXV + GGXL, EPS); 
} 

vec3 F_Schlick(vec3 F0, float VoH) { 
  return F0 + (vec3(1.) - F0) * pow(1. - VoH, 5.); 
} 

vec3 E_SphericalHarmonics(vec3 sh[9], vec3 n) { 
  n = -n; 
  return max(
    sh[0] + 
    sh[1] * n.y + 
    sh[2] * n.z + 
    sh[3] * n.x + 
    sh[4] * n.y * n.x + 
    sh[5] * n.y * n.z + 
    sh[6] * (3. * n.z * n.z - 1.) + 
    sh[7] * n.z * n.x + 
    sh[8] * (n.x * n.x - n.y * n.y)
  , 0.); 
} 

// https://www.unrealengine.com/en-US/blog/physically-based-shading-on-mobile
vec2 prefilteredBRDF(float NoV, float roughness) { 
  vec4 c0 = vec4(-1., -.0275, -.572, .022); 
  vec4 c1 = vec4(1., .0425, 1.04, -.04); 
  vec4 r = roughness * c0 + c1; 
  float a004 = min(r.x * r.x, exp2(-9.28 * NoV)) * r.x + r.y; 
  return vec2(-1.04, 1.04) * a004 + r.zw; 
} 

vec3 tonemap_ACES(vec3 x) { 
  float a = 2.51; 
  float b = 0.03; 
  float c = 2.43; 
  float d = 0.59; 
  float e = 0.14; 
  return (x * (a * x + b)) / (x * (c * x + d) + e); 
};

// lovrCubeVertexShader
out vec3 texturePosition[2]; 
vec4 position(mat4 projection, mat4 transform, vec4 vertex) { 
  texturePosition[lovrViewID] = inverse(mat3(lovrTransform)) * (inverse(lovrProjection) * lovrVertex).xyz; 
  return lovrVertex; 
};

// lovrCubeFragmentShader
in vec3 texturePosition[2]; 
uniform samplerCube lovrSkyboxTexture; 
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) { 
  return lovrGraphicsColor * texture(lovrSkyboxTexture, texturePosition[lovrViewID] * vec3(-1, 1, 1)); 
};

// lovrPanoFragmentShader
in vec3 texturePosition[2]; 
#define PI 3.141592653589 
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) { 
  vec3 direction = texturePosition[lovrViewID]; 
  float theta = acos(-direction.y / length(direction)); 
  float phi = atan(direction.x, -direction.z); 
  vec2 cubeUv = vec2(.5 + phi / (2. * PI), theta / PI); 
  return lovrGraphicsColor * texture(lovrDiffuseTexture, cubeUv); 
};

// lovrFontFragmentShader
uniform vec2 lovrSdfRange; 
float screenPxRange() { 
  vec2 screenTexSize = vec2(1.) / fwidth(lovrTexCoord); 
  return max(.5 * dot(lovrSdfRange, screenTexSize), 1.); 
} 
float median(float r, float g, float b) { 
  return max(min(r, g), min(max(r, g), b)); 
} 
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) { 
  vec3 msd = texture(lovrDiffuseTexture, lovrTexCoord).rgb; 
  float sd = median(msd.r, msd.g, msd.b); 
  float screenPxDistance = screenPxRange() * (sd - .5); 
  float alpha = clamp(screenPxDistance + .5, 0., 1.); 
  if (alpha <= 0.0) discard; 
  return vec4(lovrGraphicsColor.rgb, lovrGraphicsColor.a * alpha); 
};

// lovrFillVertexShader
vec4 position(mat4 projection, mat4 transform, vec4 vertex) { 
  return lovrVertex; 
};

// lovrShaderScalarUniforms[] = {
  lovrMetalness,
  lovrRoughness
};

// lovrShaderColorUniforms[] = {
  lovrDiffuseColor,
  lovrEmissiveColor
};

// lovrShaderTextureUniforms[] = {
  lovrDiffuseTexture,
  lovrEmissiveTexture,
  lovrMetalnessTexture,
  lovrRoughnessTexture,
  lovrOcclusionTexture,
  lovrNormalTexture
};

// lovrShaderAttributeNames[] = {
  lovrPosition,
  lovrNormal,
  lovrTexCoord,
  lovrVertexColor,
  lovrTangent,
  lovrBones,
  lovrBoneWeights
};
