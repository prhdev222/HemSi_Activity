-- ================================================
-- Turso DB Setup for elective-activity
-- Run via: turso db shell <db-name> < seed.sql
-- ================================================

CREATE TABLE IF NOT EXISTS items (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  sort_order  INTEGER NOT NULL DEFAULT 0,
  tag_th      TEXT NOT NULL,
  tag_en      TEXT NOT NULL DEFAULT '',
  keywords_th TEXT NOT NULL DEFAULT '',
  keywords_en TEXT NOT NULL DEFAULT '',
  answer_th   TEXT NOT NULL,
  answer_en   TEXT NOT NULL DEFAULT '',
  visible_th  INTEGER NOT NULL DEFAULT 1,  -- 1=show in TH, 0=hide in TH
  visible_en  INTEGER NOT NULL DEFAULT 1   -- 1=show in EN, 0=hide in EN
);

CREATE TABLE IF NOT EXISTS config (
  key       TEXT PRIMARY KEY,
  value_th  TEXT NOT NULL DEFAULT '',
  value_en  TEXT NOT NULL DEFAULT ''
);

-- ================================================
-- Migration helper (run if upgrading from old schema with `visible`)
-- ALTER TABLE items ADD COLUMN visible_th INTEGER NOT NULL DEFAULT 1;
-- ALTER TABLE items ADD COLUMN visible_en INTEGER NOT NULL DEFAULT 1;
-- UPDATE items SET visible_th = visible, visible_en = visible;
-- ================================================

-- ================================================
-- Seed: items
-- ================================================

INSERT INTO items (sort_order, tag_th, tag_en, keywords_th, keywords_en, answer_th, answer_en, visible_th, visible_en) VALUES
(1,
 'เตรียมก่อนมาดูงาน',
 'Before You Start',
 'line,กลุ่ม,add,elective,ก่อน,เตรียม,นัด,chief,แนะนำตัว',
 'line,group,add,elective,before,prepare,chief,introduce,join',
 'ให้ add เข้ากลุ่ม LINE elective ก่อนวันมาดูงาน และแนะนำตัวกับทีม

ดูรายละเอียดตารางราวด์วอร์ด + ตารางออก OPD ใน note ของกลุ่ม LINE

ให้นัดหมายเวลาและสถานที่ราวด์วอร์ดกับ chief resident ของสายด้วย',
 'Please join the LINE elective group before your start date and introduce yourself to the team.

Check the ward round schedule and OPD schedule posted in the LINE group notes.

Confirm the ward round time and meeting point with the chief resident of your assigned team.',
 1, 1),

(2,
 'ราวด์วอร์ด — ทีมและเวลา',
 'Ward Round — Teams & Schedule',
 'ราวด์,วอร์ด,ทีม,ชาย,หญิง,ปรึกษา,7.30,7:30,เช้า,เวลา,blood smear,bone marrow,attending,ชั้น 23,นวมินทร์,มะเร็ง,เคมีบำบัด,leukemia,lymphoma',
 'ward,round,team,male,female,consult,7:30,morning,time,blood smear,bone marrow,attending,23rd floor,navamindra,chemo,leukemia,lymphoma',
 'วอร์ดโลหิตวิทยาอยู่ที่ชั้น 23 อาคารนวมินทรบพิตร 84 พรรษา
▸ ปีกใต้ — ผู้ป่วยชาย (ให้เคมีบำบัดแก่ผู้ป่วยมะเร็งเลือด เช่น Acute leukemia, Lymphoma)
▸ ปีกเหนือ — ผู้ป่วยหญิง

ทั้งสองทีมรับปรึกษาผู้ป่วยอายุรกรรมและวอร์ดต่างภาควิชาที่มีปัญหาทางโลหิตวิทยา

▸ ราวด์เช้า: 7:30 น. (เวลาอาจเปลี่ยน — นัดกับ chief resident ก่อน)
▸ ช่วงบ่าย: ราวด์เคสรับปรึกษา ดู blood smear, bone marrow กับอาจารย์ attending',
 'The hematology ward is on the 23rd floor of the Navamindrapobitr 84th Anniversary Building.
▸ South wing — male patients (chemotherapy for hematologic malignancies e.g. acute leukemia, lymphoma)
▸ North wing — female patients

Both teams also provide consultations for hematologic problems in internal medicine and other department wards.

▸ Morning round: 7:30 AM (time may vary — confirm with chief resident)
▸ Afternoon: Consult rounds, blood smear and bone marrow review with attending',
 1, 1),

(3,
 'แกรนด์ราวด์ — วันจันทร์ 13:00–15:00',
 'Grand Round — Monday 13:00–15:00',
 'แกรนด์ราวด์,grand round,จันทร์,13,15,อภิปราย,เคส,น่าสนใจ,problem list',
 'grand round,monday,13:00,15:00,discuss,case,interesting,problem list',
 'ทุกวันจันทร์ เวลา 13:00–15:00 น.

แพทย์ประจำบ้านนำเสนอเคสโลหิตวิทยาน่าสนใจ 2 เคส
▸ นศพ. อาจได้รับโอกาสทำ problem list
▸ ร่วม discussion ตามความสมัครใจ

(สอบถามสถานที่จากแพทย์ประจำบ้าน)',
 'Every Monday, 13:00–15:00

The resident presents 2 interesting hematology cases.
▸ Elective students may be asked to provide the patient''s problem list
▸ Discussion is open — all participants may contribute voluntarily

(Ask the resident for the venue on the day)',
 1, 1),

(4,
 'Hematology Conference — วันพฤหัสบดี 13:15–14:15',
 'Hematology Conference — Thursday 13:15–14:15',
 'conference,พฤหัส,พฤหัสบดี,13.15,13:15,interesting case,journal club,hpc,coagulation,morbidity,mortality,เสียชีวิต,pathology,เลือด,การแข็งตัว',
 'conference,thursday,13:15,14:15,interesting case,journal club,hpc,coagulation,morbidity,mortality,pathology,deceased,bleeding,thrombosis',
 'ทุกวันพฤหัสบดี เวลา 13:15–14:15 น.

กิจกรรมหมุนเวียนแต่ละสัปดาห์:
1. Interesting case — แพทย์ประจำบ้านนำเสนอและทบทวนวิชาการ; นศพ./elective อาจทำ problem list
2. Journal club
3. Hematology Pathology Conference (HPC) — นำเสนอพร้อมอาจารย์พยาธิแพทย์ รวมชิ้นเนื้อที่น่าสนใจหรือยากในการวินิจฉัย
4. Coagulation round — เคสปัญหาการแข็งตัวของเลือด, thrombosis, ภาวะเลือดออกผิดปกติ หรือ lab น่าสนใจ
5. Morbidity & Mortality Conference — หัวหน้า resident นำเสนอเคสที่เสียชีวิต เพื่อพัฒนาการดูแล',
 'Every Thursday, 13:15–14:15

Activities rotate weekly:
1. Interesting Case — resident presents and reviews the relevant literature; students may be asked for a problem list
2. Journal Club
3. Hematology Pathology Conference (HPC) — case presented alongside a pathologist, including histology review (rare or diagnostically challenging cases)
4. Coagulation Round — cases on coagulation disorders, thrombosis, abnormal bleeding, or intriguing coagulation lab results
5. Morbidity & Mortality Conference — chief resident presents deceased cases from the month to improve patient care',
 1, 1),

(5,
 'OPD — ตารางและระเบียบ',
 'OPD — Schedule & Guidelines',
 'opd,ออกตรวจ,ตาราง,observe,9.00,9:00,9.30,9:30,700,ชั้น 7,อาหาร,เที่ยง,ใบสั่งยา,รหัส',
 'opd,schedule,observe,9:00,9:30,room 700,7th floor,lunch,outpatient,clinic',
 'ดูตาราง OPD ได้ใน note ของกลุ่ม LINE (อาจารย์จัดตารางให้แต่ละคน)

▸ นศพ.: ไปถึง ห้อง 700 ชั้น 7 อาคาร OPD ช่วง 9:00–9:30 น.
▸ OPD ช่วงเวลา 9:00–12:00 น.
▸ หลัง OPD มีอาหารเที่ยงที่ห้องด้านหลัง OPD — ร่วมรับประทานได้เลย

ก่อนมาดูงาน 1–2 สัปดาห์: กรุณาระบุ objective/goal ที่ต้องการเรียนรู้
หลังจบดูงาน: กรอก reflection/feedback ผ่าน Google Form ที่ส่งให้',
 'Check your personal OPD schedule (arranged by the lecturer) in the LINE group.

▸ Go to Room 700, 7th floor, OPD Building by 9:00–9:30 AM
▸ OPD hours: 9:00–12:00
▸ Lunch is available at the room behind OPD after the session

1–2 weeks before your elective: please specify your learning objective/goal
After finishing: please fill in the reflection/feedback via the Google Form provided',
 1, 1),

(6,
 'Lectures Online — SelecX',
 'Lectures Online — SelecX',
 'lecture,selecx,online,hematology for internist,thrombocytopenia,anemia,leukemia,lymphoma,thalassemia,itp,aiha,mpn,anticoagulant,coagulogram,blood product',
 'lecture,selecx,online,hematology for internist,thrombocytopenia,anemia,leukemia,lymphoma,thalassemia,itp,aiha,mpn,anticoagulant,coagulogram,blood product',
 'เข้าได้ผ่าน SelecX ภาควิชาอายุรศาสตร์
→ การศึกษาหลังปริญญา → COURSE → Hematology for Internist 2022

หัวข้อแนะนำ:
• Thrombocytopenia in hospitalized patients
• Acute anemia in hospitalized patients
• Management of hematologic-oncologic emergencies
• The simple concept to interpret coagulogram
• Anticoagulants: traditional and novel drugs
• ITP, AIHA, MPN, Acute leukemia
• How to choose appropriate blood products
• A practical care in thalassemic patients
• Approach to bleeding and thrombosis
• Non-Hodgkin / Hodgkin lymphoma',
 'Access via SelecX, Department of Medicine
→ Postgraduate Education → COURSE → Hematology for Internist 2022

Recommended topics:
• Thrombocytopenia in hospitalized patients
• Acute anemia in hospitalized patients
• Management of hematologic-oncologic emergencies
• The simple concept to interpret coagulogram
• Anticoagulants: traditional and novel drugs
• ITP, AIHA, MPN, Acute leukemia
• How to choose appropriate blood products
• A practical care in thalassemic patients
• Approach to bleeding and thrombosis
• Non-Hodgkin / Hodgkin lymphoma',
 1, 0),  -- SelecX: TH only, hide from EN

(7,
 'Lectures ในสาขา — ศุกร์ที่ 1 และ 3',
 'In-department Lectures — 1st & 3rd Friday',
 'lecture,resident med,สาขา,เที่ยง,ศุกร์,priority,วันที่ 1,วันที่ 3',
 'lecture,resident med,department,friday,priority,first,third',
 '▸ Lectures สำหรับ resident med ในสาขา:
  เข้าร่วมได้ — สอบถามวันเรียนจาก resident ในทีมวอร์ด
  การเรียน lecture เป็น priority แรก (ถ้า attending นัดราวด์พร้อมกัน ให้เรียนก่อน)

▸ Lectures ช่วงเที่ยง:
  ทุกวันศุกร์ที่ 1 และ 3 ของเดือน
  สอบถามสถานที่หรือ link online จากทีมวอร์ด',
 '▸ Lectures for in-department resident med:
  You are welcome to join — ask the ward team resident for the schedule
  Lectures are the first priority (if attending schedules a round at the same time, attend the lecture first)

▸ Midday lectures:
  Every 1st and 3rd Friday of the month
  Ask the ward team for the venue or online link',
 1, 1),

(8,
 'เสร็จสิ้นการดูงาน',
 'After Your Elective',
 'เสร็จ,leave,google form,ประเมิน,ฟีดแบ็ก,จบ,ออกกลุ่ม,reflection',
 'finish,done,end,leave,google form,feedback,reflection,complete,final',
 'เมื่อเสร็จสิ้นการดูงาน:

1. กรอก Google Form reflection/feedback ที่ส่งให้ — แสดงความคิดเห็นและข้อเสนอแนะ
2. Leave กลุ่ม LINE ได้เลย

ขอให้มีความสุขและได้รับความรู้ด้านโลหิตวิทยาอย่างเต็มที่ 🩸',
 'When your elective placement is finished:

1. Fill in the Google Form with your reflection — share what you gained and any suggestions for future improvement
2. You may then leave the LINE group

We wish you all the happiness and a wealth of hematology knowledge! 🩸',
 1, 1);

-- ================================================
-- Seed: config
-- ================================================

INSERT INTO config (key, value_th, value_en) VALUES
('notice',
 '<strong>⚠️ ก่อนเริ่มดูงาน:</strong> กรุณา add เข้ากลุ่ม LINE ก่อนและแนะนำตัวกับทีม<br><strong>📋 วันแรก:</strong> Staff จะ orientate กิจกรรมทั้งหมดให้',
 '<strong>⚠️ Before starting:</strong> Please join the LINE group and introduce yourself to the team<br><strong>📋 Day 1:</strong> Staff will orientate all activities on your first day'),
('feedback_url_th',
 'https://docs.google.com/forms/d/e/1FAIpQLSeHPePaS04OyV44_Uh3Hw1ifGKNaO5nK6tMqtXP_b-trJMffw/viewform',
 'https://docs.google.com/forms/d/e/1FAIpQLScAXkpKgsEkYLoR6xz4QjdkVOps9fDxc3axagOSxNNnsq2QVA/viewform');
