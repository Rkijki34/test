# Force Windows 10 Pro Installation on OEM Laptops (HP, Dell, Lenovo, etc.)

Some laptops come with an **OEM license key for Windows 10 Home** embedded in their BIOS/UEFI.  
When you try to reinstall Windows, the setup will automatically pick *Home* and won’t let you choose other editions such as *Pro*.

This guide shows you how to bypass that auto-selection and install **Windows 10 Pro** instead, without needing a valid Pro license upfront.  
⚠️ Note: You’ll still need a genuine Pro key later if you want to activate Windows.

---

## 📦 Requirements
- A Windows 10 ISO (you can get a legit one from Microsoft directly).
- A USB installer (created with [Rufus](https://rufus.ie/) or Microsoft’s Media Creation Tool).
- Basic file editing skills (Notepad will do).

---

## 🛠️ Method 1 — Add `ei.cfg`
1. On your bootable USB, go to the `sources` folder.
2. Create a text file named **`ei.cfg`**.
3. Paste the following:

   ```ini
   [EditionID]
   Professional
   [Channel]
   Retail
   [VL]
   0
   ```

```bash
   # Save as 'Optimize-Windows.ps1' and run:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\Optimize-Windows.ps1
```
