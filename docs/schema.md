# Database Schema

## 1. users Table
사용자 정보를 저장하는 테이블.

| Column      | Type      | Null    | Key       | Description        |
|-------------|-----------|---------|-----------|--------------------|
| `id`        | INTEGER   | NOT NULL | PRIMARY   | Primary Key         |
| `name`      | TEXT      | NOT NULL |           | 사용자 이름         |
| `age`       | INTEGER   | NOT NULL |           | 나이               |
| `gender`    | TEXT      | NOT NULL |           | 성별 (`M`, `F`)     |
| `photo`     | TEXT      | NULL     |           | 프로필 이미지 경로 또는 URL |
| `created_at`| DATETIME  | NOT NULL |           | 계정 생성일         |


---

## 2. symptoms Table
증상을 저장하는 테이블.

| Column      | Type      | Null    | Key       | Description        |
|-------------|-----------|---------|-----------|--------------------|
| `id`        | INTEGER   | NOT NULL | PRIMARY   | Primary Key         |
| `name`      | TEXT      | NOT NULL |           | 증상 이름 (예: 감기) |

---

## 3. results Table
사용자가 선택한 증상에 대한 진단 결과를 저장하는 테이블.

| Column      | Type      | Null    | Key       | Description        |
|-------------|-----------|---------|-----------|--------------------|
| `id`        | INTEGER   | NOT NULL | PRIMARY   | Primary Key         |
| `user_id`   | INTEGER   | NOT NULL | FOREIGN   | Foreign Key referencing `users.id` |
| `symptom_id`| INTEGER   | NOT NULL | FOREIGN   | Foreign Key referencing `symptoms.id` |
| `date`      | DATETIME  | NOT NULL |           | 진단 날짜            |
| `title`     | TEXT      | NULL     |           | 메모 제목            |
| `memo`      | TEXT      | NULL     |           | 메모 내용            |
| `photo`     | TEXT      | NULL     |           | 진단 결과 이미지 경로 또는 URL |

---

## Relationships

1. **users → results**: 
   - One-to-Many (`users.id` ↔ `results.user_id`).
2. **symptoms → results**:
   - One-to-Many (`symptoms.id` ↔ `results.symptom_id`).

---