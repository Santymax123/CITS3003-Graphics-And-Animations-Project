vec4 color;
//Vertex variables for fragment shader to utilize
varying vec2 texCoord; 
varying vec4 position;
varying vec3 norm;

uniform sampler2D texture;

uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 ModelView;
uniform mat4 Projection;
uniform float Shininess;
uniform vec4 LightPosition;

//task B
uniform float texScale;

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

    //task F
    //calculate distance from light to object
    //Light drop off after a set distance (0.05) for this example
    float dist = 0.05 + length(Lvec);

    color.rgb = globalAmbient + ((ambient + diffuse + specular) / dist);
    color.a = 1.0;

    //Task B - added * texScale
    gl_FragColor = (color * texture2D( texture, texCoord * 2.0 * texScale));
}