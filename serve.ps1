# GI & KLIRONOMIA 360 - local offline server (localhost, no internet needed)
# Launched by start.bat. Serves this folder so the app runs as a full offline PWA.
$root = $PSScriptRoot
$port = 8790
$prefix = "http://localhost:$port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
try {
  $listener.Start()
} catch {
  Write-Host ("Port " + $port + " already in use - the server may already be running.")
  exit
}

Write-Host ("GI360 serving " + $root + " -> " + $prefix)
$mime = @{
  ".html"="text/html; charset=utf-8"; ".js"="application/javascript; charset=utf-8";
  ".webmanifest"="application/manifest+json; charset=utf-8"; ".json"="application/json; charset=utf-8";
  ".png"="image/png"; ".jpg"="image/jpeg"; ".jpeg"="image/jpeg"; ".ico"="image/x-icon";
  ".svg"="image/svg+xml"; ".css"="text/css; charset=utf-8"; ".woff2"="font/woff2"
}
while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $path = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath).TrimStart('/')
    if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
    $file = Join-Path $root $path
    if (Test-Path $file -PathType Leaf) {
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ext = [System.IO.Path]::GetExtension($file).ToLower()
      if ($mime.ContainsKey($ext)) { $ctx.Response.ContentType = $mime[$ext] }
      $ctx.Response.Headers.Add("Service-Worker-Allowed","/")
      $ctx.Response.KeepAlive = $false
      $ctx.Response.SendChunked = $false
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes,0,$bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $b = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: " + $path)
      $ctx.Response.OutputStream.Write($b,0,$b.Length)
    }
    $ctx.Response.Close()
  } catch { }
}
