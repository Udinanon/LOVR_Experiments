// edited from Stereo.glsl and some inspiration from https://git.ffmpeg.org/gitweb/ffmpeg.git/blob/b725202546da366772dec1ada40ce36832582ed9:/libavfilter/vf_stereo3d.c
layout(set = 2, binding = 0) uniform texture2DArray canvas;

vec4 lovrmain() {
    // Matrix values from https://stackoverflow.com/questions/66404340/how-are-dubois-anaglyph-matrices-calculated
    vec3 RC_Dubois[3][2] =
    {{{0.45610004,  0.50048381,  0.17638087}, {-0.0434706,  -0.08793882, -0.00155529}},
    {{-0.04008216, -0.03782458, -0.01575895},  {0.37847603,  0.73363998, -0.01845032}},
    {{-0.01521607, -0.02059714, -0.00546856}, {-0.07215268, -0.11296065,  1.2263951}}};
    
    
    // the matrix is 0-65536, might want to either rescale or something
//    {{{29891, 32800, 11559}, {-2849, -5763,  -102}}, // r
//     {{-2627, -2479, -1033}, {24804, 48080, -1209}}, // g
//     {{-997, -1350,  -358}, {-4729, -7403, 80373}}}; // b
    vec2 eyeUV = UV * vec2(2, 1);
    float eyeIndex = floor(UV.x * 2.);
    vec3 lEye = getPixel(canvas, UV, 0).rgb;
    vec3 rEye = getPixel(canvas, UV, 1).rgb;
    vec4 outColor = vec4(1);
    outColor.r = dot(lEye, RC_Dubois[0][0]) + dot(rEye, RC_Dubois[0][1]);  
    outColor.g = dot(lEye, RC_Dubois[1][0]) + dot(rEye, RC_Dubois[1][1]);  
    outColor.b = dot(lEye, RC_Dubois[2][0]) + dot(rEye, RC_Dubois[2][1]);  

    //getPixel(canvas, eyeUV, eyeIndex)
    return Color * outColor;
}