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

    vec3 L = normalize( Lvec );   // Direction to the light source
    vec3 E = normalize( -pos );   // Direction to the eye/camera
    vec3 H = normalize( L + E );  // Halfway vector

    vec3 N = normalize( (ModelView*vec4(norm, 0.0)).xyz );

    // Compute terms in the illumination equation
    vec3 ambient = AmbientProduct;

    float Kd = max( dot(L, N), 0.0 );
    vec3  diffuse = Kd*DiffuseProduct;

    float Ks = pow( max(dot(N, H), 0.0), Shininess );
    vec3  specular = Ks * SpecularProduct;


    if (dot(L, N) < 0.0 ) {
	specular = vec3(0.0, 0.0, 0.0);
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
    color.rgb = globalAmbient  + (ambient + diffuse) * attenuation;
    color.a = 1.0;

    //task B - Object Rotate
    //multiply texture by texScale
    // Task H - Shine
    //Specular shine always shines to white, added specular calculation outside of texture and color calculation cont..
    // .. to allow for specular shine to be calculated individually so not to take into account the texture nor color.
    gl_FragColor = (color * texture2D( texture, texCoord * 2.0 * texScale)) + vec4(specular * attenuation, 1.0);
}
