# 새 책 모임 추가하기

`reading-hub` 안에 새 책을 추가하는 4단계. 새 저장소·새 URL을 만들 필요 없습니다.

## 시작 전 정해두기

| 항목 | 예시 |
|---|---|
| 폴더 이름(slug, 영문/하이픈) | `sapiens` |
| 책 제목 / 저자 | `사피엔스 / 유발 하라리` |
| 참여자 | `진영, 민수, 소영` (책마다 달라도 OK) |
| 시작일 (월요일 권장) | `2026-07-06` |
| 시작/끝 페이지, 회차당 쪽수 | `1 ~ 580`, `30` |

---

## 4단계

### 1. 책 폴더 만들고 템플릿 복사
- `reading-hub/` 안에 새 폴더 생성 (예: `sapiens`)
- `singularity/` 폴더의 `index.html`과 `chat.txt`를 새 폴더로 복사
- `chat.txt`는 내용을 비워도 됩니다 (모임 시작 후 카톡 export로 교체)

### 2. 새 폴더의 `index.html`에서 CONFIG만 수정
파일 상단 `CONFIG` 객체:
```js
const CONFIG = {
  book: { title: '사피엔스', author: '유발 하라리' },
  members: ['진영', '민수', '소영'],
  startDate: '2026-07-06',
  totalSessions: 20,        // = ceil(endPage / pagesPerSession)
  startPage: 1,
  endPage: 580,
  pagesPerSession: 30,
  today: null,
};
```

### 3. `books.json`에 항목 한 줄 추가
허브 목록에 뜨게 하려면 `reading-hub/books.json`의 `books` 배열에 추가:
```json
{
  "slug": "sapiens",
  "title": "사피엔스",
  "author": "유발 하라리",
  "members": ["진영", "민수", "소영"],
  "startDate": "2026-07-06",
  "endDate": "2026-07-31",
  "totalSessions": 20,
  "status": "auto"
}
```
- `slug`는 1단계 폴더 이름과 **반드시 동일**해야 클릭이 연결됨
- `status`: `"auto"`면 날짜로 자동 판정 (예정/진행 중/완독). 강제 지정하려면 `"live"`, `"done"`, `"soon"`
- `endDate`는 표시용. 모르면 비워둬도(`""`) 됨

### 4. Commit + Push
GitHub Desktop에서 변경된 파일들(새 폴더 + books.json) Commit → Push.
1~2분 후 허브 새로고침하면 새 책 카드가 보이고, 클릭하면 그 책 대시보드로 이동.

---

## 자주 묻는 질문

**Q. 멤버가 책마다 다른데 괜찮나?**
A. 네. 각 책 폴더의 `index.html`이 자기 CONFIG·멤버를 가집니다. 완전히 독립적입니다.

**Q. books.json과 책 CONFIG에 멤버·날짜가 중복되는데?**
A. books.json은 허브 목록 표시용, 책 CONFIG는 그 책 대시보드 계산용입니다. 새 책 추가 시 두 곳 다 적어주세요. (양이 적어 부담 크지 않음)

**Q. 회차당 쪽수, 시작 요일을 바꾸려면?**
A. `pagesPerSession`, `startDate`만 바꾸면 됩니다. 단 현재 코드는 월~금만 회차로 잡고 주말은 만회용입니다.

**Q. 기존 특이점 모임 기록은?**
A. `singularity/` 폴더에 그대로 보존됩니다. 별도 아카이브 저장소(`book-club-singularity`)도 남아있습니다.
