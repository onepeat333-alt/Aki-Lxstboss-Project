# คู่มือใช้งาน Aki Lxst Boss Optimize

ปรับค่า FiveM ให้ลื่นขึ้น แบบไม่ต้องติดตั้งอะไร — แตกไฟล์ออกมาใช้บนเครื่องไหนก็ได้

---

## 1. ข้อกำหนด

| ต้องมี | หมายเหตุ |
| --- | --- |
| Windows 10 / 11 | มี PowerShell 5.1 ติดมากับ Windows อยู่แล้ว ไม่ต้องติดตั้งอะไรเพิ่ม |
| เบราว์เซอร์ | Chrome / Edge / Firefox รุ่นไหนก็ได้ |
| FiveM | ติดตั้งแล้วจะใช้งานได้ครบทุกฟีเจอร์ (ยังไม่ติดตั้งก็เปิดดูได้) |
| สิทธิ์ Administrator | จำเป็นเฉพาะหน้า **Optimize** และ **Network** (แก้ registry / QoS / DNS) |

> ไม่ต้องมี Node.js, ไม่ต้อง build, ไม่ต้องต่อเน็ต

---

## 2. เริ่มใช้งาน

1. แตกไฟล์ ZIP ออกมาไว้ในโฟลเดอร์ที่ต้องการ (เช่น `D:\AkiBoss`)
2. **คนทั่วไป** → ดับเบิลคลิก **`run.bat`**
   **ต้องใช้ทุกฟีเจอร์** → คลิกขวา **`run-admin.bat`** → เลือก *Run as administrator*
3. เบราว์เซอร์จะเปิดหน้าแอปให้เอง (ค่าเริ่มต้น `http://localhost:5180`)
   - ถ้าพอร์ต 5180 ถูกใช้แล้ว แอปจะขยับไปพอร์ตถัดไปให้เอง
   - ถ้าเปิดแล้วแต่หน้าเว็บว่าง ให้ดูที่หน้าต่าง PowerShell ว่ามีข้อความอะไร
4. ปิดหน้าต่าง PowerShell เมื่อเลิกใช้ (หรือดับเบิลคลิก `stop.bat`)

**ครั้งแรกที่รัน** Windows อาจขึ้นถามเรื่อง Firewall — อนุญาตเฉพาะ **Private network** ก็พอ (แอปรับฟังเฉพาะเครื่องตัวเอง)

### ทางเลือก: เรียกด้วยคำสั่ง PowerShell

เปิด PowerShell ในโฟลเดอร์แอป แล้วพิมพ์

```powershell
.\AkiBossMap.ps1            # เปิดแอป
.\AkiBossMap.ps1 -Admin     # เปิดแบบ Administrator (มี UAC ถาม)
.\AkiBossMap.ps1 -Check     # ตรวจไฟล์ทั้งหมดก่อนส่งให้คนอื่น
.\AkiBossMap.ps1 -Stop      # ปิดเซิร์ฟเวอร์ที่ค้าง
```

ถ้าขึ้นว่า *"running scripts is disabled on this system"* ให้ใช้
`powershell -ExecutionPolicy Bypass -File .\AkiBossMap.ps1`

### ทางเลือก: EXE ไฟล์เดียว (ไม่ต้องเปิด PowerShell เอง)

ถ้าคนที่รับไฟล์ไม่อยากยุ่งกับ ZIP ให้ส่ง `Aki-Lxstboss-optimize.exe` ไปตัวเดียว หรือให้เขารันคำสั่งติดตั้งอัตโนมัติ (โหลด + วางไฟล์ + สร้างทางลัดให้):

```powershell
irm https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/install.ps1 | iex
```

หรือรัน EXE ตรง ๆ แบบไม่ติดตั้ง:

```powershell
Invoke-WebRequest -Uri "https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/Aki-Lxstboss-optimize.exe" -OutFile "$env:TEMP\Aki-Lxstboss-optimize.exe"; Start-Process "$env:TEMP\Aki-Lxstboss-optimize.exe"
```

โปรแกรมจะแตกไฟล์ของตัวเองไปที่ `%LOCALAPPDATA%\AkiLxstboss\runtime` แล้วเปิดหน้าแอปให้อัตโนมัติ
(ครั้งแรก SmartScreen อาจเตือน → **More info → Run anyway**)

### ทางเลือก: Quick Setup ในหน้า Settings

ถ้าไม่อยากไล่ปรับทีละหน้า ไปที่ **Settings → Quick Setup**

1. เลือกโปรไฟล์กราฟิก (Boss Boost / Max FPS / Daily Smooth / Ultra Visual)
2. เลือกโหมด
   - **เปิดทั้งหมด (Lxst สุด)** — ใช้โปรไฟล์ + เปิด tweak ทุกตัวในครั้งเดียว (มีหน้ายืนยันก่อน)
   - **ไล่ทีละตัว** — ทำเหมือนกัน แต่เว้นจังหวะให้เห็นทีละรายการ พร้อมแถบความคืบหน้า
3. ระบบสำรอง `gta5_settings.xml` ให้ก่อนเขียนทุกครั้ง — ถ้าอยากปิด tweak ให้ไปปิดทีละตัวที่หน้า **Optimize**

### ถ้าอยากให้หน้าจอลื่นขึ้น / ประหยัดการ์ดจอ

ไปที่ **Settings → ประสิทธิภาพหน้าจอ** เลือกได้ 3 โหมด

- **อัตโนมัติ** (แนะนำ) — ระบบเลือกให้ตามสเปกเครื่อง และลดเอฟเฟกต์ให้เองถ้าตรวจพบเฟรมตก
- **ลื่นไหล** — ปิดเบลอและเงาที่ขยับตลอดเวลา เหมาะกับตอนเล่นเกม
- **เอฟเฟกต์เต็ม** — เปิดอนิเมชันครบทุกตัว (สวยที่สุด แต่ใช้การ์ดจอมากกว่า)

ค่าที่เลือกจะจำไว้ในเบราว์เซอร์ (localStorage) และมีผลทันทีโดยไม่ต้องรีสตาร์ทแอป

---

## 2.5 สร้างไฟล์แจกเอง (สำหรับคนทำ)

ต้องมี Windows + PowerShell 5.1 เท่านั้น (ไม่ต้องติดตั้ง Node.js หรือ .NET SDK)

```powershell
.\AkiBossMap.ps1 -Check                                  # ตรวจก่อน
powershell -ExecutionPolicy Bypass -File .\build-dist.ps1 # อัด ZIP
powershell -ExecutionPolicy Bypass -File .\build-exe.ps1  # สร้าง EXE ไฟล์เดียว
.\dist\Aki-Lxstboss-optimize.exe -Check                            # ตรวจตัวที่แพ็กแล้ว
```

- ผลลัพธ์: `dist\Aki-Lxst-Boss-Optimize-v<เวอร์ชัน>.zip` และ `dist\Aki-Lxstboss-optimize.exe`
- ออกรุ่นใหม่ให้แก้เลขเวอร์ชัน 4 จุด: `server.ps1` (`$appVer`), `build-dist.ps1` (`$version`), `app/js/data.js` (`MOCK_STATUS.version`), `exe-launcher/Program.cs` (`Version`)
- `build-dist.ps1` จะไม่สร้าง ZIP ถ้าเวอร์ชันไม่ตรง หรือรูปที่ UI เรียกใช้หายไป

### ทำเป็นแอป (ทางลัด Desktop / Start Menu)

```powershell
powershell -ExecutionPolicy Bypass -File .\install-app.ps1            # สร้างทางลัด
powershell -ExecutionPolicy Bypass -File .\install-app.ps1 -Uninstall  # ถอนทางลัด
```

ได้ไอคอนบน Desktop และใน Start Menu อย่างละ 2 ตัว (ปกติ + Admin) — ดับเบิลคลิกแล้วแอปเปิดเองเหมือนโปรแกรมทั่วไป

### build-all.ps1 — ตรวจ + แพ็กในคำสั่งเดียว

```powershell
powershell -ExecutionPolicy Bypass -File .\build-all.ps1
```

ทำ 4 อย่างต่อกัน: `-Check` → อัด ZIP → สร้าง EXE → เปิดโฟลเดอร์ `dist` (มี `-NoOpen` / `-SkipCheck`)

---

## 3. หน้าจอแต่ละหน้า

| หน้า | ทำอะไรได้ |
| --- | --- |
| **Home** | ดูสเปกเครื่อง สถานะ FiveM ขนาดแคช โปรไฟล์ที่ใช้อยู่ และทางลัดแนะนำ |
| **Graphics** | ปรับค่าภาพจริงใน `gta5_settings.xml` 5 หมวด (การแสดงผล / คุณภาพภาพ / ระยะมองเห็น / เอฟเฟกต์ / ขั้นสูง) มีแถบกระโดดไปหมวดที่ต้องการได้ ดูผลก่อนบันทึกได้ |
| **Profiles** | โปรไฟล์สำเร็จรูป 4 แบว — **Boss Boost** (แนะนำ), **Max FPS**, **Daily Smooth**, **Ultra Visual** |
| **Optimize** | 42 tweak แบ่ง **4 หมวด** ด้วยแถบตัวกรองด้านบน (FiveM / Windows / Network / Input) แยกระดับ **SAFE** (กดครั้งเดียวเปิดทั้งหมด) กับ **Advanced** (ต้องเลือกเอง) |
| **Clean Up** | ล้างแคช FiveM / browser / log / crash dump, ล้าง DNS cache, ดูพื้นที่ที่คืนได้ |
| **Network** | Bandwidth Cap (QoS), เปลี่ยน DNS, เชื่อมต่อเซิร์ฟเวอร์, เซิร์ฟเวอร์ที่บันทึกไว้ |
| **Settings** | กำหนดโฟลเดอร์ GTA V, ดู/กู้คืนไฟล์สำรอง (settings / registry / CitizenFX.ini), เลือกโหมดประสิทธิภาพหน้าจอ, ข้อมูลแอป |

---

## 4. ความปลอดภัย (สำคัญ)

- ทุกครั้งที่แอปแก้ไฟล์หรือ registry จะ **สำรองค่าเดิมไว้ก่อน** และกู้คืนได้จากหน้า Settings
- ไฟล์ที่ถูกแก้คือไฟล์จริงที่เกมอ่าน:
  - `%APPDATA%\CitizenFX\gta5_settings.xml` (ไฟล์กราฟิกของ FiveM)
  - `%LOCALAPPDATA%\FiveM\FiveM.app\CitizenFX.ini` (ตั้งค่าเปิดเกม)
  - Registry ของ Windows (เฉพาะคีย์ที่ระบุไว้ กู้คืนได้จากไฟล์ `.reg`)
- ถ้า FiveM กำลังเปิดอยู่:
  - การบันทึกค่ากราฟิกจะขอยืนยันก่อน (เกมเขียนทับไฟล์ตอนปิด)
  - การกู้คืนไฟล์จะถูกปิดกั้น
  - tweak กลุ่ม **FiveM / GTA Engine** จะกดไม่ได้จนกว่าจะปิดเกม
- ค่าในหน้า Optimize ที่อยู่ระดับ **Advanced** มีผลจริงไม่แน่นอนและบางตัวต้องรีสตาร์ทเครื่อง
  ให้เปิดทีละตัวแล้วทดสอบ ไม่แนะนำให้เปิดทั้งหมดรวดเดียว

---

## 5. ข้อมูลและสำรองอยู่ที่ไหน

ทุกอย่างของแอปเก็บที่

```
%LOCALAPPDATA%\AkiLxstboss\
├─ backups\            สำรอง gta5_settings.xml (.xml)
├─ regbackups\         สำรอง registry (.reg)
└─ citizenfx-backups\  สำรอง CitizenFX.ini (.ini)
```

**ถอนการติดตั้ง:** ปิดแอป แล้วลบโฟลเดอร์ `%LOCALAPPDATA%\AkiLxstboss` (ถ้าใช้ EXE ไฟล์เดียว โฟลเดอร์ `runtime` ที่แตกออกมาอยู่ในนี้ด้วย) + โฟลเดอร์ที่แตก ZIP ไว้
(ค่า registry ที่แก้ไว้ให้กู้คืนจากหน้า Settings → สำรอง registry ก่อน)

---

## 6. แก้ปัญหาได้ง่าย ๆ

| อาการ | วิธีแก้ |
| --- | --- |
| หน้าเว็บเปิดไม่ได้ | ดูหน้าต่าง PowerShell — ถ้าขึ้นว่า port ถูกใช้ ให้ปิดโปรแกรมนั้นแล้วเปิดใหม่ (แอปเลือกพอร์ตใหม่ให้เอง) |
| หน้าเว็บขึ้นว่า "โหมดตัวอย่าง" | backend ไม่ทำงาน — เปิดด้วย `run.bat` แล้วกดรีเฟรช |
| ปุ่มที่มีป้าย ADMIN กดไม่ได้ | ยังไม่ได้รันแบบ Administrator — ใช้ `run-admin.bat` |
| แอปหาโฟลเดอร์ GTA V ไม่เจอ | ไปหน้า Settings → พิมพ์พาธโฟลเดอร์เกมเอง (เช่น `D:\SteamLibrary\steamapps\common\Grand Theft Auto V`) แล้วกดบันทึก |
| ค่ากราฟิกไม่เปลี่ยน | ปิด FiveM ให้หมดก่อนบันทึก แล้วเปิดเกมใหม่ |
| PowerShell ขึ้นว่า *running scripts is disabled* | ใช้ `powershell -ExecutionPolicy Bypass -File .\AkiBossMap.ps1` (ไม่ต้องแก้ค่าถาวรของ Windows) |
| อยากรู้ว่าชุดไฟล์ที่ได้มาครบไหม | รัน `AkiBossMap.ps1 -Check` — จะไล่ตรวจไฟล์ สคริปต์ รูป และพอร์ตให้ |

---

## 7. หมายเหตุ

- โปรแกรมนี้แก้ไฟล์จริงบนเครื่องของผู้ใช้เท่านั้น และรันฟังเฉพาะ `localhost` (เครื่องตัวเอง) ไม่มีการส่งข้อมูลออกไปไหน
- ค่าที่อยู่ในโปรไฟล์ภาพจะไม่แตะความละเอียดและเฟรมเรตของคุณ (ต้องตั้งเองที่หน้า Graphics)
- ใช้งานส่วนตัว / แจกจ่ายต่อได้ — ถ้าเอาไปพัฒนาต่อ ให้เคารพสิทธิ์ของผู้อื่นและอย่าเอาไปขายต่อ
