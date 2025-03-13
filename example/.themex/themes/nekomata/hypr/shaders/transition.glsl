#version 330 core

in vec2 v_texcoord;     // Input texture coordinates
out vec4 fragColor;     // Output fragment color
uniform sampler2D tex;  // Texture sampler
uniform vec2 resolution; // Screen resolution

precision mediump float;
uniform float time;      // Time uniform for animation
uniform float shake_power = 0.1;       // Shake intensity
uniform float shake_rate = 0.001;         // Shake rate
uniform float shake_speed = 2.0;        // Shake speed
uniform float shake_block_size = 50.5;  // Shake block size
uniform float shake_color_rate = 0.01;  // Color shift rate

// Random function to generate random values
float random(float seed) {
    return fract(543.2543 * sin(dot(vec2(seed, seed), vec2(3525.46, -54.3415))));
}

void main() {
    // Determine if we should apply the glitch effect based on random time and shake rate
    float enable_shift = float(random(floor(time * shake_speed)) < shake_rate);

    // Compute the fixed UV coordinates for glitching effect
    vec2 fixed_uv = v_texcoord;
    fixed_uv.x += (random((floor(v_texcoord.y * shake_block_size) / shake_block_size) + time) - 0.5) * shake_power * enable_shift;

    // Sample the texture at the fixed UV coordinates
    vec4 pixel_color = texture(tex, fixed_uv);

    // Apply red color shift
    pixel_color.r = mix(pixel_color.r, texture(tex, fixed_uv + vec2(shake_color_rate, 0.0)).r, enable_shift);
    // Apply blue color shift
    pixel_color.b = mix(pixel_color.b, texture(tex, fixed_uv + vec2(-shake_color_rate, 0.0)).b, enable_shift);

    // Output the final pixel color
    fragColor = pixel_color;
}


