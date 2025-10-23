# Flutter Architecture

- lib/
  - core/            // โค้ดข้ามฟีเจอร์ เช่น theme, utils, error, usecase base
    - theme/
    - utils/
    - errors/
    - usecase/
  - common/          // UI/Widget/Helper ที่ใช้ร่วมกันหลายฟีเจอร์
    - widgets/
  - features/        // แยกตามฟีเจอร์
    - <feature_name>/
      - domain/      // entity, repository abstract, usecases
      - data/        // datasource, models, repository impl
      - presentation // pages, providers/state, widgets

แนวคิดหลัก:
- แยกชั้น Domain, Data, Presentation ชัดเจน
- `core/` และ `common/` ไม่มีการอ้างอิงเฉพาะฟีเจอร์ เพื่อให้ reuse ได้ง่าย
- ฟีเจอร์ใหม่ให้สร้างภายใต้ `lib/features/<feature>/...`

เริ่มต้นฟีเจอร์ใหม่:
1. สร้างโฟลเดอร์ `lib/features/<feature>/{domain,data,presentation}`
2. สร้าง interface repository ใน domain
3. ทำ data source + repository impl ใน data
4. ทำหน้า UI และ state ที่ presentation
