# PowerShell Playground 🚀

![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?logo=powershell&logoColor=white)
![GitHub last commit](https://img.shields.io/github/last-commit/stanleyzwj/powershell-playground)

My personal journey learning PowerShell, Git, and GitHub —
building toward becoming a confident Windows IT engineer.

## 📁 Structure

| Folder | Contents |
|--------|----------|
| `scripts/` | Reusable PowerShell scripts |
| `tests/` | Practice scripts and bug-fixing exercises |
| `notes/` | Daily learning notes |
| `projects/` | Mini automation projects |

## 🛠️ Scripts

### `scripts/hello.ps1`
Prints a greeting with computer name, username, and current time, then lists the top 3 processes by memory usage.

```powershell
.\scripts\hello.ps1
```

---

### `scripts/Get-DiskReport.ps1`
Reports used/free space in GB for every mounted disk drive. Color-coded by fullness: green (<70%), yellow (70–90%), red (>90%).

```powershell
.\scripts\Get-DiskReport.ps1
```

Example output:
```
Drive C:  199.5 GB free of 254.7 GB (22% used) - Healthy
Drive D:  12.3 GB free of 500.0 GB (98% used) - WARNING - Almost Full!
```

---

### `scripts/Get-ServiceHealth.ps1`
Checks whether key Windows services are running or stopped. Defaults to Spooler, WinRM, W32Time, and Dnscache. Accepts a custom list via `-ServiceNames`.

```powershell
# Run with defaults
.\scripts\Get-ServiceHealth.ps1

# Check specific services
Get-ServiceHealth -ServiceNames "Spooler", "wuauserv", "BITS"
```

Example output:
```
[OK]  Print Spooler: Running
[!!]  Windows Remote Management (WS-Management): STOPPED
[OK]  Windows Time: Running
[OK]  DNS Client: Running
```

## 📅 Learning Log

| Day | Date | Topics Covered |
|-----|------|----------------|
| 1 | 2026-05-02 | PowerShell basics, pipeline, Git workflow, first GitHub push |
| 2 | 2026-05-03 | Functions, colored output, stream redirection (`2>&1`), `$LASTEXITCODE`, bug fixing (typos, wrong operators), conventional commits |

## 📚 Resources
- [Microsoft Learn — PowerShell](https://learn.microsoft.com/en-us/powershell/)
- [John Savill's PowerShell Master Class](https://www.youtube.com/playlist?list=PLlVtbbG169nFq_hR7FcMYg32xsSAObuq8)
- [PDQ PowerShell Wednesdays](https://www.youtube.com/@PDQ)

---
*Maintained by [@stanleyzwj](https://github.com/stanleyzwj) · Stanley Zhu*