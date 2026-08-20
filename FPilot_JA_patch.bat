@echo off
rem ================================================================
rem  FPilot_JA_patch.bat  --  File Pilot v0.8.3.0 Japanese patch
rem  Usage   : drag and drop FPilot.exe onto this BAT file.
rem  Output  : FPilot_JA.exe created in the SAME folder as the exe.
rem  Safety  : the source exe is opened read-only and never changed.
rem            Existing FPilot_JA.exe is backed up with a timestamp.
rem  Requires: Windows PowerShell (built-in). No Python needed.
rem ================================================================
setlocal
set "BATPATH=%~f0"
set "PS1=%TEMP%\FPilot_JA_patch_impl.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $raw=[IO.File]::ReadAllText($env:BATPATH); $mk=[string][char]35+'PSSTART'; $i=$raw.IndexOf($mk); if($i -lt 0){throw 'embedded marker not found'}; $j=$raw.IndexOf([char]10,$i); [IO.File]::WriteAllText($env:TEMP+'\FPilot_JA_patch_impl.ps1',$raw.Substring($j+1),(New-Object Text.UTF8Encoding($true)))"
if errorlevel 1 (
  echo [ERROR] failed to extract the embedded PowerShell script.
  pause
  exit /b 9
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%PS1%" -BatPath "%BATPATH%" %*
set "EC=%errorlevel%"
del "%PS1%" >nul 2>&1
echo.
pause
exit /b %EC%
#PSSTART
# ----------------------------------------------------------------
#  FPilot v0.8.3.0 Japanese range patch (atlas-limit safe edition)
#  Patches glyph range table idx6..idx10:
#    idx6  U+3000-33FF  (kana / CJK punct / enclosed CJK)  1024 gl -> 257 slices
#    idx7  U+4E00-6DFB  (kanji part A)                     8188 gl -> 2048 slices
#    idx8  U+6DFC-8DF7  (kanji part B)                     8188 gl -> 2048 slices
#    idx9  U+8DF8-9FFF  (kanji part C)                     4616 gl -> 1155 slices
#    idx10 U+FF00-FFEF  (fullwidth forms)                   240 gl ->   61 slices
#  Each slot's D3D11 Texture2DArray needs ceil(n/4)+1 slices;
#  D3D11 limit is 2048, so U+4E00-9FFF in ONE slot (5249 slices)
#  fails CreateTexture2D and renders ALL kanji blank.
# ----------------------------------------------------------------
param(
  [string]$BatPath,
  [Parameter(ValueFromRemainingArguments=$true)][string[]]$Files
)
$ErrorActionPreference = 'Stop'
$script:LogPath = $null
$script:Created = $false
$script:OutPath = $null

function Write-Log([string]$m) {
  $line = ('[{0}] {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $m)
  if ($script:LogPath) { Add-Content -LiteralPath $script:LogPath -Value $line -ErrorAction SilentlyContinue }
  Write-Host $line
}

try {
  if (-not $Files -or $Files.Count -lt 1) {
    Write-Host 'FPilot.exe をこのBATにドラッグ&ドロップしてください / Drag and drop FPilot.exe onto this BAT.'
    exit 2
  }
  if ($Files.Count -gt 1) {
    Write-Host ('NOTE: multiple files dropped. Only the first one is processed: ' + $Files[0])
  }

  $srcPath = [System.IO.Path]::GetFullPath(([Environment]::ExpandEnvironmentVariables($Files[0])))
  if ($BatPath) { $script:LogPath = Join-Path (Split-Path -Parent $BatPath) 'FPilot_JA_patch.log' }
  Write-Log '=== FPilot_JA patch start ==='
  Write-Log ('input: ' + $srcPath)

  if (-not (Test-Path -LiteralPath $srcPath -PathType Leaf)) { throw ('file not found: ' + $srcPath) }
  $srcItem = Get-Item -LiteralPath $srcPath
  $srcDir  = $srcItem.DirectoryName
  $script:OutPath = Join-Path $srcDir 'FPilot_JA.exe'
  if ([string]::Compare($srcItem.FullName, $script:OutPath, $true) -eq 0) {
    throw 'input is already named FPilot_JA.exe. Drop the original FPilot.exe instead.'
  }

  # ---- read source bytes (read-only handle; file is never written) ----
  $inStream = [IO.File]::Open($srcItem.FullName, 'Open', 'Read', 'ReadWrite')
  try {
    $mem = New-Object System.IO.MemoryStream
    $inStream.CopyTo($mem)
    [byte[]]$src = $mem.ToArray()
  } finally { $inStream.Close() }
  Write-Log ('source size: ' + $src.Length + ' bytes')

  # ---- MZ / PE validation ----
  if ($src.Length -lt 0x40) { throw 'file too small: not an executable' }
  if ($src[0] -ne 0x4D -or $src[1] -ne 0x5A) { throw 'MZ signature missing: not an EXE' }
  $peOff = [BitConverter]::ToUInt32($src, 0x3C)
  if ($peOff -le 0 -or ($peOff + 4) -gt $src.Length) { throw ('bad e_lfanew 0x{0:X}: not a PE' -f $peOff) }
  if ($src[$peOff] -ne 0x50 -or $src[$peOff+1] -ne 0x45 -or $src[$peOff+2] -ne 0x00 -or $src[$peOff+3] -ne 0x00) {
    throw ('PE signature missing at 0x{0:X}: not a PE image' -f $peOff)
  }
  Write-Log ('PE check OK (e_lfanew=0x{0:X})' -f $peOff)

  # ---- locate glyph-range table by byte signature (idx6..idx9 originals) ----
  [byte[]]$sig = @(0x00,0x05,0x00,0x00,0x2F,0x05,0x00,0x00,
                   0xE0,0x2D,0x00,0x00,0xFF,0x2D,0x00,0x00,
                   0x40,0xA6,0x00,0x00,0x9F,0xA6,0x00,0x00,
                   0x80,0x1C,0x00,0x00,0x8F,0x1C,0x00,0x00)
  [byte[]]$idx10orig = @(0x00,0x03,0x00,0x00,0x6F,0x03,0x00,0x00)

  $latin1 = [Text.Encoding]::GetEncoding(28591)
  $hay = $latin1.GetString($src)
  $needle = $latin1.GetString($sig)
  $hits = New-Object System.Collections.Generic.List[int]
  $p = 0
  while ($true) {
    $p = $hay.IndexOf($needle, $p, [StringComparison]::Ordinal)
    if ($p -lt 0) { break }
    $hits.Add($p); $p++
  }
  if ($hits.Count -ne 1) {
    $hs = ($hits | ForEach-Object { '0x{0:X}' -f $_ }) -join ', '
    throw ('range-table signature found {0} time(s) (expected exactly 1): {1}. Unsupported build - aborting.' -f $hits.Count, $hs)
  }
  $X = $hits[0]
  Write-Log ('range table signature: unique match at file offset 0x' + $X.ToString('X'))

  # idx10 original bytes must immediately follow the signature
  for ($i = 0; $i -lt 8; $i++) {
    if ($src[$X + 32 + $i] -ne $idx10orig[$i]) {
      throw ('idx10 original byte mismatch at 0x{0:X} (expected 0x{1:X2}, got 0x{2:X2}). Unsupported build - aborting.' -f ($X+32+$i), $idx10orig[$i], $src[$X+32+$i])
    }
  }
  Write-Log 'idx10 original bytes verified (U+0300-036F).'

  # ---- new ranges + D3D11 atlas-array self check ----
  $ranges = @(
    @{ idx = 6;  lo = 0x3000; hi = 0x33FF },
    @{ idx = 7;  lo = 0x4E00; hi = 0x6DFB },
    @{ idx = 8;  lo = 0x6DFC; hi = 0x8DF7 },
    @{ idx = 9;  lo = 0x8DF8; hi = 0x9FFF },
    @{ idx = 10; lo = 0xFF00; hi = 0xFFEF }
  )
  foreach ($r in $ranges) {
    $cnt = $r.hi - $r.lo + 1
    $pages = [int][math]::Floor(($cnt + 3) / 4) + 1
    if ($pages -gt 2048) { throw ('internal check failed: idx{0} needs {1} atlas slices (>2048)' -f $r.idx, $pages) }
    Write-Log ('idx{0,-2} : U+{1:X4}-U+{2:X4}  glyphs={3,5}  atlas_slices={4,5} (D3D11 max 2048: OK)' -f $r.idx, $r.lo, $r.hi, $cnt, $pages)
  }
  $sorted = $ranges | Sort-Object { $_.lo }
  for ($i = 1; $i -lt $sorted.Count; $i++) {
    if ($sorted[$i].lo -le $sorted[$i-1].hi) { throw ('range overlap between idx{0} and idx{1}' -f $sorted[$i-1].idx, $sorted[$i].idx) }
  }
  if (($ranges | Where-Object { $_.hi -lt $_.lo }).Count -gt 0) { throw 'invalid range (hi<lo)' }
  $kanji = ($ranges | Where-Object { $_.idx -in 7,8,9 } | Sort-Object { $_.lo } | ForEach-Object { 'U+{0:X4}-U+{1:X4}' -f $_.lo, $_.hi }) -join ' + '
  Write-Log ('kanji coverage U+4E00-9FFF split with no gaps: ' + $kanji)

  # ---- build the 40-byte patch window ----
  [byte[]]$patch = New-Object byte[] 40
  foreach ($r in $ranges) {
    $off = ($r.idx - 6) * 8
    [BitConverter]::GetBytes([uint32]$r.lo).CopyTo($patch, $off)
    [BitConverter]::GetBytes([uint32]$r.hi).CopyTo($patch, $off + 4)
  }

  # ---- backup existing output, then copy source -> output ----
  if (Test-Path -LiteralPath $script:OutPath) {
    $bak = Join-Path $srcDir ('FPilot_JA.exe.bak-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Move-Item -LiteralPath $script:OutPath -Destination $bak
    Write-Log ('existing FPilot_JA.exe backed up -> ' + $bak)
  }
  Copy-Item -LiteralPath $srcItem.FullName -Destination $script:OutPath
  $script:Created = $true

  # ---- apply patch ----
  $outStream = [IO.File]::Open($script:OutPath, 'Open', 'ReadWrite', 'Read')
  try {
    [void]$outStream.Seek($X, 'Begin')
    $outStream.Write($patch, 0, $patch.Length)
    $outStream.Flush()
  } finally { $outStream.Close() }
  Write-Log ('patched 40 bytes at 0x{0:X}-0x{1:X}' -f $X, ($X + 39))

  # ---- verify: read-back + full-file diff containment + size ----
  [byte[]]$chk = [IO.File]::ReadAllBytes($script:OutPath)
  if ($chk.Length -ne $src.Length) { throw ('output size mismatch: {0} vs {1}' -f $chk.Length, $src.Length) }
  for ($i = 0; $i -lt 40; $i++) {
    if ($chk[$X + $i] -ne $patch[$i]) { throw ('read-back mismatch at +0x{0:X}' -f $i) }
  }
  $diffCount = 0
  $firstOutside = -1
  for ($i = 0; $i -lt $src.Length; $i++) {
    if ($src[$i] -ne $chk[$i]) {
      if (($i -lt $X) -or ($i -ge ($X + 40))) { if ($firstOutside -lt 0) { $firstOutside = $i } }
      else { $diffCount++ }
    }
  }
  if ($firstOutside -ge 0) { throw ('unexpected diff OUTSIDE patch window at 0x{0:X}' -f $firstOutside) }
  Write-Log ('verification OK: exactly {0} differing bytes, all inside patch window; size identical ({1} bytes)' -f $diffCount, $chk.Length)

  $shaIn  = (Get-FileHash -LiteralPath $srcItem.FullName -Algorithm SHA256).Hash
  $shaOut = (Get-FileHash -LiteralPath $script:OutPath -Algorithm SHA256).Hash
  Write-Log ('source  SHA256 (unchanged): ' + $shaIn)
  Write-Log ('output  SHA256           : ' + $shaOut)
  if ($script:LogPath) { Write-Log ('log: ' + $script:LogPath) }
  Write-Host ''
  Write-Host ('SUCCESS -> ' + $script:OutPath)
  Write-Host 'Font strings / config are NOT modified (keep using your FontName=yumin.ttf config).'
  exit 0
}
catch {
  if ($script:Created -and $script:OutPath -and (Test-Path -LiteralPath $script:OutPath)) {
    Remove-Item -LiteralPath $script:OutPath -Force -ErrorAction SilentlyContinue
    Write-Log 'failed output removed (no partial file left behind).'
  }
  Write-Log ('ERROR: ' + $_.Exception.Message)
  Write-Log 'PATCH FAILED - nothing was applied.'
  exit 1
}
