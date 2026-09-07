{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Keep the renderer and fallback font requests inside the built app.
    canvasKitBaseUrl: new URL('canvaskit/', document.baseURI).href,
    fontFallbackBaseUrl: new URL('assets/fonts/', document.baseURI).href,
  },
});
