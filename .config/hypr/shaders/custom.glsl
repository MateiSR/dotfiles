precision mediump float;
varying vec2 v_texcoord;
uniform sampler2D tex;

void main() {
    vec4 pixColor = texture2D(tex, v_texcoord);
    vec3 color = pixColor.rgb;

    // 1. Brightness - disabled (a multiplier < 1.0 darkens the whole image).
    //    Leave this OFF: brightness/gamma is handled by r_fullscreen_gamma in
    //    CS2. Doing it here too would double up and be impossible to tune.
    // color *= 0.95;

    // 2. Contrast - expands tones around mid-grey (0.5).
    //    1.03 = +3%. Was 1.06 (+6%); lowered to cut harsh edges and highlight
    //    clipping. Set 1.00 to remove contrast entirely, 1.05 for more bite.
    color = (color - 0.5) * 1.03 + 0.5;

    // 3. Gamma - 1.0/1.0 is the identity function, i.e. it does NOTHING.
    //    Keep it at 1.0. Brightness lives in CS2's r_fullscreen_gamma; do not
    //    add gamma here as well or the two will fight each other.
    color = pow(max(color, 0.0), vec3(1.0 / 1.0));

    // 4. Digital Vibrance (saturation) - pushes each channel away from the
    //    pixel's luma. 1.30 = +30%. Was 1.40 (+40%); lowered because on already
    //    bright/saturated content (fire, skyboxes, reds) the +40% shoved the
    //    dominant channel past 1.0 and hard-clipped it to pure colour - that is
    //    the "burned" look. Drop to 1.25 / 1.20 if it still burns, raise to
    //    1.35 for more pop.
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = mix(vec3(luma), color, 1.30);

    gl_FragColor = vec4(color, pixColor.a);
}

