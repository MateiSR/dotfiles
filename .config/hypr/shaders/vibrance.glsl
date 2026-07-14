precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

const float vibrance = 0.6; // 0.0 = no change, 1.0 = max saturation

void main() {
    vec4 color = texture2D(tex, v_texcoord);
    float avg = (color.r + color.g + color.b) / 3.0;
    float mx = max(color.r, max(color.g, color.b));
    float amt = (mx - avg) * (-vibrance * 3.0);
    color.rgb = mix(color.rgb, vec3(mx), amt);
    gl_FragColor = color;
}
