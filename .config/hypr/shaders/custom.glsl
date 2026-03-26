precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    vec3 color = pixColor.rgb;

    // 1. Brightness (95% = 0.95 multiplier)
    // color *= 0.95;

    // 2. Contrast (103% = centered expansion around 0.5)
    color = (color - 0.5) * 1.06 + 0.5;

    // 3. Gamma (1.0 = pow(color, 1.0/1.0))
    color = pow(max(color, 0.0), vec3(1.0 / 1.0));

    // 4. Digital Vibrance (+50% Saturation)
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(luma), color, 1.40); // 1.0 is default, 1.5 is +50%

    gl_FragColor = vec4(color, pixColor.a);
}
