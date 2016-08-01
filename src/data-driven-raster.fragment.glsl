#ifdef GL_ES
precision mediump float;
#else
#define lowp
#define mediump
#define highp
#endif

uniform float u_opacity0;
uniform float u_opacity1;
uniform sampler2D u_image0;
uniform sampler2D u_image1;
uniform sampler2D u_image2;
varying vec2 v_pos0;
varying vec2 v_pos1;

uniform float u_brightness_low;
uniform float u_brightness_high;

// These indicate the range of the data tile png
// e.g. 0 - 100 for temperature tiles
uniform float u_data_min;
uniform float u_data_max;

uniform float u_saturation_factor;
uniform float u_contrast_factor;
uniform vec3 u_spin_weights;

void main() {

    // read and cross-fade colors from the main and parent tiles
    vec4 color0 = texture2D(u_image0, v_pos0);
    vec4 color1 = texture2D(u_image1, v_pos1);
    vec4 color = color0 * u_opacity0 + color1 * u_opacity1;
    vec3 rgb = color.rgb;

    float value = rgb.r * 255.0;
    value = (value - u_data_min) / (u_data_max - u_data_min);
    value = clamp(value, 0.0, 1.0);

    // spin
    rgb = vec3(
        dot(rgb, u_spin_weights.xyz),
        dot(rgb, u_spin_weights.zxy),
        dot(rgb, u_spin_weights.yzx));

    // saturation
    float average = (color.r + color.g + color.b) / 3.0;
    rgb += (average - rgb) * u_saturation_factor;

    // contrast
    rgb = (rgb - 0.5) * u_contrast_factor + 0.5;

    // brightness
    vec3 u_high_vec = vec3(u_brightness_low, u_brightness_low, u_brightness_low);
    vec3 u_low_vec = vec3(u_brightness_high, u_brightness_high, u_brightness_high);

    // gl_FragColor = vec4(mix(u_high_vec, u_low_vec, rgb), color.a);
    vec4 lookUpColor = texture2D(u_image2, vec2(value, 0.0));
    gl_FragColor = lookUpColor;

#ifdef OVERDRAW_INSPECTOR
    gl_FragColor = vec4(1.0);
#endif
}
