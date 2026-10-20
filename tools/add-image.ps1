# 독서 로그에 이미지를 붙인다: 책·사람·회차를 고르면
# 책폴더\img\이름_회차.png (두 번째부터 이름_회차-2.png ...) 로 저장하고 push한다.
# 사용: 이미지 파일들을 add-image.bat 위로 끌어다 놓기, 또는 bat 더블클릭 후 파일 선택
param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Files)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Windows.Forms
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo
$MaxWidth = 1600

function Fail($msg) {
  Write-Host ""
  Write-Host "[실패] $msg" -ForegroundColor Red
  exit 1
}

function Choose($title, $items, $labels) {
  if ($items.Count -eq 1) { return $items[0] }
  Write-Host ""
  Write-Host $title
  for ($i = 0; $i -lt $items.Count; $i++) { Write-Host ("  {0}. {1}" -f ($i + 1), $labels[$i]) }
  $n = Read-Host "번호 (Enter = 1)"
  if (-not $n) { $n = 1 }
  if ($n -notmatch '^\d+$' -or [int]$n -lt 1 -or [int]$n -gt $items.Count) { Fail "번호를 잘못 입력했습니다." }
  return $items[[int]$n - 1]
}

# 1. 이미지 고르기
$Files = @($Files | Where-Object { $_ })
if ($Files.Count -eq 0) {
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = '독서 로그에 넣을 이미지 선택'
  $dlg.Filter = '이미지 (*.png;*.jpg;*.jpeg;*.gif)|*.png;*.jpg;*.jpeg;*.gif'
  $dlg.Multiselect = $true
  if ($dlg.ShowDialog() -ne 'OK') { Write-Host "취소했습니다."; exit 0 }
  $Files = $dlg.FileNames
}
foreach ($f in $Files) {
  if (-not (Test-Path $f)) { Fail "파일을 찾을 수 없습니다: $f" }
  if ([IO.Path]::GetExtension($f) -notmatch '^\.(png|jpe?g|gif)$') { Fail "png·jpg·gif만 넣을 수 있습니다: $f" }
}

# 2. 최신 내용 받기
git pull --rebase --autostash
if ($LASTEXITCODE -ne 0) { Fail "git pull에 실패했습니다." }

# 3. 책·사람·회차 고르기
$data = Get-Content -Path (Join-Path $repo 'books.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$today = (Get-Date).Date
$books = @($data.books | Sort-Object @{ Expression = {
  $s = if ($_.startDate) { [datetime]$_.startDate } else { $today }
  $e = if ($_.endDate) { [datetime]$_.endDate } else { $today }
  if ($today -ge $s -and $today -le $e) { 0 } elseif ($today -lt $s) { 1 } else { 2 }
} })
$book = Choose '어느 책인가요?' $books @($books | ForEach-Object { "$($_.title)  ($(if ($_.type -eq 'solo') { '혼자' } else { '함께' }))" })
$members = @($book.members)
$name = Choose '누구의 기록인가요?' $members $members
$session = Read-Host "몇 회차인가요? (1~$($book.totalSessions))"
if ($session -notmatch '^\d+$' -or [int]$session -lt 1 -or ($book.totalSessions -and [int]$session -gt [int]$book.totalSessions)) { Fail "회차를 잘못 입력했습니다." }
$session = [int]$session

# 4. 이름 붙여 저장 (가로 1600px 넘으면 축소, 사진 회전 정보 반영)
$imgDir = Join-Path $repo "$($book.slug)\img"
New-Item -ItemType Directory -Force -Path $imgDir | Out-Null
$saved = @()
foreach ($f in $Files) {
  $ext = [IO.Path]::GetExtension($f).ToLower()
  if ($ext -eq '.jpeg') { $ext = '.jpg' }
  $n = 1
  do {
    $base = if ($n -eq 1) { "${name}_$session" } else { "${name}_$session-$n" }
    $exists = @(Get-ChildItem -Path $imgDir -File | Where-Object { $_.BaseName -eq $base }).Count -gt 0
    $n++
  } while ($exists)
  $dest = Join-Path $imgDir "$base$ext"

  if ($ext -eq '.gif') {
    Copy-Item $f $dest
  } else {
    $img = [System.Drawing.Image]::FromFile($f)
    try {
      if ($img.PropertyIdList -contains 0x0112) {
        switch ($img.GetPropertyItem(0x0112).Value[0]) {
          3 { $img.RotateFlip('Rotate180FlipNone') }
          6 { $img.RotateFlip('Rotate90FlipNone') }
          8 { $img.RotateFlip('Rotate270FlipNone') }
        }
      }
      $w = $img.Width; $h = $img.Height
      if ($w -gt $MaxWidth) { $h = [int]($h * $MaxWidth / $w); $w = $MaxWidth }
      $bmp = New-Object System.Drawing.Bitmap $w, $h
      $g = [System.Drawing.Graphics]::FromImage($bmp)
      $g.InterpolationMode = 'HighQualityBicubic'
      if ($ext -eq '.jpg') { $g.Clear([System.Drawing.Color]::White) }
      $g.DrawImage($img, 0, 0, $w, $h)
      $g.Dispose()
      if ($ext -eq '.jpg') {
        $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
        $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
        $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), 85L
        $bmp.Save($dest, $codec, $ep)
      } else {
        $bmp.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
      }
      $bmp.Dispose()
    } finally { $img.Dispose() }
  }
  $kb = [int]((Get-Item $dest).Length / 1KB)
  $saved += "$base$ext"
  Write-Host ("  {0}  →  {1}\img\{2}{3}  ({4} KB)" -f [IO.Path]::GetFileName($f), $book.slug, $base, $ext, $kb)
}

# 5. 이미지 목록(img/index.json) 갱신
$list = @(Get-ChildItem -Path $imgDir -File | Where-Object { $_.Extension -match '^\.(png|jpe?g|gif|webp)$' } | Sort-Object Name | ForEach-Object { $_.Name })
$json = '[' + (($list | ForEach-Object { '"' + $_.Replace('\', '\\').Replace('"', '\"') + '"' }) -join ',') + ']'
[IO.File]::WriteAllText((Join-Path $imgDir 'index.json'), $json, (New-Object System.Text.UTF8Encoding $false))

Write-Host ""
Write-Host "$($book.title) · $name · ${session}회차 후기 아래에 $($saved.Count)장이 붙습니다."
$ok = Read-Host "GitHub에 올릴까요? (Y/N)"
if ($ok -notmatch '^[Yy]') {
  Write-Host "올리지 않았습니다. 파일은 $($book.slug)\img 에 남아 있어요."
  exit 0
}

# 6. commit → push
git add -- "$($book.slug)/img"
git commit -m "Add images to $($book.slug) ($name ${session}회차)"
if ($LASTEXITCODE -ne 0) { Fail "commit에 실패했습니다." }
git push
if ($LASTEXITCODE -ne 0) { Fail "push에 실패했습니다. GitHub 로그인 상태를 확인해 주세요." }

Write-Host ""
Write-Host "[완료] 1~2분 뒤 사이트를 새로고침하면 독서 로그에 이미지가 보입니다." -ForegroundColor Green
Write-Host "https://asmxkey-source.github.io/reading-hub/$($book.slug)/"
