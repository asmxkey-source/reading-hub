# 카카오톡 내보내기 txt를 책 폴더의 chat.txt로 반영하고 GitHub에 push한다.
# 사용: update-chat.bat 더블클릭 (가장 최근 KakaoTalk_*.txt 자동 탐색)
#       또는 txt 파일을 update-chat.bat 위로 끌어다 놓기
param(
  [string]$Book = 'sapiens',
  [string]$File = ''
)

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$target = Join-Path $repo "$Book\chat.txt"

function Fail($msg) {
  Write-Host ""
  Write-Host "[실패] $msg" -ForegroundColor Red
  exit 1
}

if (-not (Test-Path (Join-Path $repo $Book))) { Fail "책 폴더가 없습니다: $Book" }

# 1. 반영할 txt 찾기
if ($File) {
  if (-not (Test-Path $File)) { Fail "파일을 찾을 수 없습니다: $File" }
  $src = Get-Item $File
} else {
  $searchDirs = @(
    (Join-Path $env:USERPROFILE 'Downloads'),
    (Join-Path $env:USERPROFILE 'Desktop'),
    (Join-Path $env:USERPROFILE 'Documents\카카오톡 받은 파일')
  ) | Where-Object { Test-Path $_ }
  $src = $searchDirs |
    ForEach-Object { Get-ChildItem -Path $_ -Filter 'KakaoTalk_*.txt' -File -ErrorAction SilentlyContinue } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
  if (-not $src) { Fail "다운로드·바탕화면·'카카오톡 받은 파일'에서 KakaoTalk_*.txt를 찾지 못했습니다. txt 파일을 bat 위로 끌어다 놓아 주세요." }
}

$head = Get-Content -Path $src.FullName -Encoding UTF8 -TotalCount 2
$count = (Select-String -Path $src.FullName -Pattern '회\s*차\s*미\s*션\s*완\s*료' -Encoding UTF8).Count

Write-Host "반영할 파일 : $($src.FullName)"
Write-Host "저장 시각   : $($src.LastWriteTime)"
Write-Host "대화방      : $($head[0])"
Write-Host "미션완료 글 : $count 건"
Write-Host "대상        : $Book\chat.txt"
Write-Host ""
$ok = Read-Host "이 파일로 반영할까요? (Y/N)"
if ($ok -notmatch '^[Yy]') { Write-Host "취소했습니다."; exit 0 }

# 2. 다른 PC에서 올린 변경 먼저 받기
Set-Location $repo
git pull --rebase --autostash
if ($LASTEXITCODE -ne 0) { Fail "git pull에 실패했습니다. 충돌이 있는지 확인해 주세요." }

# 3. 복사 → commit → push
Copy-Item -Path $src.FullName -Destination $target -Force
git add -- "$Book/chat.txt"
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host "이미 같은 내용입니다. 올릴 변경이 없습니다."; exit 0 }

git commit -m "Update $Book chat.txt ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
if ($LASTEXITCODE -ne 0) { Fail "commit에 실패했습니다." }
git push
if ($LASTEXITCODE -ne 0) { Fail "push에 실패했습니다. GitHub 로그인 상태를 확인해 주세요." }

Write-Host ""
Write-Host "[완료] 1~2분 뒤 사이트를 새로고침하면 후기가 보입니다." -ForegroundColor Green
Write-Host "https://asmxkey-source.github.io/reading-hub/$Book/"
