# 독서 기록 허브 (reading-hub)

여러 책 모임을 **하나의 URL**로 모아 보는 통합 대시보드.

## URL 구조
```
허브 (멤버가 기억할 URL 하나)
  https://asmxkey-source.github.io/reading-hub/

각 책 대시보드 (허브에서 클릭하면 자동 이동)
  https://asmxkey-source.github.io/reading-hub/singularity/
  https://asmxkey-source.github.io/reading-hub/<새책slug>/
```

## 폴더 구성
```
reading-hub/
├── index.html        ← 허브 (책 목록)
├── books.json        ← 책 목록 데이터 (허브가 읽음)
├── singularity/      ← 책 1
│   ├── index.html    ← 대시보드 (자기만의 CONFIG)
│   └── chat.txt      ← 카톡 대화
└── <새책>/           ← 책 2, 3 ...
    ├── index.html
    └── chat.txt
```

각 책 폴더는 **독립적**입니다 — 책마다 멤버·기간·페이지가 달라도 됩니다.

## 함께 / 혼자 탭
허브 위쪽 **[👥 함께] [🙋 혼자]** 탭으로 나뉩니다. `books.json`의 `type`으로 구분합니다.

| | 함께 (`"type": "group"`) | 혼자 (`"type": "solo"`) |
|---|---|---|
| 기록 파일 | `chat.txt` (카톡 내보내기) | `log.txt` (직접 작성) |
| 반영 | `update-chat.bat` | `update-log.bat` 또는 GitHub 웹에서 수정 |
| 템플릿 | 기존 함께 책 폴더 복사 | `_templates/solo/` 복사 |

- `type`이 없으면 함께로 봅니다.
- 혼자 탭 바로가기: `https://asmxkey-source.github.io/reading-hub/#solo`
- 검색창은 두 탭의 기록을 모두 검색합니다.

## 새 책 모임 추가하기 → `REUSE.md` 참고

## 운영 — 혼자 읽는 책 (`log.txt`)
양식: `날짜 N회차 완료` 한 줄, 다음 줄부터 후기. 다음 `날짜 N회차 완료` 줄 전까지가 그 회차 후기입니다. `#`으로 시작하는 줄은 무시합니다.
```
10/20 1회차 완료
1. 인지혁명
• 허구를 믿는 능력이 협력의 바탕
```
**PC (기본)**: `update-log.bat` 더블클릭 → 최신 내용 받기(git pull) → 메모장으로 `log.txt`가 열림 → 작성·저장(Ctrl+S) → 창에서 Enter → 인식된 회차 확인 후 Y → push

**휴대폰·다른 PC (보조)**: github.com/asmxkey-source/reading-hub → 책 폴더 → `log.txt` → ✏️ 연필 → 작성 → **Commit changes**. bat은 시작할 때 pull을 하므로 웹에서 쓴 내용도 그대로 이어집니다. 단, 같은 내용을 웹과 PC에서 **동시에** 고쳐 두면 pull이 충돌할 수 있으니 한쪽에서 올린 뒤 다른 쪽을 쓰세요.

## 독서 로그에 이미지 넣기 (구조화 이미지·연대표 등)
책 폴더의 `img/`에 **`이름_회차.확장자`** 규칙으로 두면, 그 사람의 그 회차 후기 아래에 자동으로 붙습니다.
```
sapiens/img/규리_3.png      ← 규리 3회차 첫 번째 이미지
sapiens/img/규리_3-2.png    ← 두 번째 (-3, -4 … 순서대로 표시)
```
- 후기(인증)가 있는 회차에만 표시됩니다. 형식: png·jpg·gif

**PC (기본)**: 이미지 파일(여러 장 가능)을 `add-image.bat` 위로 끌어다 놓기 → 책·사람·회차 선택 → 자동으로 이름 붙이고 가로 1600px 넘으면 축소 → Y 입력 시 push. bat을 더블클릭하면 파일 선택 창이 열립니다.

**GitHub 웹 (보조)**: 책 폴더 → `img` 폴더 → **Add file → Upload files**. 파일 이름을 규칙대로 미리 바꿔서 올리세요(`img` 폴더가 없으면 bat으로 한 번 먼저 올리기). 큰 원본은 그대로 올라가니 가능하면 bat을 쓰세요.

⚠️ 사이트는 공개입니다. 개인정보가 담긴 이미지는 올리지 마세요.

## 운영 — 함께 읽는 책 (`chat.txt`)
1. PC 카톡에서 대화 내보내기(텍스트만)
2. 해당 책 폴더의 `chat.txt` 덮어쓰기 (예: `singularity/chat.txt`)
3. GitHub Desktop → Summary → Commit → Push
4. 1~2분 후 라이브 URL 새로고침

### 한 번에 반영하기 (`update-chat.bat`)
카톡에서 대화를 내보낸 뒤 `update-chat.bat`을 더블클릭하면 2~3단계를 대신합니다.
- 다운로드·바탕화면·`문서\카카오톡 받은 파일`에서 가장 최근 `KakaoTalk_*.txt`를 찾음 (txt를 bat 위로 끌어다 놓아도 됨)
- 파일·대화방 이름·미션완료 건수를 보여 주고 Y 입력 시 `git pull` → `sapiens/chat.txt` 덮어쓰기 → commit → push
- 다른 책에 쓰려면 bat 안의 `-Book sapiens`를 그 책 폴더 이름으로 변경
