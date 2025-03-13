#version 330 core

in vec2 v_texcoord;     // Input texture coordinates
out vec4 fragColor;     // Output fragment color
uniform sampler2D tex;  // Texture sampler
uniform vec2 resolution; // Screen resolution

precision mediump float;
uniform float time;      // Time uniform for animation

void main()
{
    // Normalize the screen coordinates to [0, 1]
    vec2 uv = gl_FragCoord.xy / vec2(1920, 1080); // Replace 800.0, 600.0 with your screen resolution

    // Calculate the diagonal line from bottom-right to top-left
    float diagonal = uv.x + uv.y;

    // Normalize the time to a range of 0 to 1 (adjust the divisor to control speed)
    float progress = time / 0.5; // 10.0 is the total duration of the animation


    vec4 pix = texture(tex, v_texcoord);

    // Create the black box effect
    if (diagonal < progress * 2.0) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0); // Black color
    } else {
        fragColor = vec4(pix.r, pix.g, pix.b, 1.0); // White color (or any other background color)
    }
}
