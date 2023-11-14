// https://lovr.org/docs/v0.16.0/Simple_Lighting

Constants {
    vec4 ambience;
    vec4 lightColor;
    vec3 lightPos;
    float specularStrength;
    int metallic;
    
    float time;
};

vec4 lovrmain(){
    //diffuse
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - PositionWorld);
    float diff = max(dot(norm, lightDir), 0.0);
    vec4 diffuse = diff * lightColor;

    //specular
    vec3 viewDir = normalize(CameraPositionWorld - PositionWorld);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), metallic);
    vec4 specular = specularStrength * spec * lightColor;

    vec4 baseColor = Color * getPixel(ColorTexture, UV);
    return baseColor * (ambience + diffuse + specular);
}