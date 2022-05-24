// Task G - Fragment Shader Lighting
// This task involved copying and pasting the original lighting code found in the vertex shader cont..
// .. whilst making small additions to allow the fragment shader to grab variables from the vertex shader.
// Copied variables from vertex shader
uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 ModelView;
uniform mat4 Projection;
uniform float Shininess;

// First light position
uniform vec4 LightPosition;
// Task I - Second light position
uniform vec4 LightPosition2;
// Task J - Spotlight position
uniform vec4 LightPosition3;

// Task B - Object Rotate
// Link texScale to shader
uniform float texScale;

vec4 color;

// Vertex variables for fragment shader to utilize
varying vec2 texCoord; 
varying vec4 position;
varying vec3 norm;

uniform sampler2D texture;

// Values needed to create spotlight
uniform vec3 spotLightDirection;
uniform float cutOff;
float attenuation3;

void main()
{
    vec3 pos = (ModelView * position).xyz;
    
    // Vector from first light from the fragment    
    vec3 Lvec = LightPosition.xyz - pos;
    // Vector from second light to fragment
    vec3 Lvec2 = LightPosition2.xyz - pos;
    // Vector from Spotlight to fragment
    vec3 Lvec3 = LightPosition3.xyz - pos;

    vec3 L = normalize( Lvec );   // Direction to the light source
    vec3 L2 = normalize( Lvec2 ); // Direction to second light source
    vec3 L3 = normalize( Lvec3 ); // Direction to Spotlight
    vec3 E = normalize( -pos );   // Direction to the eye/camera
    vec3 H = normalize( L + E );  // Halfway vector for first light
    vec3 H2 = normalize( L2 + E );  // Halfway vector for second light
    vec3 H3 = normalize( L3 + E );  // Halfway vector for Spotlight
    // Transform vertex normal into eye coordinates (assumes scaling
    // is uniform across dimensions)
    vec3 N = normalize( (ModelView*vec4(norm, 0.0)).xyz );

    // Compute terms in the illumination equation
    vec3 ambient = AmbientProduct;

    float Kd = max( dot(L, N), 0.0 );
    vec3  diffuse = Kd * DiffuseProduct;

    float Kd2 = max( dot(L2, N), 0.0 );
    vec3  diffuse2 = Kd2 * DiffuseProduct;

    float Kd3 = max( dot(L3, N), 0.0 );
    vec3  diffuse3 = Kd3 * DiffuseProduct;

    float Ks = pow( max(dot(N, H), 0.0), Shininess );
    vec3  specular = Ks * SpecularProduct;

    float Ks2 = pow( max(dot(N, H2), 0.0), Shininess );
    vec3  specular2 = Ks * SpecularProduct;

    float Ks3 = pow( max(dot(N, H3), 0.0), Shininess );
    vec3  specular3 = Ks3 * SpecularProduct;

    if (dot(L, N) < 0.0 ) {
	    specular = vec3(0.0, 0.0, 0.0);
    } 

    if (dot(L2, N) < 0.0 ) {
	    specular2 = vec3(0.0, 0.0, 0.0);
    } 

    if (dot(L3, N) < 0.0 ) {
	    specular3 = vec3(0.0, 0.0, 0.0);
    } 

    // GlobalAmbient is independent of distance from the light source
    vec3 globalAmbient = vec3(0.1, 0.1, 0.1);

    // Task F - Light Reduction
    // find distance from light to vector
    // calculate attenuation using quadratic formula
    // constant of 0.075 was chosen as it looked similar to sample solution, however more experimentation could likely give a closer solution
    // multiply all lighting (except globalAmbient) by attenuation factor
    // Task H - Shine
    // Removed + specular from color.rgb calculation.
    float dist = length(Lvec);
    float attenuation = (1.0 / (0.075 + 0.075 * dist + 0.075 * dist * dist));

    // Task I - Light2
    // Calculate attenuation for second light
    float dist2 = length(Lvec2);
    float attenuation2 = (1.0 / (0.075 + 0.075 * dist2 + 0.075 * dist2 * dist2));

    // Task J - SpotLight
    // Spotlight not fully functional, additionally rotates based on camera movement.
    // Theta calulcation taken from (https://learnopengl.com/Lighting/Light-casters)
    float theta = dot(L3, normalize( - spotLightDirection ));

    if (theta > cutOff) {
        // Calculate attenuation for spotLight
        float dist3 = length(Lvec3);
        attenuation3 = (1.0 / (0.075 + 0.075 * dist3 + 0.075 * dist3 * dist3));
    }
    else
        attenuation3 = 0.0;

    color.rgb = globalAmbient  + ((ambient + diffuse) * attenuation) + ((ambient + diffuse2) * attenuation2) + ((ambient + diffuse3) * attenuation3);
    color.a = 1.0;

    // Task B - Object Rotate
    // Added texScale to multiply texCoords
    // Task H - Shine
    // Specular shine always shines to white, added specular calculation outside of texture and color calculation cont..
    // .. to allow for specular shine to be calculated individually so not to take into account the texture nor color.
    gl_FragColor = (color * texture2D( texture, texCoord * 2.0 * texScale) + vec4(specular * attenuation, 1.0) + vec4(specular2 * attenuation, 1.0) + vec4(specular3 * attenuation, 1.0));
}
