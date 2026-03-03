<div align="center">

# ⚔️ DIGI KILLER IRONCLAD

### A végső fegyver a nem kívánt folyamatok ellen

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge&logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?style=for-the-badge&logo=windows&logoColor=white)
![Version](https://img.shields.io/badge/Verzió-5.0-FF0000?style=for-the-badge)
![License](https://img.shields.io/badge/Licenc-MIT-22C55E?style=for-the-badge)
![Admin](https://img.shields.io/badge/Admin-Szükséges-orange?style=for-the-badge&logo=shield&logoColor=white)

<br/>

> 💀 **Kill. Suspend. Resume. Monitor.** — Minden egy helyen.

</div>

---

## 🎯 Mi ez?

A **DIGI KILLER IRONCLAD** egy PowerShell-alapú folyamatkezelő eszköz, amit arra terveztek, hogy egyszer és mindenkorra leszámolj a nem kívánt, makacs programokkal — mint például a DIGI médialejátszó és hasonló alkalmazások, amelyek nem hajlandók normálisan leállni.

**Nincs több:**
- 😤 kézzel Task Managerbe mászkálni
- 🔁 újra meg újra leölni ugyanazt a programot
- 🐌 befagyott, reagálatlan folyamatokkal küzdeni

---

## ✨ Funkciók

### 💀 TERMINATOR
Azonnali és automatikus folyamatleállítás — a legegyszerűbb módja a célprogram eltüntetésének.

| Funkció | Leírás |
|:---|:---|
| 📂 `BROWSE` | Célprogram `.exe` kiválasztása |
| 💥 `NUKE ALL INSTANCES` | Azonnali kill — minden futó példány egyszerre |
| 🛡️ `GUARDIAN PROTOCOL` | Auto-Kill: másodpercenként figyel és azonnal öl |
| 🔊 `BEEP` | Hangjelzés kill eseményekre |
| 🗑️ `CLEAR TARGET` | Target törlése, monitor reset |

### ⏸️ SUSPEND / RESUME
Nem mindig kell teljesen leölni. Fagyaszd be és folytasd később.

| Funkció | Leírás |
|:---|:---|
| ⏸️ `SUSPEND` | Befagyasztja a folyamatot — CPU = 0%, memória megmarad |
| ▶️ `RESUME` | Folytatja pontosan onnan ahol abbahagyta |
| ☠️ `KILL SUSPENDED` | Leállítja a felfüggesztett folyamatot |

> 🔧 **Technikai részlet:** Win32 `SuspendThread` / `ResumeThread` API — ugyanaz az alap, amit a Sysinternals Process Explorer is alkalmaz.

### 📋 PROCESS LIST
Böngéssz az összes futó folyamat között egyetlen kattintással.

- 🔍 Teljes folyamatlista: név, PID, CPU, memória, elérési út
- 🖱️ **Dupla klikk** egy sorra = azonnal beállítja targetként
- 🔄 Refresh gomb az azonnali frissítéshez

### 📜 KILL LOG
Minden esemény naplózva, színkódolással.

| Kategória | Szín | Leírás |
|:---|:---|:---|
| `[SYS]` | 🔵 Cián | Rendszeresemények |
| `[INFO]` | 🟢 Zöld | Általános infó |
| `[KILL]` | 🔴 Piros | Kill események |
| `[SUSPEND]` | 🟡 Sárga | Suspend műveletek |
| `[RESUME]` | 🟢 Zöld | Resume műveletek |
| `[WARN]` | 🟠 Narancs | Figyelmeztetések |

---

## 🚀 Telepítés & Indítás

### 1️⃣ Letöltés

```bash
git clone https://github.com/digifandev/digikiller.git
cd digikiller
```

Vagy töltsd le közvetlenül a `.ps1` fájlt a [Releases](https://github.com/digifandev/digikiller/releases) oldalról.

### 2️⃣ Futtatás

```powershell
powershell -ExecutionPolicy Bypass -File "DIGI_KILLER_v5.ps1"
```

> ⚡ A script automatikusan újraindítja magát rendszergazdai joggal, ha szükséges.

### ✅ Követelmények

- 🪟 Windows 10 / 11
- 💙 PowerShell 5.1+
- 🔐 Rendszergazdai jog *(automatikusan kéri)*

---

## ⚡ Gyors Start

```
1. 🟢  Indítsd el a scriptet
2. 📂  Kattints a BROWSE gombra
3. 🎯  Válaszd ki a célprogram .exe-jét
4. 💥  Nyomj NUKE — kész!
```

**Auto-kill bekapcsoláshoz:** pipáld be a `🛡️ GUARDIAN PROTOCOL` checkboxot — ezután a program automatikusan megöli a targetet minden alkalommal, amikor elindul.

---

## 📦 Verziótörténet

| Verzió | Változások |
|:---|:---|
| `v5.0` 🆕 | ⏸️ Suspend/Resume (Win32 API), 📋 Folyamatlista tab, dupla klikk target, színes napló |
| `v4.0` | 🔧 Stabil ASCII build, encoding hibajavítás |
| `v3.0` | 🏗️ Újraírt stabil alap, GroupBox elrendezés, uptime számláló |
| `v2.0` | 🎨 Egyéni tab renderer, Kill Counter, Log export, BEEP |
| `v1.0` | 💀 Alap kill + Guardian funkció |

---

## ⚠️ Figyelmeztetés

> Ez az eszköz **saját folyamatok kezelésére** készült.  
> Használd felelősségteljesen — csak olyan programokat állíts le, amelyekre jogod van.

---

## 👤 Fejlesztő

<div align="center">

### **DigiFan** 🔥

[![GitHub](https://img.shields.io/badge/GitHub-digifandev-181717?style=for-the-badge&logo=github)](https://github.com/digifandev)

*"Ha a DIGI nem áll le magától — segítünk neki."*

</div>

---

## 📄 Licenc

Nyílt forráskódú, [MIT licenc](LICENSE) alatt — szabad felhasználásra és módosításra.

<div align="center">

---

⭐ **Ha hasznos volt, dobj egy stárt a repóra!** ⭐

💀 *DIGI KILLER IRONCLAD — mert néha csak meg kell ölni.* 💀

</div>
