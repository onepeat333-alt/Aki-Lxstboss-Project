# Aki Lxst Boss Optimize

โปรแกรมตั้งค่า FiveM แบบพกพา (ไม่ต้องติดตั้ง Node.js, ไม่ต้อง build) ธีมดำ–โครม (obsidian / chrome) HUD
รันบนเครื่องตัวเองผ่าน PowerShell + เปิดหน้าเว็บที่ `http://localhost:5180`
เวอร์ชัน **2.6.0** — แจกจ่ายให้คนอื่นใช้ได้ทันที (ดูหัวข้อ [แจกจ่ายให้คนอื่น](#แจกจ่ายให้คนอื่น))

## เริ่มใช้งาน

1. ดับเบิลคลิก **`run.bat`**
   - ถ้าต้องการใช้ QoS, เปลี่ยน DNS หรือแก้ registry ให้คลิกขวา **`run-admin.bat`** → **Run as administrator**
2. เบราว์เซอร์จะเปิดที่ `http://localhost:5180` อัตโนมัติ
   - ถ้าพอร์ต 5180 ถูกโปรแกรมอื่นใช้ แอปจะขยับไปพอร์ตถัดไปให้เอง (5180–5199)
   - ถ้าเปิดแอปซ้ำ แอปจะเปิดหน้าต่างเดิมให้แทน ไม่สร้างซ้ำ
3. ปิดหน้าต่าง PowerShell สีดำเมื่อเลิกใช้ (หรือรัน `stop.bat`)

> ครั้งแรกที่รัน Windows อาจถามเรื่อง firewall — อนุญาตเฉพาะ private network ก็พอ

### เรียกใช้ด้วยคำสั่ง PowerShell

เปิด PowerShell ในโฟลเดอร์แอป (Shift + คลิกขวาที่โฟลเดอร์ → *Open PowerShell window here*) แล้วพิมพ์

```powershell
.\AkiBossMap.ps1                 # เปิดแอป (โหมดปกติ)
.\AkiBossMap.ps1 -Admin          # ขอสิทธิ์ Administrator เองผ่าน UAC
.\AkiBossMap.ps1 -Check          # ตรวจไฟล์/สคริปต์/พอร์ต ก่อนส่งให้คนอื่น
.\AkiBossMap.ps1 -Stop           # ปิดเซิร์ฟเวอร์ที่ค้างอยู่
.\AkiBossMap.ps1 -Port 5190      # เริ่มที่พอร์ตอื่น
.\AkiBossMap.ps1 -NoBrowser      # เปิดเซิร์ฟเวอร์แต่ไม่เด้งเบราว์เซอร์
```

ถ้า Windows บล็อกสคริปต์ (ExecutionPolicy) ให้เรียกแบบนี้แทน — ไม่ต้องแก้ค่าถาวรของเครื่อง:

```powershell
powershell -ExecutionPolicy Bypass -File .\AkiBossMap.ps1
```

`run.bat` / `run-admin.bat` ยังใช้ได้เหมือนเดิม (สะดวกสำหรับคนที่ไม่อยากเปิด PowerShell)

## ฟีเจอร์

| หน้า | ทำอะไรได้ |
| --- | --- |
| Home | ภาพรวมสเปกเครื่อง, สถานะ FiveM, แคช, โปรไฟล์ที่ใช้, Bandwidth Cap และทางลัด |
| กราฟิก | ปรับค่าจริงใน `gta5_settings.xml` **5 หมวด** (การแสดงผล · คุณภาพภาพ · ระยะมองเห็น · เอฟเฟกต์ · ขั้นสูง) มีแถบกระโดดไปหมวด + เพิ่มค่าใหม่: ระยะเงา, Shadow SplitZ, Max LOD Scale, MSAA Fragments/Quality, Pause on Focus Loss, 3D Audio |
| Profiles | ชุดค่าสำเร็จรูป 4 แบบ: **Boss Boost** (แนะนำ) / Max FPS / Daily Smooth / Ultra Visual — ไม่แตะความละเอียด/Hz |
| Optimize | **42 tweak** กรองตามหมวดได้ทันที (FiveM/GTA Engine · Windows & System · Network & Internet · Mouse/Keyboard/UI) แยกระดับ **Safe (2)** และ **Advanced/Caution (40)** อย่างตรงไปตรงมา — เพิ่ม TCP Fast Open, TCP Low-Latency, UDP URO, Reserved Bandwidth และค่า engine ใหม่ + สำรองก่อนแก้ทุกครั้ง |
| ประสิทธิภาพ | ล้างแคช FiveM, แคช browser/subprocess, log/crash dump, ล้าง DNS, ดูผลลัพธ์แบบเรียลไทม์ |
| Network | **Bandwidth Cap (QoS)**: สร้าง `GameOpt_*` policy เพื่อจำกัดทราฟฟิก FiveM/GTA + พอร์ต 30120; ใช้เฉพาะเมื่อ upload เต็ม/เกิด bufferbloat |
| ตั้งค่า | **Quick Setup**: เลือกโปรไฟล์ + เปิดทุกอย่างในคลิกเดียว (โหมด Lxst สุด หรือไล่ทีละตัวพร้อมแถบความคืบหน้า), กำหนดโฟลเดอร์ GTA V (`CitizenFX.ini` → `IVPath`), ดู/กู้คืนไฟล์สำรอง settings, registry backup และ CitizenFX.ini backup |

## วิธีทำ (build จากซอร์ส)

ต้องมีแค่ Windows 10/11 + PowerShell 5.1 (มีมาแล้ว) — ไม่ต้องติดตั้ง Node.js, npm หรือ .NET SDK

| ไฟล์ | หน้าที่ |
| --- | --- |
| `server.ps1` | HTTP server + tweak ทั้ง 42 รายการ + helper อ่าน/คืนค่า registry |
| `AkiBossMap.ps1` | ตัวเปิดแอป: `-Admin` `-Check` `-Stop` `-Port` `-NoBrowser` |
| `build-dist.ps1` | ตรวจความถูกต้อง + อัด ZIP สำหรับแจก |
| `build-exe.ps1` | เรียก `build-dist.ps1` แล้วฝัง ZIP เป็น EXE ไฟล์เดียว |
| `build-all.ps1` | **คำสั่งเดียวจบ**: ตรวจ → อัด ZIP → สร้าง EXE → เปิดโฟลเดอร์ `dist` |
| `install-app.ps1` | สร้าง/ถอนทางลัดแบบแอป (Desktop + Start Menu, มีตัวเลือก Admin) |
| `exe-launcher/Program.cs` | ตัวแตกไฟล์ของ EXE (คอมไพล์ด้วย `csc.exe` ที่มากับ Windows) |

ลำดับที่แนะนำ — แก้โค้ด → ตรวจ → แพ็ก:

**ทางลัด — คำสั่งเดียวจบ:**

```powershell
powershell -ExecutionPolicy Bypass -File .\build-all.ps1
```

สคริปต์นี้จะตรวจระบบ → อัด ZIP → สร้าง EXE → ลบโฟลเดอร์ staging → แสดง SHA256 → เปิดโฟลเดอร์ `dist`
(มี `-NoOpen` ถ้าไม่อยากให้เปิดโฟลเดอร์ และ `-SkipCheck` ถ้าอยากข้ามการตรวจ)

**แยกทีละขั้น (ถ้าต้องการควบคุมเอง):**

```powershell
# 1) ตรวจไฟล์/สคริปต์/พอร์ต/สิทธิ์
.\AkiBossMap.ps1 -Check

# 2) อัด ZIP (ถ้าตรวจไม่ผ่านจะไม่สร้างไฟล์)
powershell -ExecutionPolicy Bypass -File .\build-dist.ps1

# 3) สร้าง EXE ไฟล์เดียว (เรียก build-dist ให้เอง + พิมพ์ SHA256)
powershell -ExecutionPolicy Bypass -File .\build-exe.ps1

# 4) ตรวจตัวที่แพ็กแล้ว
.\dist\Aki-Lxstboss-optimize.exe -Check
```

ผลลัพธ์อยู่ใน `dist\`: `Aki-Lxst-Boss-Optimize-v<เวอร์ชัน>.zip` และ `Aki-Lxstboss-optimize.exe` (~400 KB)

**ออกรุ่นใหม่ต้องแก้เลขเวอร์ชันให้ตรงกัน 4 ที่** — `server.ps1` (`$appVer`), `build-dist.ps1` (`$version`),
`app/js/data.js` (`MOCK_STATUS.version`), `exe-launcher/Program.cs` (`Version`)
`build-dist.ps1` จะไม่ยอมสร้าง ZIP ถ้าเลขไม่ตรงกัน

ต้องคง **UTF-8 BOM** ของ `server.ps1` / `AkiBossMap.ps1` ไว้ (ภาษาไทยจะได้ไม่เพี้ยน) — `build-dist.ps1` ตรวจให้อัตโนมัติ

## ติดตั้งด้วยคำสั่งเดียว (จาก GitHub)

ไฟล์ที่ต้องอัปขึ้น repo มี **2 ไฟล์**: `Aki-Lxstboss-optimize.exe` (ตัวแอป) และ `install.ps1` (ตัวติดตั้ง)

```powershell
irm https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/install.ps1 | iex
```

ตัวติดตั้งจะ: ดาวน์โหลด EXE → เก็บที่ `%LOCALAPPDATA%\AkiLxstboss\app\Aki-Lxstboss-optimize.exe` → ตรวจว่าเป็นไฟล์ EXE จริง → สร้างทางลัด Desktop + Start Menu (ปกติ/Admin) → พิมพ์ SHA256

| คำสั่ง | ทำอะไร |
| --- | --- |
| `install.ps1` | ติดตั้ง/อัปเดต (ถ้าไฟล์เดิมเหมือนกันจะข้ามให้) |
| `install.ps1 -Force` | บังคับโหลดใหม่ |
| `install.ps1 -File .\dist\Aki-Lxstboss-optimize.exe` | ติดตั้งจากไฟล์ในเครื่อง (ไม่ต้องโหลด) |
| `install.ps1 -Dev` | ติดตั้งลง `...\app\dev` และเปิดหน้าต่าง console ค้างไว้ (โหมดนักพัฒนา) |
| `install.ps1 -Uninstall` | ถอนทางลัด + ไฟล์ที่ติดตั้ง (เก็็บ backup ไว้) |
| `install.ps1 -Uninstall -Purge` | ถอนทั้งหมดรวมข้อมูลใน `%LOCALAPPDATA%\AkiLxstboss` |

## ทำเป็นแอป (ทางลัดบน Desktop / Start Menu)

ถ้าไม่อยากเปิด PowerShell ทุกครั้ง ให้สร้างทางลัดเหมือนโปรแกรมทั่วไป:

```powershell
powershell -ExecutionPolicy Bypass -File .\install-app.ps1
```

ได้ 4 ทางลัด (ใช้ไอคอนเดียวกับ EXE):

| ทางลัด | เปิดอะไร |
| --- | --- |
| `Aki Lxst Boss Optimize` (Desktop) | `Aki-Lxstboss-optimize.exe` — เปิดแอปแล้วเด้งเบราว์เซอร์ |
| `Aki Lxst Boss Optimize (Admin)` (Desktop) | เดียวกัน แต่ขอสิทธิ์ Administrator (สำหรับ Optimize/Network) |
| ชื่อเดียวกัน 2 ตัว | อยู่ใน Start Menu (ค้นหาเจอทันที) |

ถอนออกทั้งหมด: `powershell -ExecutionPolicy Bypass -File .\install-app.ps1 -Uninstall`
ถ้าไม่มี EXE (ยังไม่ build) ทางลัดจะชี้ไปที่ `AkiBossMap.ps1` แทนโดยอัตโนมัติ

## แจกจ่ายให้คนอื่น

แอปเป็นโฟลเดอร์เดียว ไม่ต้องติดตั้งอะไร — แตก ZIP ให้เขาไปใช้ได้เลย

```powershell
powershell -ExecutionPolicy Bypass -File build-dist.ps1
```

สคริปต์นี้จะ:

1. คัดลอกเฉพาะไฟล์ที่ต้องแจก (`app/`, `AkiBossMap.ps1`, `server.ps1`, `run.bat`, `run-admin.bat`, `stop.bat`, `README.md`, `คู่มือใช้งาน.md`)
2. ตรวจว่า `server.ps1` ยังมี UTF-8 BOM (ภาษาไทยจะไม่เพี้ยน) และ `server.ps1` / `AkiBossMap.ps1` ไม่มี syntax error
3. ตรวจว่าเลขเวอร์ชันตรงกัน และรูปทุกใบที่ UI อ้างถึงมีอยู่จริง
4. อัดเป็น `dist/Aki-Lxst-Boss-Optimize-v2.6.0.zip`

> ถ้าข้อใดข้อหนึ่งไม่ผ่าน สคริปต์จะ **ไม่สร้าง ZIP** และบอกว่าติดตรงไหน — กันการแจกไฟล์ที่พัง

**สิ่งที่ทำให้ส่งต่อได้สบาย**

| ปัญหาเดิม | จัดการแล้ว |
| --- | --- |
| พอร์ต 5180 ถูกโปรแกรมอื่นใช้ | ขยับไปพอร์ต 5181–5199 อัตโนมัติ (หน้าเว็บยิง API แบบ relative จึงไม่กระทบ) |
| เปิดแอปซ้ำแล้วได้ 2 ตัว | จดจำพอร์ตไว้ใน `port.txt` → ครั้งที่สองเปิดหน้าต่างเดิมแทน ไม่สร้างซ้ำ |
| คนที่ไม่มีสิทธิ์ Admin | `run.bat` ทำงานได้ปกติ (กราฟิก/โปรไฟล์/ล้างแคช) + เตือนให้ใช้ `run-admin.bat` สำหรับส่วนที่ต้องใช้สิทธิ์ |
| หาโฟลเดอร์ GTA V ไม่เจอ | ตรวจหลายที่ (Program Files / Steam / Epic / ไดรฟ์ C–G) + ให้ตั้งเองได้ที่หน้า Settings |
| ไม่มี FiveM ติดตั้ง | หน้า Home แสดงคำแนะนำให้ไปตั้ง path แต่หน้าอื่นยังใช้ได้ครบ |
| เกิดข้อผิดพลาดจากโปรแกรมอื่น | โฟลเดอร์ข้อมูลของแอปแยกเป็น `%LOCALAPPDATA%\AkiLxstboss` ลบทิ้งได้เลย |

**สิ่งที่ไม่รวมในแพ็กเกจ (โดยเจตนา):** ข้อมูลส่วนตัวของผู้ใช้, ไฟล์สำรอง, ค่า registry ที่แก้ไว้ —
ทุกอย่างถูกเก็บใน `%LOCALAPPDATA%\AkiLxstboss` ของแต่ละเครื่อง ไม่ติดไปกับไฟล์ที่แจก

> หมายเหตุความปลอดภัย: เซิร์ฟเวอร์ฟังเฉพาะ `localhost` / `127.0.0.1` เท่านั้น และปิดกัน path traversal
> ข้อมูลไม่ถูกส่งออกนอกเครื่อง

### แจกเป็น EXE ไฟล์เดียว (โหลดจาก GitHub)

ถ้าไม่อยากให้คนรับไฟล์ต้องแตก ZIP หรือแก้ ExecutionPolicy ให้สร้าง EXE ที่ฝังแอปทั้งชุดไว้ข้างใน

```powershell
powershell -ExecutionPolicy Bypass -File build-exe.ps1
```

ได้ `dist\Aki-Lxstboss-optimize.exe` ไฟล์เดียว (~340 KB) ข้างในมี `app/`, `server.ps1`, `AkiBossMap.ps1` ครบ
ตอนรันมันจะแตกตัวเองไปที่ `%LOCALAPPDATA%\AkiLxstboss\runtime\<hash>` แล้วเปิดหน้าแอปให้เอง
(สร้างด้วย `csc.exe` ที่มากับ Windows — ไม่ต้องติดตั้ง SDK หรือ Node)

| คำสั่ง | ทำอะไร |
| --- | --- |
| `Aki-Lxstboss-optimize.exe` | เปิดแอปและเปิดเบราว์เซอร์ |
| `Aki-Lxstboss-optimize.exe -Admin` | ขอสิทธิ์ Administrator ผ่าน UAC |
| `Aki-Lxstboss-optimize.exe -Check` | ตรวจไฟล์ที่แตกออกมา |
| `Aki-Lxstboss-optimize.exe -Stop` | ปิดเซิร์ฟเวอร์ที่ค้าง |
| `Aki-Lxstboss-optimize.exe -Port 5190` | เปลี่ยนพอร์ต |

**อัปโหลดขึ้น GitHub (ทำทุกครั้งที่ออกรุ่นใหม่)**

1. เปิด https://github.com/onepeat333-alt/Aki-Lxstboss-Project
2. กด **Add file → Upload files**
3. ลาก `dist\Aki-Lxstboss-optimize.exe` ไปวางทับไฟล์เดิม → **Commit changes** (สาขา `main`)
4. รอสักครู่ แล้วผู้ใช้รันคำสั่งนี้ได้เลย

```powershell
Invoke-WebRequest -Uri "https://github.com/onepeat333-alt/Aki-Lxstboss-Project/raw/main/Aki-Lxstboss-optimize.exe" -OutFile "$env:TEMP\Aki-Lxstboss-optimize.exe"; Start-Process "$env:TEMP\Aki-Lxstboss-optimize.exe"
```

**ข้อควรรู้ก่อนแจก EXE**

- EXE ไม่ได้เซ็นชื่อ → Windows SmartScreen จะเตือน *"Windows protected your PC"* ครั้งแรก (More info → Run anyway) และ antivirus บางตัวอาจตั้งข้อสังเกตเพราะ EXE แตกไฟล์แล้วเรียก PowerShell ถ้าจะแจกวงกว้างควรมี code signing certificate
- ตรวจว่าไฟล์ที่โหลดมาไม่ถูกแก้: `Get-FileHash "$env:TEMP\Aki-Lxstboss-optimize.exe" -Algorithm SHA256` แล้วเทียบกับค่า SHA256 ที่ `build-exe.ps1` พิมพ์ตอนสร้าง
- GitHub raw มีแคช ถ้าคนอื่นยังได้รุ่นเก่า ให้รอ 1–2 นาทีแล้วโหลดใหม่ หรือใช้ **Releases** (`https://github.com/<user>/<repo>/releases/latest/download/Aki-Lxstboss-optimize.exe`) ซึ่งเหมาะกับการแจกหลายเวอร์ชันกว่า
- EXE ไม่ได้อัปเดตตัวเอง — อัปโหลดทับแล้วผู้ใช้ต้องโหลดไฟล์ใหม่ (ตัวเก่าไม่หาย แต่จะไม่ถูกลบ)

## ค่าที่ใช้

- **โปรไฟล์ Boss Boost** ใช้ฐานค่าจาก `MidasV2/assets/gta5_settings_preset.xml` แต่คง TextureQuality 2,
  AnisotropicFiltering 16 และ ShaderQuality 2 ไว้ เพราะสามค่านี้เกือบไม่กระทบ FPS แต่ภาพคมขึ้นชัดเจน
- **Bandwidth Cap (QoS)** อ้างอิงสคริปต์ `ค่าเน็ต.txt`: `New-NetQosPolicy` ต่อโปรเซส FiveM/GTA ทุกเวอร์ชัน + พอร์ต 30120
  โดย `ThrottleRateActionBitsPerSecond` คือการ **จำกัด bandwidth** ไม่ใช่เพิ่มสปีด/ping/FPS จึงไม่เปิดอัตโนมัติ
  ใช้เฉพาะเมื่อ upload เต็ม/เกิด bufferbloat และตั้งใกล้ 85–90% ของ upload จริง
- **Tweaks** ใช้ค่าเดียวกับ `MidasV2/main.js` (Nagle, network adapter power saving, delivery optimization,
  IPv6, MMCSS, Power Throttling, mouse acceleration, Filter/Sticky/Toggle Keys, keyboard repeat ฯลฯ)
  แต่วัดระดับความน่าเชื่อถือใหม่ — เฉพาะ Delivery Optimization กับ Game Mode/Capture OFF เท่านั้นที่อยู่ในปุ่ม **Quick Safe Setup**

## ผลตรวจไฟล์ที่แนบ (Audit)

ตรวจทุกไฟล์ก่อนเลือกเข้าแอป สรุปว่าใส่อะไร / ไม่ใส่อะไรเพราะอะไร

### ใส่เข้าแอป (ระดับ Advanced/Caution ทั้งหมด)
| ไฟล์ที่มา | ค่า | ทำไมถึงใส่ |
| --- | --- | --- |
| `X3d intel.bat` | HwSchMode = 2 (HAGS) | ของจริง มีเอกสาร Windows รองรับ ลด overhead ของการ์ดจอ ต้องรีบูต |
| `X3d intel.bat` / `t.bat` | Win32PrioritySeparation = 0x26 | ของจริง ให้ foreground ได้ quantum ยาวขึ้น ผลจำกัดแต่ปลอดภัย ปิดกลับได้ |
| `X3d intel.bat` | DisablePagingExecutive = 1 | ของจริง เก็บเคอร์เนลใน RAM — ใส่เป็น caution (แรม < 16GB ห้ามใช้) |
| `t.bat` (X3D) / `X3d intel.bat` | Ultimate Performance power plan (e9a42b02…) | ของจริง ลด CPU wake latency เหมาะกับเดสก์ท็อป เดิมเป็น Balanced ตอนปิด |
| `FixLag.reg` | Mouse/KeyboardDataQueueSize = 16 | ของจริง ลด input queue ช่วยตอน mouse polling สูงมาก ปิดกลับเป็น 100 ได้ |
| `X3d intel.bat` | ForegroundLockTimeout = 0, MenuShowDelay = 0 | ของจริง แต่เป็นเรื่องความรู้สึก/UI ไม่ใช่ FPS — ใส่เป็น caution |
| `FiveM_Apply_Gpedit.bat` | GameDVR policy AllowGameDVR = 0 | ของจริง ปิดการจับภาพ Xbox ระดับ policy ชัดกว่าค่า HKCU เดิม |
| `FiveM_Apply_Gpedit.bat` | QoS DSCP 46 (Three `AkiBoss_*` policies) | ของจริง เครื่องหมาย EF ให้ router ที่รองรับ — ไม่ใช่ตัวเพิ่มความเร็ว |
| `CitizenFX.txt` | SwapChainUseWaitableSwapChain / ForceRenderAheadLimit / DisableNagleAlgorithm / HighPriority / UseDirectInput | ค่า renderer/input ในตัว FiveM จริง เขียนลง `CitizenFX.ini` ได้ มีสำรองก่อนแก้ + กันแก้ตอนเกมรัน |
| `gta5_settings.xml` (ตัวอย่าง) | ยืนยันว่า key ตรงกับที่แอปใช้ | ไฟล์จริงของเครื่องยังเหมือนเดิม — แอปอ่านเขียนเฉพาะ key ที่รู้จักเท่านั้น |

### รอบ 2.3.x (ปรับเป็นธีมดำ–โครมใน 2.4.0) — ค่าที่เพิ่มเข้ามา

| ไฟล์ที่มา | ค่าใหม่ | หมายเหตุ |
| --- | --- | --- |
| `gta5_settings.xml` | `Shadow_Distance`, `Shadow_SplitZStart`, `Shadow_SplitZEnd`, `MaxLodScale`, `MSAAFragments`, `MSAAQuality`, `PauseOnFocusLoss`, `Audio3d` | คีย์ที่มีอยู่จริงในไฟล์ ทุกค่าเป็นตัวเลข/บูลีนตรงตามไฟล์ ปล่อย 0 ในช่อง % = ให้เกมคำนวณเอง |
| `CitizenFX.txt` | `[Renderer] EnablePresentationOptimizations`, `[Game] DisableNvThreadOptimization` | ค่า renderer ในตัว FiveM — เขียนลง `CitizenFX.ini` พร้อมสำรองก่อนแก้ และปิดเกมก่อนตั้งค่า |
| `FiveM_Apply_Gpedit.bat` | `netsh tcp fastopen` + `fastopenfallback`, `timestamps`, `ecncapability`, `initialRto 1500`, `maxsynretransmissions 2`, `pacingprofile off`, `netsh int udp uro` | ค่า TCP/UDP ของ Windows จริง ปิดกลับเป็น `default` ได้ทุกตัว (ปุ่มเดียวกัน) |
| `FiveM_Apply_Gpedit.bat` | `Psched NonBestEffortLimit = 0` | ปลดล็อก 20% ที่ Windows สงวนไว้ — ผลกับเกมแทบไม่มี แต่เป็นค่าที่คนขอมาและกู้คืนได้ |
| `FiveM_RESET.bat` | ใช้เป็น "ค่าปกติ" สำหรับปุ่มปิดกลับของ tweak TCP/UDP ด้านบน | ตรวจว่าทุกตัวมีทางกลับ ไม่มี tweak ใหม่ตัวใดที่ปิดกลับไม่ได้ |

> **การปิดกลับของ tweak กลุ่ม netsh (2.3.1):** ก่อนเปิด ระบบจะอ่านค่าเดิมของ Windows เก็บไว้ใน
> `%LOCALAPPDATA%\AkiLxstboss\tweak-originals.json` แล้วเขียนค่านั้นกลับตอนปิด — ไม่ใช้ `=default`
> เพราะ Windows ไม่ได้คืนค่าเดิมจริง (ทดสอบแล้ว: Initial RTO 2000 → ค้างที่ 3000, Timestamps, Fast Open Fallback)
> ถ้าอ่านค่าเดิมไม่ได้ (Windows ภาษาอื่นที่ netsh แปลป้ายกำกับ) tweak จะ **ปฏิเสธการเปิด** แทนที่จะค้างค่าไว้
>
> ผลข้างเคียงที่ควรรู้: ถ้า Windows เปิดค่านั้นอยู่แล้ว (เช่น Fast Open ถูก .bat ตัวอื่นเปิดไว้) ปุ่มจะแสดง **ON**
> ตามค่าจริง และกดปิดแล้วจะกลับไปเป็นค่าเดิมของเครื่อง (ยัง ON) — เป็นการคืนสภาพ ไม่ใช่การบังคับปิด

**ยังคงไม่ใส่จากไฟล์ชุดนี้:** `bcdedit` (disabledynamictick / useplatformclock / tscsyncpolicy), timer resolution 0.5ms,
`net stop` บริการระบบ, ปิด Defender, `netsh winsock reset`, ตั้ง Receive/Transmit Buffers ของการ์ดเน็ต
(เพราะคืนค่าเดิมไม่ได้), `MaxStreamingMemory`, `DisableLauncher`, `disable_fog` — เหตุผลเดิมคือเสี่ยงหรือไม่มีทางกู้คืนที่สะอาด

### ตั้งใจไม่ใส่ (และเหตุผล)
| ไฟล์ที่มา | ค่าที่ตัด | เหตุผล |
| --- | --- | --- |
| `X3d intel.bat`, `t.bat`, ALL-NET | `bcdedit /set disabledynamictick` ฯลฯ | แก้ boot config เสี่ยงสูง ผลบน Windows ใหม่ใกล้ศูนย์ ไม่คุ้ม |
| `FiveM_Apply_Gpedit.bat` | ปิด Windows Defender ทั้งหมด, ปิดอัปเดต Windows (DoSvc/BITS/wuauserv), `DisableAntiSpyware` | เปิดรูรั่วความปลอดภัย — ไม่ใส่เด็ดขาด |
| `FiveM_Net_Optimize.reg` | IRQ0/8/16Priority, DpcWatchdog*, SMB `AutoShareWks`, `Tcp1323Opts`, `MaxUserPort`, IPv6 disable ซ้ำสองครั้ง, `NoLazyMode`, `FeatureSettingsOverride` | ขยะเส้นทางยาว ไม่มีผลกับ FiveM หรือเป็นค่าที่ Microsoft ไม่รองรับ/เลิกใช้แล้ว |
| `t.bat` | `autotuninglevel=experimental`, `congestionprovider=ctcp`, `rsc=disabled`, DNS อัตโนมัติ 1.1.1.1/8.8.8.8, `EnableWsd` | ผลกลับด้านหรือเป็นเรื่องส่วนตัว บางค่าทำให้เน็ตแย่ลง |
| `ALL-NET/FiveM_Apply_Gpedit.bat` | Timer resolution 0.5ms, ปิด DiagTrack/SysMain/WSearch, ลบ Prefetch, ลบ AppxPackage | Windows 10 2004+ ทำให้ timer เป็น per-process อยู่แล้ว และการลบ Prefetch/แอปทำให้อาการแย่ลง |
| ทุกไฟล์ | ปิด IPv6, ปิด NLA tweak, `NonBestEffortLimit = 0`, `NetworkThrottlingIndex`, `SystemResponsiveness` | ยังคงไว้ในรายการ Advanced แบบมีคำอธิบายตรงไปตรงมา — ไม่ใช่ของมหัศจรรย์ แต่บางคนใช้จริง ผลจึงให้ทดสอบเอง (ไม่ติดไปกับ Quick Safe Setup) |
| `CitizenFX.txt` | `PoolSizesIncrease=…` | **เครื่องนี้ตั้งค่านี้ใน `CitizenFX.ini` จริงอยู่แล้ว** (ไฟล์จริงมี `PoolSizesIncrease` ขนาดใหญ่กว่านั้น) — แอปจะไม่เขียนทับ |
| `CitizenFX.txt` | `DefaultBuild`, `SavedBuildNumber`, `UpdateChannel=beta`, `ReplaceExecutable=1`, `MaxStreamingRequests`, `StreamerMode` | ไม่ใช่ตัวเลือกเพิ่ม fps/ลดกระตุก — เป็นการบังคับ build/channel ที่เสี่ยงทำให้เกม/addon พัง |
| `TimerResolution.exe` | เครื่องมือ 0.5ms แบบ third-party | ไม่ฝังไว้ในแอป ผลบน Win10 2004+ จำกัด และเป็น binary ที่ตรวจสอบที่มาไม่ได้ |

> หมายเหตุเรื่อง **gta5_settings.xml** ที่แนบมา: เป็นไฟล์ Max FPS ที่ key ตรงกับที่แอปรู้จักทั้งหมด (`TextureQuality`, `AnisotropicFiltering`, `ParticleQuality`, …)
> แอปไม่ได้เขียนทับไฟล์จริงด้วยไฟล์นี้ เพราะเครื่องคุณใช้ hash/refresh rate ของตัวเองอยู่ — ถ้าต้องการ flash เป็นโปรไฟล์ Max FPS ให้ทำผ่านหน้า Profiles เองหลังปิดเกม

## ความปลอดภัยของไฟล์เกม

- ไฟล์ที่แก้คือไฟล์จริงที่ FiveM อ่าน: `%APPDATA%\CitizenFX\gta5_settings.xml`
  (fallback: `%LOCALAPPDATA%\FiveM\FiveM.app\settings.xml`, `Documents\Rockstar Games\GTA V\settings.xml`)
- ทุกครั้งที่บันทึก ระบบจะสำรองไฟล์เดิมไว้ที่
  `%LOCALAPPDATA%\AkiLxstboss\backups\settings-YYYYMMDD-HHMMSS-fff.xml`
- กู้คืนได้จากหน้า **ตั้งค่า → ไฟล์สำรองค่า → กู้คืน** (ก่อนกู้คืนจะสำรองไฟล์ปัจจุบันให้อีกชั้น)
- ก่อนแก้ registry ทุกครั้ง ระบบจะ export ค่าเดิมเป็น `.reg` เก็บที่ `%LOCALAPPDATA%\AkiLxstboss\regbackups\`
  และกู้คืนได้จากหน้า **ตั้งค่า → สำรอง registry**
- ก่อนแก้ `CitizenFX.ini` ทุกครั้ง ระบบจะสำรองเป็น `.ini` เก็บที่ `%LOCALAPPDATA%\AkiLxstboss\citizenfx-backups\`
  (รวมถึงก่อนกู้คืนไฟล์เก่า ระบบจะสำรองปัจจุบันให้อีกชั้น) และกู้คืนได้จากหน้า **ตั้งค่า → สำรอง CitizenFX.ini**
- ถ้า FiveM กำลังรันอยู่ ระบบจะขอให้ยืนยันก่อนบันทึก จะไม่อนุญาตให้กู้คืนไฟล์ตั้งค่า
  และ tweak กลุ่ม **FiveM / GTA Engine** จะถูกปิดการทำงานจนกว่าจะปิดเกม
- เขียนไฟล์แบบ UTF-8 ไม่มี BOM และคง line ending เดิม

## พาธที่เกี่ยวข้อง

| อะไร | ที่อยู่ |
| --- | --- |
| gta5_settings.xml | `%APPDATA%\CitizenFX\gta5_settings.xml` |
| FiveM | `%LOCALAPPDATA%\FiveM\` |
| CitizenFX.ini | `%LOCALAPPDATA%\FiveM\FiveM.app\CitizenFX.ini` |
| ไฟล์สำรอง settings | `%LOCALAPPDATA%\AkiLxstboss\backups\` |
| ไฟล์สำรอง registry | `%LOCALAPPDATA%\AkiLxstboss\regbackups\` |
| ไฟล์สำรอง CitizenFX.ini | `%LOCALAPPDATA%\AkiLxstboss\citizenfx-backups\` |

## โครงสร้างโปรเจกต์

```
AkiBossMap/
├─ AkiBossMap.ps1     ตัวเรียกใช้หลักผ่าน PowerShell (start / -Admin / -Check / -Stop)
├─ run.bat            เปิดแอป (เรียก server.ps1)
├─ stop.bat           ปิดเซิร์ฟเวอร์ที่ค้างอยู่
├─ server.ps1         HTTP server + JSON API + tweak/QoS logic (ไม่ต้องใช้ dependency)
├─ build-exe.ps1      สร้าง dist\Aki-Lxstboss-optimize.exe (EXE ไฟล์เดียวที่ฝังแอปทั้งชุด)
├─ exe-launcher/      ซอร์ส C# ของตัวเรียกที่อยู่ใน EXE
└─ app/
   ├─ index.html
   ├─ css/app.css     ธีมทั้งหมด (แก้สีที่ :root)
   ├─ assets/         โลโก้ + อาร์ตเคลื่อนไหว (aki-logo.png, aki-orbit.svg)
   └─ js/
      ├─ main.js      layout + router
      ├─ data.js      นิยามค่าที่ปรับได้ + โปรไฟล์ + รายการ tweak
      ├─ store.js     state, activity log, รายการโปรด
      ├─ api.js       ตัวเรียก API (มีโหมดตัวอย่างเมื่อต่อ backend ไม่ได้)
      ├─ actions.js   ตัวช่วยเรียก action + toast
      ├─ ui.js        toast / modal / format
      ├─ icons.js     ชุดไอคอน SVG
      └─ pages/       dashboard, graphics, profiles, tweaks, performance, network, settings
```

## ปรับแต่งเพิ่มเติม

- **เปลี่ยนพอร์ต**: ใช้ `-Port 5190` กับ `AkiBossMap.ps1` (หรือแก้ค่า `param([int]$Port = 5180)` ใน `server.ps1`)
- **เพิ่ม/แก้ภาพเคลื่อนไหว**: แก้ `app/assets/aki-orbit.svg` แล้วปรับขนาด/ความทึบที่คลาส `.hero-orbit` และ `.bg-fx-orbit` ใน `app/css/app.css`
- **เปลี่ยนสี/รัศมี/ฟอนต์**: แก้ตัวแปรใน `:root` ของ `app/css/app.css` (`--p`, `--mag`, `--bg`, `--hairline`)
- **เพิ่มค่าที่ปรับได้**: เพิ่ม object ใน `GROUPS` ของ `app/js/data.js` โดยใช้ key เดียวกับใน `gta5_settings.xml`
- **เพิ่ม tweak**: เพิ่ม hashtable ใน `$TWEAKS` ของ `server.ps1` (id/cat/tier/admin/reboot/regKey/enable/disable/state)
- **เพิ่มแอ็กชันใหม่**: เพิ่ม case ใน `Invoke-Action` ของ `server.ps1` แล้วเรียกผ่าน `runAction('ชื่อ action')`

## หมายเหตุ

- แอปนี้แก้ไฟล์บนเครื่องคุณจริง (gta5_settings.xml, cache, registry, DNS, QoS) — อ่านคำอธิบายก่อนกดทุกครั้ง
- การเปลี่ยน QoS, DNS, registry และบาง tweak ต้องใช้สิทธิ์ Administrator
- สถานะ tweak บางตัว (เช่น power management ของการ์ดเน็ต) อ่านไม่ได้ถ้าไม่ใช่ admin — UI จะแสดงเป็น “ไม่ทราบสถานะ”
- โหมดตัวอย่างจะขึ้นอัตโนมัติเมื่อเปิดหน้าเว็บโดยไม่มี `server.ps1` (ดูข้อมูลตัวอย่างได้ แต่บันทึกไม่ลงไฟล์)
