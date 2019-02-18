number verticalPhase = 0.0001;

extern number edge;
extern number width;
extern number height;

vec4 effect(vec4 c, Image tex, vec2 tc, vec2 sc) {
  // For some reason it's necessary to ever so slightly increment the Y-axis of the texture coords.
  // I don't totally understand why this is necessary, the same thing is not true about the X-axis.
  tc.y = tc.y + verticalPhase;
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