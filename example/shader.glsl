#version 120

uniform sampler2D tex;

// vec2 radialDistortion(vec2 coord, float dist) {
//   vec2 cc = coord - 0.5;
//   float elapsed = 1;
//   dist = dot(cc, cc) * dist + cos(elapsed * .3) * .01;
//   return (coord + cc * (1.0 + dist) * dist);
// }


// vec4 effect(sampler2D tex, vec2 tc) {
//   vec2 tcr = radialDistortion(tc, .24)  + vec2(.001, 0);
//   vec2 tcg = radialDistortion(tc, .20);
//   vec2 tcb = radialDistortion(tc, .18) - vec2(.001, 0);
//   vec4 res = vec4(texture2D(tex, tcr).r, texture2D(tex, tcg).g, texture2D(tex, tcb).b, 1)
//     - cos(tcg.y * 128. * 3.142 * 2) * .03
//     - sin(tcg.x * 128. * 3.142 * 2) * .03;
//   return res * texture2D(tex, tcg).a;
// }


// void main() {
//   if (false) {
//     // wavy    
//     float x = gl_TexCoord[0].x;
//     float y = gl_TexCoord[0].y;
//     vec2 tc = vec2(x + sin(y * 30) * 10 / 1000, y);
//   gl_FragColor = effect(tex, tc) + vec4(-.2, -.1, .1, 0);
//   } else {
//     // normal
//     vec2 tc = gl_TexCoord[0].xy;
//     gl_FragColor = effect(tex, tc) + vec4(-.2, -.1, .1, 0);
//   }
// }

// Author @patriciogv - 2015
// Title: Ikeda Data Stream

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float random(float x) {
    return fract(sin(x)*1e4);
}

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898,78.233)))* 43758.5453123);
}

float pattern(vec2 st, vec2 v, float t) {
    vec2 p = floor(st+v);
    return step(t, random(100.+p*.000001)+random(p.x)*0.5 );
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec2 grid = vec2(100.0,50.);
    st *= grid;

    vec2 ipos = floor(st);  // integer
    vec2 fpos = fract(st);  // fraction

    vec2 vel = vec2(u_time*2.*max(grid.x,grid.y)); // time
    vel *= vec2(-1.,0.0) * random(1.0+ipos.y); // direction

    // Assign a random value base on the integer coord
    vec2 offset = vec2(0.1,0.);

    vec3 color = vec3(0.);
    color.r = pattern(st+offset,vel,0.5+u_mouse.x/u_resolution.x);
    color.g = pattern(st,vel,0.5+u_mouse.x/u_resolution.x);
    color.b = pattern(st-offset,vel,0.5+u_mouse.x/u_resolution.x);

    // Margins
    color *= step(0.2,fpos.y);

    gl_FragColor = vec4(1.0-color,1.0);
}
