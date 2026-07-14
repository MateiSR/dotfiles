precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    vec3 color = pixColor.rgb;

    // Increase contrast around mid-grey.
    color = (color - 0.5) * 1.03 + 0.5;

    color = max(color, 0.0);

    // Increase saturation relative to luminance.
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(luma), color, 1.30);

    gl_FragColor = vec4(color, pixColor.a);
}
