#version 330 core

in vec2 v_texcoord;     // Input texture coordinates
out vec4 FragColor;     // Output fragment color
uniform sampler2D tex;  // Texture sampler
uniform vec2 resolution; // Screen resolution

precision mediump float;
uniform float time;      // Time uniform for animation

void main() {
    // Block size (adjust to change the size of the blocks)
    float blockSize = 50.0;

    // Calculate the block coordinates
    vec2 blockCoord = floor(gl_FragCoord.xy / blockSize);

    // Generate a unique seed for each block using its coordinates
    float seed = blockCoord.x + blockCoord.y * 100.0;

    // Use the seed to create a random threshold for each block
    float threshold = fract(sin(seed) * 43758.5453);

    // Calculate the disappearance progress based on time
    float progress = time / 0.6; // Loops every 10 seconds

    vec4 pix = texture(tex, v_texcoord);
    if (threshold < progress) {
        FragColor = vec4(pix.r, pix.g, pix.b, 1.0); // White color (or any other background color)
    } else {
        FragColor = vec4(0.0, 0.0, 0.0, 1.0); // Black
    }
}
