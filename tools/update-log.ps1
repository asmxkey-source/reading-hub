# 개인 책(type: solo)의 log.txt를 메모장으로 열어 작성하고 GitHub에 push한다.
# 사용: update-log.bat 더블클릭
#  1) 최신 내용 받기(git pull) — GitHub 웹에서 고친 내용도 함께 받아 옴
#  2) 메모장으로 log.txt 열기 → 작성·저장 후 Enter
#  3) 인식된 회차 확인 → Y 입력 시 commit·push
param([string]$Book = '')

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
Set-Location $repo

function Fail($msg) {
  Write-Host ""
  Write-Host "[실패] $msg" -ForegroundColor Red
  exit 1
}

# 1. 최신 내용 받기
git pull --rebase --autostash
if ($LASTEXITCODE -ne 0) { Fail "git pull에 실패했습니다. 같은 log.txt를 GitHub 웹과 PC에서 동시에 고쳤는지 확인해 주세요." }

# 2. 개인 책 고르기
$data = Get-Content -Path (Join-Path $repo 'books.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$today = (Get-Date).Date
$solo = @($data.books | Where-Object { $_.type -eq 'solo' } | ForEach-Object {
  $start = if ($_.startDate) { [datetime]$_.startDate } else { $null }
  $end = if ($_.endDate) { [datetime]$_.endDate } else { $null }
  $st = if ($_.status -and $_.status -ne 'auto') { $_.status }
        elseif ($start -and $today -lt $start) { 'soon' }
        elseif ($end -and $today -gt $end) { 'done' }
        else { 'live' }
  $order = @{ live = 0; soon = 1; done = 2 }[$st]
  [pscustomobject]@{ slug = $_.slug; title = $_.title; status = $st; order = $order }
} | Sort-Object order)

if ($Book) { $solo = @($solo | Where-Object { $_.slug -eq $Book }) }
if ($solo.Count -eq 0) { Fail "books.json에 혼자 읽는 책(type: solo)이 없습니다." }

$label = @{ live = '진행 중'; soon = '예정'; done = '완독' }
if ($solo.Count -eq 1) {
  $pick = $solo[0]
} else {
  Write-Host ""
  for ($i = 0; $i -lt $solo.Count; $i++) {
    Write-Host ("  {0}. {1} ({2})" -f ($i + 1), $solo[$i].title, $label[$solo[$i].status])
  }
  $n = Read-Host "기록할 책 번호 (Enter = 1)"
  if (-not $n) { $n = 1 }
  if ($n -notmatch '^\d+$' -or [int]$n -lt 1 -or [int]$n -gt $solo.Count) { Fail "번호를 잘못 입력했습니다." }
  $pick = $solo[[int]$n - 1]
}

$log = Join-Path $repo "$($pick.slug)\log.txt"
if (-not (Test-Path $log)) { Fail "기록 파일이 없습니다: $($pick.slug)\log.txt" }

# 3. 메모장으로 작성
Write-Host ""
Write-Host "$($pick.title) — 메모장에서 log.txt를 엽니다."
Start-Process notepad.exe -ArgumentList "`"$log`""
Read-Host "작성하고 저장(Ctrl+S)한 뒤 여기서 Enter를 누르세요"

# 4. 인식 결과 확인
$re = '^[ \t]*(\d{1,2})[/.](\d{1,2})[ \t]+(\d+)[ \t]*회[ \t]*차[ \t]*(?:미[ \t]*션[ \t]*)?완[ \t]*료'
$sessions = @(Get-Content -Path $log -Encoding UTF8 |
  Where-Object { $_ -notmatch '^\s*#' } |
  ForEach-Object { if ($_ -match $re) { [int]$Matches[3] } } |
  Sort-Object -Unique)

git add -- "$($pick.slug)/log.txt"
git diff --cached --quiet
if ($LASTEXITCODE -eq 0) { Write-Host "바뀐 내용이 없습니다. 올릴 것이 없어요."; exit 0 }

Write-Host ""
Write-Host "인식된 회차 : $($sessions.Count)개 ($($sessions -join ', '))"
$ok = Read-Host "GitHub에 올릴까요? (Y/N)"
if ($ok -notmatch '^[Yy]') {
  git reset -q -- "$($pick.slug)/log.txt"
  Write-Host "올리지 않았습니다. 작성한 내용은 PC에 그대로 남아 있어요."
  exit 0
}

# 5. commit → push
git commit -m "Update $($pick.slug) log.txt ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
if ($LASTEXITCODE -ne 0) { Fail "commit에 실패했습니다." }
git push
if ($LASTEXITCODE -ne 0) { Fail "push에 실패했습니다. GitHub 로그인 상태를 확인해 주세요." }

Write-Host ""
Write-Host "[완료] 1~2분 뒤 사이트를 새로고침하면 기록이 보입니다." -ForegroundColor Green
Write-Host "https://asmxkey-source.github.io/reading-hub/$($pick.slug)/"
