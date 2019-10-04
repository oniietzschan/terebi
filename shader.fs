number phase = 0.0001;

extern number edge;
extern number width;
extern number height;

vec4 effect(vec4 c, Image tex, vec2 tc, vec2 sc) {
  // For some reason offsetting the position slightly in both directions produces more consistent results.
  // I don't totally understand why this is necessary, but it probably has to do with fuzzy float comparisons.
  tc.x = tc.x + phase;
  tc.y = tc.y + phase;
  c = Texel(tex, tc);

  vec2 locationWithinTexel = vec2(
    fract(tc.x * width),
    fract(tc.y * height)
  );
  if (locationWithinTexel.x > edge) { // Horizontal Border
    vec2 neighbourCoords = vec2(tc.x + (1 / width), tc.y);
    c += Texel(tex, neighbourCoords);
    if (locationWithinTexel.y > edge) { // Diagonal Border
      neighbourCoords = vec2(tc.x, tc.y + (1 / height));
      c += Texel(tex, neighbourCoords);
      neighbourCoords = vec2(tc.x + (1 / width), tc.y + (1 / height));
      c += Texel(tex, neighbourCoords);
      c /= 4;
    } else {  // Strictly Horizontal Border
      c /= 2;
    }
  } else if (locationWithinTexel.y > edge) { // Strictly Vertical Border
    vec2 neighbourCoords = vec2(tc.x, tc.y + (1 / height));
    c += Texel(tex, neighbourCoords);
    c /= 2;
  }

  // // Various processes for debugging the pixel grid visualize locationWithinTexel
  // c.rgb = c.rgb * locationWithinTexel.x * locationWithinTexel.y;
  // c.rgb = vec3(1,1,1) * locationWithinTexel.y;
  // if (locationWithinTexel.x > edge || locationWithinTexel.y > edge) {
  // // if (locationWithinTexel.y > edge) {
  //   // c.rgb *= 0.6;
  // }

  return c;
}