uniform vec4 ambience;  
uniform vec4 lightColor;

in vec3 Normal;
in vec3 FragmentPos;

vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
{    
    //diffuse
    vec3 norm = normalize(Normal);
    vec4 diffuse = vec4(0.0);
    for( int i = 0; i < lightPos.length(); i++){
        if (lightPos[i][0] > 0.){
        vec3 pos = lightPos[i].yzw;  
        vec3 lightDir = normalize(pos - FragmentPos); // unit vector of vertex-light  
        float diff = max(dot(norm, lightDir), 0.0); // represent how exposes the fragment is
        diffuse += diff * lightColor; //apply to color
        }
    }
    vec4 baseColor = graphicsColor * texture(image, uv); // get potential texture            
    return baseColor * (ambience + diffuse); //apply ligth and ambiance
}