#include <flutter/runtime_effect.glsl>

// Liquid-glass dot matrix for GlassNavBar.
//
// Runs as the outer stage of a BackdropFilter (composed after a gaussian
// blur), so uTexture is the blurred content scrolling beneath the bar. The
// body of the bar is the backdrop mixed with the surface tint; the idle dot
// lattice punches through that tint, each dot lit by the backdrop sampled at
// the dot's center — a dot-matrix reflection of whatever moves below.
//
// The lattice must stay phase-locked with termos_ui's DotGridPainter, which
// draws square dots centered at k * (dotSize + spacing) + dotSize / 2 from
// the widget origin (no DotGridGroup above the nav bar, so gridOffset = 0).
// All position uniforms are in the same pixel space as FlutterFragCoord.

uniform vec2 uSize;     // backdrop texture size
uniform float uPitch;   // dotSize + gridSpacing
uniform float uDotSize; // square dot edge
uniform vec4 uTint;     // surface tint (straight alpha)
uniform float uBoost;   // reflection luminance ceiling
uniform vec2 uOrigin;   // bar's top-left in the frag-coord space (physical px)
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 p = FlutterFragCoord().xy;
  vec4 bg = texture(uTexture, p / uSize);

  // Glass body: tint over the blurred backdrop.
  vec3 body = mix(bg.rgb, uTint.rgb, uTint.a);

  // FlutterFragCoord originates at the backdrop layer (the bar's on-screen
  // position), but DotGridPainter lays its lattice out from the bar's own
  // top-left. Rebase to that local origin so the two grids stay phase-locked;
  // texture sampling below keeps the raw device-space coord.
  vec2 pl = p - uOrigin;

  // Signed offset to the nearest dot center along each axis.
  vec2 q = pl - vec2(uDotSize * 0.5);
  vec2 delta = mod(q + vec2(uPitch * 0.5), vec2(uPitch)) - vec2(uPitch * 0.5);

  // Square dot mask with ~half-pixel anti-aliasing.
  float d = max(abs(delta.x), abs(delta.y));
  float aa = 0.6;
  float m = 1.0 - smoothstep(uDotSize * 0.5 - aa, uDotSize * 0.5 + aa, d);

  // One uniform color per dot: the backdrop sampled at the dot center.
  // Dot opacity is gated by chroma, not brightness — gray content of any
  // luminance (max == min channel) leaves the dot fully transparent; only
  // colorful content materializes the lattice. The displayed color is the
  // normalized hue with luminance compressed under the uBoost ceiling, so
  // even saturated bright content stays subdued.
  vec3 reflection = texture(uTexture, (p - delta) / uSize).rgb;

  float mx = max(reflection.r, max(reflection.g, reflection.b));
  float mn = min(reflection.r, min(reflection.g, reflection.b));
  float chroma = mx - mn;
  // Blur upstream flattens chroma hard, so the gate opens on the faintest
  // hint of color and is fully open by 0.08.
  float presence = smoothstep(0.008, 0.08, chroma);

  vec3 hue = mx > 0.001 ? reflection / mx : vec3(1.0);
  // Re-saturate the displayed hue: push channels apart around the max.
  hue = clamp(vec3(1.0) - (vec3(1.0) - hue) * 1.8, 0.0, 1.0);
  float lum = uBoost * pow(mx, 0.3);

  fragColor = vec4(body + hue * lum * presence * m, 1.0);
}
