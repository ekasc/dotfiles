-- Flat, restrained i3bar-like theme. Single accent only.
return {
  bg     = 0xff101012, -- near-black bar
  text   = 0xffe6e6e2, -- soft white (active workspace, app name)
  muted  = 0xff8e8e93, -- secondary (occupied workspace, title)
  dim    = 0xff5c5c62, -- darker gray (empty workspace)
  faint  = 0xff3a3a3f, -- low-contrast separator
  accent = 0xff5f8fae, -- restrained steel-blue active underline
  accent_dim = 0xff47708a, -- breathing trough (herdr working pulse)
  accent_hi  = 0xff8fb8d4, -- breathing peak (herdr working pulse)
  err    = 0xffe06c75, -- semantic only: unhealthy / needs attention (blocked agent)
}
