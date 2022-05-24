vec4 color;
//Vertex variables for fragment shader to utilize
varying vec2 texCoord; 
varying vec4 position;
varying vec3 norm;

uniform sampler2D texture;

// Copied variables from vertex shader
uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 ModelView;
uniform mat4 Projection;
uniform float Shininess;


uniform vec4 LightPosition;

uniform vec4 LightPosition2;

uniform vec4 LightPosition3;

//task B - Object Rotate
//link texScale to shader
uniform float texScale;

// Task G - Fragment Shader Lighting
// This task involved copying and pasting the original lighting code found in the vertex shader cont..
// .. whilst making small additions to allow the fragment shader to grab variables from the vertex shader.

void main()
{
    vec3 pos = (ModelView * position).xyz;
    
    // The vector to the light from the vertex    
    vec3 Lvec = LightPosition.xyz - pos;

    vec3 Lvec2 = LightPosition2.xyz - pos;

    // The vector to the light from the vertex    
    vec3 Lvec3 = LightPosition3.xyz - pos; // Spotlight

    vec3 L = normalize( Lvec );   // Direction to the light source
    vec3 L2 = normalize( Lvec2 );  
    vec3 L3 = normalize( Lvec3 ); // Spotlight
    vec3 E = normalize( -pos );   // Direction to the eye/camera
    vec3 H = normalize( L + E );  // Halfway vector
    vec3 H2 = normalize( L2 + E );
    vec3 H3 = normalize( L3 + E );  // Halfway vector

    vec3 N = normalize( (ModelView*vec4(norm, 0.0)).xyz );

    // Compute terms in the illumination equation
    vec3 ambient = AmbientProduct;

    vec3 ambient2 = AmbientProduct;

    vec3 ambient3 = AmbientProduct; // Spotlight

    float Kd = max( dot(L, N), 0.0 );
    vec3  diffuse = Kd * DiffuseProduct;

    float Kd2 = max( dot(L2, N), 0.0 );
    vec3  diffuse2 = Kd2 * DiffuseProduct;

    float Kd3 = max( dot(L3, N), 0.0 ); // Spotlight
    vec3  diffuse3 = Kd3 * DiffuseProduct;

    float Ks = pow( max(dot(N, H), 0.0), Shininess );
    vec3  specular = Ks * SpecularProduct;

    float Ks2 = pow( max(dot(N, H2), 0.0), Shininess ); // Second Light
    vec3  specular2 = Ks2 * SpecularProduct;

    float Ks3 = pow( max(dot(N, H3), 0.0), Shininess ); // Spotlight
    vec3  specular3 = Ks3 * SpecularProduct;


    if (dot(L, N) < 0.0 ) {
	    specular = vec3(0.0, 0.0, 0.0);
    } 

    if (dot(L2, N) < 0.0 ) {
	    specular2 = vec3(0.0, 0.0, 0.0);
    } 

    if (dot(L3, N) < 0.0 ) { 
	    specular3 = vec3(0.0, 0.0, 0.0); // Spotlight
    } 

    // globalAmbient is independent of distance from the light source
    vec3 globalAmbient = vec3(0.1, 0.1, 0.1);

    //task F - Light Reduction
    //find distance from light to vector
    //calculate attenuation using quadratic formula
    //constant of 0.075 was chosen as it looked similar to sample solution, however more experimentation could likely give a closer solution
    // multiply all lighting (except globalAmbient) by attenuation factor
    // Task H - Shine
    //Removed + specular from color.rgb calculation.
    float dist = length(Lvec);
    float attenuation = (1.0 / (0.075 + 0.075 * dist + 0.075 * dist * dist));
    color.rgb = globalAmbient  + ((ambient + diffuse)  + (ambient2 + diffuse2) + (ambient3 + diffuse3)) * attenuation;
    color.a = 1.0;

    //task B - Object Rotate
    //multiply texture by texScale
    // Task H - Shine
    //Specular shine always shines to white, added specular calculation outside of texture and color calculation cont..
    // .. to allow for specular shine to be calculated individually so not to take into account the texture nor color.
    gl_FragColor = (color * texture2D( texture, texCoord * 2.0 * texScale)) + vec4(specular + specular2 + specular3 * attenuation, 1.0);
}
