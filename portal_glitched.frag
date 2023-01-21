#version 120


uniform sampler2D perlinTexture;
uniform float reasonableTime;


uniform float iTime;
const float PI = 3.1415926535;
const float TAU = 2.0 * PI;
const vec2 res = vec2(128,128);
const float num_circles = 4.0;

float snoise(vec2 v);
vec3 hsv2rgb(vec3 c);
mat2 rotate(float t);


#include "shaders/logic.glsl"


vec4 draw_texture(vec2 pos) {
    float wobbly_edge = snoise(pos + 2.0 * pos + 0.75 * iTime) * 0.03;
    float value = length(pos) > (0.43 + wobbly_edge) ? 0.0 : 0.7;
    float hue = length(pos + 0.9 - sin(pos + iTime * 0.45) * 0.9);
    float opacity = ceil(value);
    vec3 col = hsv2rgb(vec3(hue, 0.99, value));
    return vec4(col + vec3(0.5 * col.g,-col.g * 0.5,col.g * 0.5), opacity);
}

vec4 draw_circle(vec2 pos, float radius, float rotate_angle, float mid) {
    pos = rotate(rotate_angle) * pos;
    float angle = atan(pos.y, pos.x);
    float wobbly_edge = snoise(pos + 2.0 * pos + 0.75 * iTime) * 0.03;

    if (length(pos) < (radius + wobbly_edge)) {
        return vec4(0.0, 0.0, 0.4, mid);
    } else {
        return draw_texture(pos);
    }
}

vec4 draw(vec2 pos) {
    vec4 color = vec4(vec3(0.0), 0.0);
    float t = iTime * 0.75;
    float mid = 1.0;

    for (float i = 0.0; i < num_circles; ++i) {
        // Wiggle the circles around
        float offset_size = (num_circles - (i + 1.0)) * 0.0125;
        float angle = iTime * PI / 32.0;
        vec2 offset = vec2(cos(t + angle), sin(t + angle)) * vec2(offset_size);
        // Circle size
        float radius = (i) * 0.06 + 0.15;

        // Location on the buffer
        vec2 st = offset + pos;
        vec2 pos = vec2(0.5) - st;

        // Draw the sample
        vec4 circle = draw_circle(pos, radius, i, mid);
        mid = 0.65;
        color = mix(color, circle, circle.a);
    }

    return color;
}


const float glitchCycleTime = 192.0;
const float glitchTime = 16.0;

void main()
{
    vec2 xy = gl_TexCoord[0].xy;

    float bigGlitch = ge(mod(reasonableTime,glitchCycleTime),glitchCycleTime - glitchTime);

    float noiseA = texture2D(perlinTexture,vec2(0.0,mod(xy.y*0.5 + reasonableTime*0.02,1.0))).r;
    float noiseB = texture2D(perlinTexture,vec2(mod(xy.y*0.5 + reasonableTime*0.025,1.0),0.0)).r;

    xy.x += cos(reasonableTime/mix(8.0,12.0,noiseA) + xy.y*8.0)*(mix(0.025,0.035,noiseB) + bigGlitch*0.1);

    gl_FragColor = draw(xy);
}


mat2 rotate(float t) {
    return mat2(
        cos(t), -sin(t),
        sin(t),  cos(t)
    );
}

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

// Noise shit
vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}

float snoise(vec2 v) {
    const vec4 C = vec4(
         0.211324865405187, // (3.0-sqrt(3.0))/6.0
         0.366025403784439, // 0.5*(sqrt(3.0)-1.0)
        -0.577350269189626, // -1.0 + 2.0 * C.x
         0.024390243902439  // 1.0 / 41.0
    );
    vec2 i = floor(v + dot(v, C.yy));
    vec2 x0 = v - i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute(permute(i.y + vec3(0.0, i1.y, 1.0)) + i.x + vec3(0.0, i1.x, 1.0));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m * m * m * m;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * (a0 * a0 + h * h);
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}