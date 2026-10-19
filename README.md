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

## 새 책 모임 추가하기 → `REUSE.md` 참고

## 운영 (데이터 갱신)
1. PC 카톡에서 대화 내보내기(텍스트만)
2. 해당 책 폴더의 `chat.txt` 덮어쓰기 (예: `singularity/chat.txt`)
3. GitHub Desktop → Summary → Commit → Push
4. 1~2분 후 라이브 URL 새로고침

### 한 번에 반영하기 (`update-chat.bat`)
카톡에서 대화를 내보낸 뒤 `update-chat.bat`을 더블클릭하면 2~3단계를 대신합니다.
- 다운로드·바탕화면·`문서\카카오톡 받은 파일`에서 가장 최근 `KakaoTalk_*.txt`를 찾음 (txt를 bat 위로 끌어다 놓아도 됨)
- 파일·대화방 이름·미션완료 건수를 보여 주고 Y 입력 시 `git pull` → `sapiens/chat.txt` 덮어쓰기 → commit → push
- 다른 책에 쓰려면 bat 안의 `-Book sapiens`를 그 책 폴더 이름으로 변경
