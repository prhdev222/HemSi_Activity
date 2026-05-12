# Elective Activity — Turso + Admin (Cloudflare Pages)

## โครงสร้างใน repo

```
.
├── index.html                 ← หน้าหลัก (นักศึกษา)
├── admin/index.html           ← Admin (PIN + CRUD)
├── functions/api/             ← Cloudflare Pages Functions
│   ├── items.js               → GET /api/items
│   └── admin/
│       ├── login.js           → POST /api/admin/login
│       ├── items.js           → GET+POST /api/admin/items
│       ├── items/[id].js      → PUT+DELETE /api/admin/items/:id
│       └── config.js          → GET+PUT /api/admin/config
├── package.json               ← dependency @libsql/client + wrangler
├── seed.sql                   ← รัน 1 ครั้งบน Turso
└── .dev.vars.example          ← คัดลอกเป็น .dev.vars สำหรับรัน local
```

---

## รันบนเครื่อง (local)

1. ติดตั้ง dependencies:

```bash
npm install
```

2. สร้างไฟล์ `.dev.vars` ที่ root โปรเจกต์ (อย่า commit) — คัดลอกจาก `.dev.vars.example` แล้วใส่ค่า Turso + PIN + secret จริง

3. เปิด dev server (หน้าเว็บ + Functions เหมือน production):

```bash
npm run dev
```

เปิดเบราว์เซอร์ตาม URL ที่ Wrangler แสดง (มักเป็น `http://127.0.0.1:8788`)

- หน้าหลัก: `/`
- Admin: `/admin/`

---

## Deploy — Cloudflare Pages + GitHub (แนะนำ)

### A. เชื่อม GitHub จาก Cloudflare (auto deploy เวลา push)

1. Push โค้ดขึ้น GitHub repo (สาขา `main` หรือ `master`)
2. [Cloudflare Dashboard](https://dash.cloudflare.com/) → **Workers & Pages** → **Create** → **Pages** → **Connect to Git**
3. เลือก repo นี้ แล้วตั้งค่า build ดังนี้:

| การตั้งค่า | ค่า |
|------------|-----|
| **Framework preset** | None |
| **Build command** | **`npm run build`** (รัน `npm ci` ติดตั้ง `@libsql/client` ก่อน bundle Functions) |
| **Build output directory** | **`.`** (จุดเดียว = root ของ repo) |

**สำคัญ:** ถ้าไม่ใส่ build command ระบบจะข้าม `npm install` แล้ว build Functions จะพังด้วยข้อความ `Could not resolve "@libsql/client/http"` — ต้องมีขั้นตอนติดตั้ง dependency เสมอ

ทางเลือกอื่นที่ใช้ได้เหมือนกัน: build command เป็น **`npm ci`** หรือ **`npm install`** โดยตรง (ไม่ต้องผ่าน `npm run build`)

4. หลัง deploy ครั้งแรก ไปที่ **Settings** → **Environment variables** ใส่ `TURSO_URL`, `TURSO_AUTH_TOKEN`, `ADMIN_PIN`, `ADMIN_SECRET` (ทั้ง Production และ Preview ตาม README เดิม)

5. ทุกครั้งที่ push ไปยังสาขาที่ผูกไว้ Cloudflare จะ build + deploy อัตโนมัติ

### B. Deploy ด้วย GitHub Actions (ทางเลือก)

ถ้าใช้ workflow `.github/workflows/cloudflare-pages.yml` ให้สร้าง secrets ใน repo:

- `CLOUDFLARE_API_TOKEN` — สร้างที่ Cloudflare → My Profile → API Tokens (สิทธิ์แก้ไข Cloudflare Pages)
- `CLOUDFLARE_ACCOUNT_ID` — จากหน้า Overview ของ account
- `CLOUDFLARE_PAGES_PROJECT_NAME` — ชื่อโปรเจกต์ Pages ที่สร้างไว้แล้ว

> ถ้าใช้วิธี **A** อย่างเดียว สามารถลบหรือปิด workflow นี้ได้เพื่อไม่ให้ deploy ซ้ำซ้อน

---

## Turso + seed (เหมือนเดิม)

```bash
turso db create elective-activity
turso db show elective-activity
turso db tokens create elective-activity
turso db shell elective-activity < seed.sql
```

ตรวจสอบ:

```bash
turso db shell elective-activity "SELECT count(*) FROM items;"
# ควรได้ 8
```

---

## ทดสอบหลัง deploy

- หน้าหลัก: `https://<ชื่อโปรเจกต์>.pages.dev/`
- Admin: `https://<ชื่อโปรเจกต์>.pages.dev/admin/`
- API: `https://<ชื่อโปรเจกต์>.pages.dev/api/items`

---

## แก้ `/api/items` ขึ้น 500 (โหลดข้อมูลไม่สำเร็จ)

1. **ดูข้อความ error จริง** — ในเบราว์เซอร์ DevTools → **Network** → คลิก request `api/items` → แท็บ **Response** มักจะเป็น JSON แบบ `{"error":"..."}` (โค้ดส่ง message จาก Turso / runtime กลับมา)
2. **เปิด `nodejs_compat` บน Workers runtime** (สำคัญมากเมื่อใช้ `@libsql/client` บน Pages Functions):
   - ไป **Workers & Pages** → โปรเจกต์ → **Settings** → **Functions** → **Compatibility flags**
   - เพิ่ม **`nodejs_compat`** ทั้ง **Production** และ **Preview** (ถ้าใช้ preview URL)
   - จากนั้น **Deployments** → **Retry deployment** หรือ push commit ใหม่
   - อ้างอิง: [Compatibility flags](https://developers.cloudflare.com/workers/configuration/compatibility-flags/)
3. **ตรวจค่า Turso** — `TURSO_URL` เป็น `libsql://...` คู่กับ DB ที่รัน `seed.sql` แล้ว และ `TURSO_AUTH_TOKEN` ไม่มีช่องว่างเกินหลัง paste

---

## การใช้งาน Admin Panel

1. เปิด `/admin/`
2. กรอก PIN ที่ตั้งไว้ใน `ADMIN_PIN`
3. แก้ไข/เพิ่ม/ลบ/ซ่อนรายการกิจกรรมได้เลย
4. แก้ไขข้อความประกาศ (Notice) และ link Google Form ใน tab "ข้อความประกาศ"
5. Token หมดอายุใน 8 ชั่วโมง (ต้อง login ใหม่)

---

## Security Notes

- `/admin/` ป้องกันด้วย PIN + HMAC token (8 ชั่วโมง)
- `/api/admin/*` ทุก endpoint ตรวจสอบ token ก่อนทำงาน
- `/api/items` เป็น public (ไม่ต้อง auth) — ข้อมูลกิจกรรมไม่ sensitive
- ถ้าต้องการเปลี่ยน PIN ให้แก้ที่ Cloudflare Pages environment variable แล้ว redeploy
