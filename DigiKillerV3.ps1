# ============================================================
#  DIGI KILLER IRONCLAD v5.0
#  + SUSPEND / RESUME / STOP process control
#  + Tobb ful: TERMINATOR / SUSPEND / KILL LOG / HELP
# ============================================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

# Suspend/Resume-hoz szukseges Win32 API
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class ProcessControl {
    [DllImport("kernel32.dll")]
    public static extern IntPtr OpenThread(int dwDesiredAccess, bool bInheritHandle, uint dwThreadId);
    [DllImport("kernel32.dll")]
    public static extern uint SuspendThread(IntPtr hThread);
    [DllImport("kernel32.dll")]
    public static extern int ResumeThread(IntPtr hThread);
    [DllImport("kernel32.dll")]
    public static extern bool CloseHandle(IntPtr hObject);
    public const int THREAD_SUSPEND_RESUME = 0x0002;
}
"@

$Global:TargetPath    = ""
$Global:TargetName    = ""
$Global:KillCount     = 0
$Global:Uptime        = 0
$Global:IsSuspended   = $false

# ============================================================
# FOABLAK
# ============================================================
$form = New-Object System.Windows.Forms.Form
$form.Text            = "DIGI KILLER IRONCLAD v5.0"
$form.Size            = New-Object System.Drawing.Size(720, 660)
$form.BackColor       = [System.Drawing.Color]::FromArgb(10,10,10)
$form.ForeColor       = [System.Drawing.Color]::White
$form.StartPosition   = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox     = $false

# ============================================================
# FEJLEC PANEL
# ============================================================
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size      = New-Object System.Drawing.Size(720, 72)
$headerPanel.Location  = New-Object System.Drawing.Point(0, 0)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(15, 0, 0)
$form.Controls.Add($headerPanel)

$lblMain = New-Object System.Windows.Forms.Label
$lblMain.Text      = "DIGI KILLER  IRONCLAD"
$lblMain.Font      = New-Object System.Drawing.Font("Consolas", 22, [System.Drawing.FontStyle]::Bold)
$lblMain.ForeColor = [System.Drawing.Color]::FromArgb(220, 30, 30)
$lblMain.Location  = New-Object System.Drawing.Point(18, 8)
$lblMain.AutoSize  = $true
$headerPanel.Controls.Add($lblMain)

$lblSub = New-Object System.Windows.Forms.Label
$lblSub.Text      = "PROCESS TERMINATION SYSTEM  //  v5.0  //  ADMIN MODE"
$lblSub.Font      = New-Object System.Drawing.Font("Consolas", 8)
$lblSub.ForeColor = [System.Drawing.Color]::FromArgb(90, 90, 90)
$lblSub.Location  = New-Object System.Drawing.Point(20, 50)
$lblSub.AutoSize  = $true
$headerPanel.Controls.Add($lblSub)

$lblKillCounter = New-Object System.Windows.Forms.Label
$lblKillCounter.Text      = "KILLS: 0"
$lblKillCounter.Font      = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$lblKillCounter.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 0)
$lblKillCounter.Location  = New-Object System.Drawing.Point(560, 22)
$lblKillCounter.AutoSize  = $true
$headerPanel.Controls.Add($lblKillCounter)

# ============================================================
# TAB CONTROL
# ============================================================
$tabs = New-Object System.Windows.Forms.TabControl
$tabs.Size      = New-Object System.Drawing.Size(692, 530)
$tabs.Location  = New-Object System.Drawing.Point(14, 82)
$tabs.BackColor = [System.Drawing.Color]::FromArgb(10,10,10)

$tabKill    = New-Object System.Windows.Forms.TabPage; $tabKill.Text    = "  TERMINATOR  "; $tabKill.BackColor    = [System.Drawing.Color]::FromArgb(12,12,12)
$tabSuspend = New-Object System.Windows.Forms.TabPage; $tabSuspend.Text = "  SUSPEND/RESUME  "; $tabSuspend.BackColor = [System.Drawing.Color]::FromArgb(12,12,12)
$tabProcs   = New-Object System.Windows.Forms.TabPage; $tabProcs.Text   = "  PROCESS LIST  "; $tabProcs.BackColor   = [System.Drawing.Color]::FromArgb(12,12,12)
$tabLog     = New-Object System.Windows.Forms.TabPage; $tabLog.Text     = "  KILL LOG  ";     $tabLog.BackColor     = [System.Drawing.Color]::FromArgb(12,12,12)
$tabHelp    = New-Object System.Windows.Forms.TabPage; $tabHelp.Text    = "  HELP  ";         $tabHelp.BackColor    = [System.Drawing.Color]::FromArgb(12,12,12)

$tabs.Controls.AddRange(@($tabKill, $tabSuspend, $tabProcs, $tabLog, $tabHelp))
$form.Controls.Add($tabs)

# ============================================================
# === TERMINATOR TAB ===
# ============================================================

$grpTarget = New-Object System.Windows.Forms.GroupBox
$grpTarget.Text = " TARGET "; $grpTarget.Size = New-Object System.Drawing.Size(660, 80)
$grpTarget.Location = New-Object System.Drawing.Point(8, 8)
$grpTarget.ForeColor = [System.Drawing.Color]::FromArgb(180,0,0)
$grpTarget.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
$tabKill.Controls.Add($grpTarget)

$txtTarget = New-Object System.Windows.Forms.TextBox
$txtTarget.Location = New-Object System.Drawing.Point(10, 28); $txtTarget.Size = New-Object System.Drawing.Size(505, 28)
$txtTarget.BackColor = [System.Drawing.Color]::FromArgb(5,5,5); $txtTarget.ForeColor = [System.Drawing.Color]::FromArgb(0,210,0)
$txtTarget.Font = New-Object System.Drawing.Font("Consolas", 9); $txtTarget.BorderStyle = "FixedSingle"
$txtTarget.ReadOnly = $true; $txtTarget.Text = ">>> Nincs target kivalasztva <<<"
$grpTarget.Controls.Add($txtTarget)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "BROWSE"; $btnBrowse.Location = New-Object System.Drawing.Point(525, 25)
$btnBrowse.Size = New-Object System.Drawing.Size(118, 32); $btnBrowse.FlatStyle = "Flat"
$btnBrowse.BackColor = [System.Drawing.Color]::FromArgb(40,0,0); $btnBrowse.ForeColor = [System.Drawing.Color]::FromArgb(255,80,80)
$btnBrowse.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
$btnBrowse.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(150,0,0)
$grpTarget.Controls.Add($btnBrowse)

# STATUS GROUP
$grpStatus = New-Object System.Windows.Forms.GroupBox
$grpStatus.Text = " LIVE STATUS "; $grpStatus.Size = New-Object System.Drawing.Size(660, 120)
$grpStatus.Location = New-Object System.Drawing.Point(8, 98)
$grpStatus.ForeColor = [System.Drawing.Color]::FromArgb(180,0,0)
$grpStatus.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
$tabKill.Controls.Add($grpStatus)

$lblStateKey = New-Object System.Windows.Forms.Label; $lblStateKey.Text = "PROCESS STATE:"
$lblStateKey.Location = New-Object System.Drawing.Point(15,28); $lblStateKey.Size = New-Object System.Drawing.Size(145,20)
$lblStateKey.ForeColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblStateKey.Font = New-Object System.Drawing.Font("Consolas",9)
$grpStatus.Controls.Add($lblStateKey)

$lblStatusVal = New-Object System.Windows.Forms.Label; $lblStatusVal.Text = "STANDBY"
$lblStatusVal.Location = New-Object System.Drawing.Point(165,28); $lblStatusVal.Size = New-Object System.Drawing.Size(470,20)
$lblStatusVal.ForeColor = [System.Drawing.Color]::Cyan; $lblStatusVal.Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Bold)
$grpStatus.Controls.Add($lblStatusVal)

$lblInstKey = New-Object System.Windows.Forms.Label; $lblInstKey.Text = "INSTANCES:"
$lblInstKey.Location = New-Object System.Drawing.Point(15,52); $lblInstKey.Size = New-Object System.Drawing.Size(145,20)
$lblInstKey.ForeColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblInstKey.Font = New-Object System.Drawing.Font("Consolas",9)
$grpStatus.Controls.Add($lblInstKey)

$lblInstVal = New-Object System.Windows.Forms.Label; $lblInstVal.Text = "---"
$lblInstVal.Location = New-Object System.Drawing.Point(165,52); $lblInstVal.Size = New-Object System.Drawing.Size(470,20)
$lblInstVal.ForeColor = [System.Drawing.Color]::White; $lblInstVal.Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Bold)
$grpStatus.Controls.Add($lblInstVal)

$lblUptimeKey = New-Object System.Windows.Forms.Label; $lblUptimeKey.Text = "MONITOR UPTIME:"
$lblUptimeKey.Location = New-Object System.Drawing.Point(15,76); $lblUptimeKey.Size = New-Object System.Drawing.Size(145,20)
$lblUptimeKey.ForeColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblUptimeKey.Font = New-Object System.Drawing.Font("Consolas",9)
$grpStatus.Controls.Add($lblUptimeKey)

$lblUptimeVal = New-Object System.Windows.Forms.Label; $lblUptimeVal.Text = "00:00:00"
$lblUptimeVal.Location = New-Object System.Drawing.Point(165,76); $lblUptimeVal.Size = New-Object System.Drawing.Size(470,20)
$lblUptimeVal.ForeColor = [System.Drawing.Color]::FromArgb(180,180,0); $lblUptimeVal.Font = New-Object System.Drawing.Font("Consolas",9)
$grpStatus.Controls.Add($lblUptimeVal)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(15,98); $progressBar.Size = New-Object System.Drawing.Size(630,10)
$progressBar.Style = "Marquee"; $progressBar.MarqueeAnimationSpeed = 35; $progressBar.Visible = $false
$grpStatus.Controls.Add($progressBar)

# OPTIONS GROUP
$grpOptions = New-Object System.Windows.Forms.GroupBox
$grpOptions.Text = " OPTIONS "; $grpOptions.Size = New-Object System.Drawing.Size(660, 65)
$grpOptions.Location = New-Object System.Drawing.Point(8, 228)
$grpOptions.ForeColor = [System.Drawing.Color]::FromArgb(180,0,0)
$grpOptions.Font = New-Object System.Drawing.Font("Consolas", 9, [System.Drawing.FontStyle]::Bold)
$tabKill.Controls.Add($grpOptions)

$chkAuto = New-Object System.Windows.Forms.CheckBox
$chkAuto.Text = "GUARDIAN PROTOCOL  [ Auto-Kill minden indulasnal ]"
$chkAuto.Location = New-Object System.Drawing.Point(15,25); $chkAuto.Size = New-Object System.Drawing.Size(500,28)
$chkAuto.ForeColor = [System.Drawing.Color]::Orange; $chkAuto.Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Bold)
$grpOptions.Controls.Add($chkAuto)

$chkSound = New-Object System.Windows.Forms.CheckBox
$chkSound.Text = "BEEP"; $chkSound.Location = New-Object System.Drawing.Point(560,25); $chkSound.Size = New-Object System.Drawing.Size(80,28)
$chkSound.ForeColor = [System.Drawing.Color]::FromArgb(80,180,80); $chkSound.Font = New-Object System.Drawing.Font("Consolas",9)
$grpOptions.Controls.Add($chkSound)

# ACTION BUTTONS
$btnKill = New-Object System.Windows.Forms.Button
$btnKill.Text = ">>> NUKE ALL INSTANCES <<<"; $btnKill.Location = New-Object System.Drawing.Point(8,302)
$btnKill.Size = New-Object System.Drawing.Size(660,50); $btnKill.BackColor = [System.Drawing.Color]::FromArgb(120,0,0)
$btnKill.ForeColor = [System.Drawing.Color]::White; $btnKill.FlatStyle = "Flat"
$btnKill.Font = New-Object System.Drawing.Font("Consolas",13,[System.Drawing.FontStyle]::Bold)
$btnKill.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(220,0,0)
$btnKill.FlatAppearance.BorderSize = 2
$tabKill.Controls.Add($btnKill)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "CLEAR TARGET"; $btnClear.Location = New-Object System.Drawing.Point(8,362)
$btnClear.Size = New-Object System.Drawing.Size(200,35); $btnClear.BackColor = [System.Drawing.Color]::FromArgb(22,22,22)
$btnClear.ForeColor = [System.Drawing.Color]::FromArgb(110,110,110); $btnClear.FlatStyle = "Flat"
$btnClear.Font = New-Object System.Drawing.Font("Consolas",9)
$btnClear.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(55,55,55)
$tabKill.Controls.Add($btnClear)

# ============================================================
# === SUSPEND / RESUME TAB ===
# ============================================================

$grpSuspTarget = New-Object System.Windows.Forms.GroupBox
$grpSuspTarget.Text = " TARGET "; $grpSuspTarget.Size = New-Object System.Drawing.Size(660,80)
$grpSuspTarget.Location = New-Object System.Drawing.Point(8,8)
$grpSuspTarget.ForeColor = [System.Drawing.Color]::FromArgb(180,100,0)
$grpSuspTarget.Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Bold)
$tabSuspend.Controls.Add($grpSuspTarget)

$lblSuspTarget = New-Object System.Windows.Forms.Label
$lblSuspTarget.Text = "Ugyanazt a targetet hasznalja mint a TERMINATOR tab."
$lblSuspTarget.Location = New-Object System.Drawing.Point(12,22); $lblSuspTarget.Size = New-Object System.Drawing.Size(630,20)
$lblSuspTarget.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150); $lblSuspTarget.Font = New-Object System.Drawing.Font("Consolas",9)
$grpSuspTarget.Controls.Add($lblSuspTarget)

$lblSuspName = New-Object System.Windows.Forms.Label
$lblSuspName.Text = "Target: ---"; $lblSuspName.Location = New-Object System.Drawing.Point(12,44)
$lblSuspName.Size = New-Object System.Drawing.Size(630,20); $lblSuspName.ForeColor = [System.Drawing.Color]::FromArgb(0,200,0)
$lblSuspName.Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Bold)
$grpSuspTarget.Controls.Add($lblSuspName)

# STATE kijelzo
$grpSuspState = New-Object System.Windows.Forms.GroupBox
$grpSuspState.Text = " PROCESS STATE "; $grpSuspState.Size = New-Object System.Drawing.Size(660,80)
$grpSuspState.Location = New-Object System.Drawing.Point(8,98)
$grpSuspState.ForeColor = [System.Drawing.Color]::FromArgb(180,100,0)
$grpSuspState.Font = New-Object System.Drawing.Font("Consolas",9,[System.Drawing.FontStyle]::Bold)
$tabSuspend.Controls.Add($grpSuspState)

$lblSuspStateKey = New-Object System.Windows.Forms.Label; $lblSuspStateKey.Text = "ALLAPOT:"
$lblSuspStateKey.Location = New-Object System.Drawing.Point(15,28); $lblSuspStateKey.Size = New-Object System.Drawing.Size(120,20)
$lblSuspStateKey.ForeColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblSuspStateKey.Font = New-Object System.Drawing.Font("Consolas",9)
$grpSuspState.Controls.Add($lblSuspStateKey)

$lblSuspStateVal = New-Object System.Windows.Forms.Label; $lblSuspStateVal.Text = "---"
$lblSuspStateVal.Location = New-Object System.Drawing.Point(145,28); $lblSuspStateVal.Size = New-Object System.Drawing.Size(490,20)
$lblSuspStateVal.ForeColor = [System.Drawing.Color]::Cyan; $lblSuspStateVal.Font = New-Object System.Drawing.Font("Consolas",11,[System.Drawing.FontStyle]::Bold)
$grpSuspState.Controls.Add($lblSuspStateVal)

$lblSuspPidKey = New-Object System.Windows.Forms.Label; $lblSuspPidKey.Text = "PID(ek):"
$lblSuspPidKey.Location = New-Object System.Drawing.Point(15,52); $lblSuspPidKey.Size = New-Object System.Drawing.Size(120,20)
$lblSuspPidKey.ForeColor = [System.Drawing.Color]::FromArgb(90,90,90); $lblSuspPidKey.Font = New-Object System.Drawing.Font("Consolas",9)
$grpSuspState.Controls.Add($lblSuspPidKey)

$lblSuspPidVal = New-Object System.Windows.Forms.Label; $lblSuspPidVal.Text = "---"
$lblSuspPidVal.Location = New-Object System.Drawing.Point(145,52); $lblSuspPidVal.Size = New-Object System.Drawing.Size(490,20)
$lblSuspPidVal.ForeColor = [System.Drawing.Color]::White; $lblSuspPidVal.Font = New-Object System.Drawing.Font("Consolas",9)
$grpSuspState.Controls.Add($lblSuspPidVal)

# GOMBOK
$btnSuspend = New-Object System.Windows.Forms.Button
$btnSuspend.Text = "|| SUSPEND  (FELFUGGESZTES)"; $btnSuspend.Location = New-Object System.Drawing.Point(8,198)
$btnSuspend.Size = New-Object System.Drawing.Size(660,55); $btnSuspend.FlatStyle = "Flat"
$btnSuspend.BackColor = [System.Drawing.Color]::FromArgb(80,60,0); $btnSuspend.ForeColor = [System.Drawing.Color]::Orange
$btnSuspend.Font = New-Object System.Drawing.Font("Consolas",13,[System.Drawing.FontStyle]::Bold)
$btnSuspend.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(200,150,0)
$btnSuspend.FlatAppearance.BorderSize = 2
$tabSuspend.Controls.Add($btnSuspend)

$btnResume = New-Object System.Windows.Forms.Button
$btnResume.Text = "> RESUME  (FOLYTATAS)"; $btnResume.Location = New-Object System.Drawing.Point(8,263)
$btnResume.Size = New-Object System.Drawing.Size(660,55); $btnResume.FlatStyle = "Flat"
$btnResume.BackColor = [System.Drawing.Color]::FromArgb(0,60,0); $btnResume.ForeColor = [System.Drawing.Color]::FromArgb(0,220,0)
$btnResume.Font = New-Object System.Drawing.Font("Consolas",13,[System.Drawing.FontStyle]::Bold)
$btnResume.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0,180,0)
$btnResume.FlatAppearance.BorderSize = 2
$tabSuspend.Controls.Add($btnResume)

$btnKillFromSusp = New-Object System.Windows.Forms.Button
$btnKillFromSusp.Text = "X  KILL SUSPENDED PROCESS"; $btnKillFromSusp.Location = New-Object System.Drawing.Point(8,328)
$btnKillFromSusp.Size = New-Object System.Drawing.Size(660,45); $btnKillFromSusp.FlatStyle = "Flat"
$btnKillFromSusp.BackColor = [System.Drawing.Color]::FromArgb(80,0,0); $btnKillFromSusp.ForeColor = [System.Drawing.Color]::FromArgb(255,80,80)
$btnKillFromSusp.Font = New-Object System.Drawing.Font("Consolas",11,[System.Drawing.FontStyle]::Bold)
$btnKillFromSusp.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(160,0,0)
$tabSuspend.Controls.Add($btnKillFromSusp)

$lblSuspInfo = New-Object System.Windows.Forms.Label
$lblSuspInfo.Text = "SUSPEND: befagyasztja a folyamatot (CPU = 0%), de a memoria megmarad.`nRESUME: folytatja onnan ahol abbahagyta."
$lblSuspInfo.Location = New-Object System.Drawing.Point(10,390); $lblSuspInfo.Size = New-Object System.Drawing.Size(655,45)
$lblSuspInfo.ForeColor = [System.Drawing.Color]::FromArgb(100,100,100); $lblSuspInfo.Font = New-Object System.Drawing.Font("Consolas",9)
$tabSuspend.Controls.Add($lblSuspInfo)

# ============================================================
# === PROCESS LIST TAB ===
# ============================================================

$lblProcTitle = New-Object System.Windows.Forms.Label
$lblProcTitle.Text = "FUTO FOLYAMATOK  (dupla klikk = target beallitas)"
$lblProcTitle.Location = New-Object System.Drawing.Point(10,10); $lblProcTitle.AutoSize = $true
$lblProcTitle.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150); $lblProcTitle.Font = New-Object System.Drawing.Font("Consolas",9)
$tabProcs.Controls.Add($lblProcTitle)

$listProcs = New-Object System.Windows.Forms.ListView
$listProcs.Location = New-Object System.Drawing.Point(8,35); $listProcs.Size = New-Object System.Drawing.Size(660,370)
$listProcs.View = "Details"; $listProcs.FullRowSelect = $true; $listProcs.GridLines = $true
$listProcs.BackColor = [System.Drawing.Color]::FromArgb(5,5,5); $listProcs.ForeColor = [System.Drawing.Color]::FromArgb(0,200,0)
$listProcs.Font = New-Object System.Drawing.Font("Consolas",9); $listProcs.BorderStyle = "None"
$listProcs.Columns.Add("Nev",         200) | Out-Null
$listProcs.Columns.Add("PID",          70) | Out-Null
$listProcs.Columns.Add("CPU(s)",        80) | Out-Null
$listProcs.Columns.Add("Mem (MB)",      90) | Out-Null
$listProcs.Columns.Add("Eleresi ut",   210) | Out-Null
$tabProcs.Controls.Add($listProcs)

$btnRefreshProcs = New-Object System.Windows.Forms.Button
$btnRefreshProcs.Text = "REFRESH"; $btnRefreshProcs.Location = New-Object System.Drawing.Point(8,415)
$btnRefreshProcs.Size = New-Object System.Drawing.Size(150,35); $btnRefreshProcs.FlatStyle = "Flat"
$btnRefreshProcs.BackColor = [System.Drawing.Color]::FromArgb(0,30,40); $btnRefreshProcs.ForeColor = [System.Drawing.Color]::FromArgb(0,180,220)
$btnRefreshProcs.Font = New-Object System.Drawing.Font("Consolas",9)
$btnRefreshProcs.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0,100,140)
$tabProcs.Controls.Add($btnRefreshProcs)

$lblProcCount = New-Object System.Windows.Forms.Label
$lblProcCount.Text = ""; $lblProcCount.Location = New-Object System.Drawing.Point(175,422)
$lblProcCount.AutoSize = $true; $lblProcCount.ForeColor = [System.Drawing.Color]::FromArgb(80,80,80)
$lblProcCount.Font = New-Object System.Drawing.Font("Consolas",9)
$tabProcs.Controls.Add($lblProcCount)

# ============================================================
# === KILL LOG TAB ===
# ============================================================

$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Location = New-Object System.Drawing.Point(8,8); $logBox.Size = New-Object System.Drawing.Size(660,390)
$logBox.BackColor = [System.Drawing.Color]::FromArgb(4,4,4); $logBox.ForeColor = [System.Drawing.Color]::FromArgb(0,200,0)
$logBox.Font = New-Object System.Drawing.Font("Consolas",9); $logBox.ReadOnly = $true; $logBox.BorderStyle = "None"
$tabLog.Controls.Add($logBox)

$btnClearLog = New-Object System.Windows.Forms.Button
$btnClearLog.Text = "CLEAR LOG"; $btnClearLog.Location = New-Object System.Drawing.Point(8,408)
$btnClearLog.Size = New-Object System.Drawing.Size(150,35); $btnClearLog.FlatStyle = "Flat"
$btnClearLog.BackColor = [System.Drawing.Color]::FromArgb(18,18,18); $btnClearLog.ForeColor = [System.Drawing.Color]::FromArgb(100,100,100)
$btnClearLog.Font = New-Object System.Drawing.Font("Consolas",9)
$btnClearLog.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(50,50,50)
$tabLog.Controls.Add($btnClearLog)

$btnExportLog = New-Object System.Windows.Forms.Button
$btnExportLog.Text = "EXPORT LOG (.txt)"; $btnExportLog.Location = New-Object System.Drawing.Point(168,408)
$btnExportLog.Size = New-Object System.Drawing.Size(200,35); $btnExportLog.FlatStyle = "Flat"
$btnExportLog.BackColor = [System.Drawing.Color]::FromArgb(0,28,0); $btnExportLog.ForeColor = [System.Drawing.Color]::FromArgb(0,180,0)
$btnExportLog.Font = New-Object System.Drawing.Font("Consolas",9)
$btnExportLog.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(0,75,0)
$tabLog.Controls.Add($btnExportLog)

# ============================================================
# === HELP TAB ===
# ============================================================

$helpBox = New-Object System.Windows.Forms.RichTextBox
$helpBox.Location = New-Object System.Drawing.Point(8,8); $helpBox.Size = New-Object System.Drawing.Size(660,460)
$helpBox.BackColor = [System.Drawing.Color]::FromArgb(4,4,4); $helpBox.ForeColor = [System.Drawing.Color]::FromArgb(175,175,175)
$helpBox.Font = New-Object System.Drawing.Font("Consolas",10); $helpBox.ReadOnly = $true; $helpBox.BorderStyle = "None"
$helpBox.Text = @"
+----------------------------------------------------------+
|      DIGI KILLER IRONCLAD v5.0  --  HELP                 |
+----------------------------------------------------------+

[ TERMINATOR TAB ]
  BROWSE        : Celprogram .exe kivalasztasa
  NUKE ALL      : Azonnal leallitja az osszes peldanyt
  GUARDIAN      : Auto-Kill masodpercenkent
  CLEAR TARGET  : Torol mindent

[ SUSPEND/RESUME TAB ]
  SUSPEND       : Befagyasztja a folyamatot
                  (CPU 0%, memoria megmarad, windows nem latszik)
  RESUME        : Folytatja pontosan onnan ahol megakadt
  KILL SUSPENDED: Leallitja a felfuggesztett folyamatot

[ PROCESS LIST TAB ]
  Listazza az osszes futo folyamatot.
  Dupla klikk egy sorra -> beallitja targetkent.
  REFRESH gomb frissiti a listat.

[ KILL LOG TAB ]
  Minden esemeny idobelyeggel naplozva.
  EXPORT: .txt fajlba menti.

[ TIPPEK ]
  * Futtasd mindig rendszergazdakent (automatikus).
  * Suspend utan a program nem latszik, de mem. foglal.
  * Resume utan pontosan folytatja -- hasznos teszteleshez.

[ TECHNIKAI INFO ]
  Motor  : WinForms + PowerShell 5+
  Suspend: Win32 SuspendThread / ResumeThread API
  Verzio : 5.0
"@
$tabHelp.Controls.Add($helpBox)

# ============================================================
# LOG HELPER
# ============================================================
function Write-Log {
    param([string]$msg, [string]$level = "INFO")
    $ts = Get-Date -Format "HH:mm:ss"
    $line = "[$ts][$level] $msg"
    $colMap = @{
        "INFO"    = [System.Drawing.Color]::FromArgb(0,200,0)
        "WARN"    = [System.Drawing.Color]::Orange
        "KILL"    = [System.Drawing.Color]::FromArgb(255,50,50)
        "SUSPEND" = [System.Drawing.Color]::FromArgb(255,180,0)
        "RESUME"  = [System.Drawing.Color]::FromArgb(0,220,100)
        "SYS"     = [System.Drawing.Color]::Cyan
    }
    $col = if ($colMap.ContainsKey($level)) { $colMap[$level] } else { [System.Drawing.Color]::White }
    $logBox.SelectionStart  = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor  = $col
    $logBox.AppendText("$line`n")
    $logBox.ScrollToCaret()
}

# ============================================================
# SUSPEND / RESUME FUGGVENYEK
# ============================================================
function Suspend-Process {
    param($proc)
    foreach ($t in $proc.Threads) {
        $handle = [ProcessControl]::OpenThread([ProcessControl]::THREAD_SUSPEND_RESUME, $false, $t.Id)
        if ($handle -ne [IntPtr]::Zero) {
            [ProcessControl]::SuspendThread($handle) | Out-Null
            [ProcessControl]::CloseHandle($handle) | Out-Null
        }
    }
}

function Resume-Process {
    param($proc)
    foreach ($t in $proc.Threads) {
        $handle = [ProcessControl]::OpenThread([ProcessControl]::THREAD_SUSPEND_RESUME, $false, $t.Id)
        if ($handle -ne [IntPtr]::Zero) {
            [ProcessControl]::ResumeThread($handle) | Out-Null
            [ProcessControl]::CloseHandle($handle) | Out-Null
        }
    }
}

function Update-SuspendTab {
    if ($Global:TargetName -ne "") {
        $lblSuspName.Text = "Target: $Global:TargetName"
        $procs = @(Get-Process | Where-Object { try { $_.Path -eq $Global:TargetPath } catch { $false } })
        if ($procs.Count -gt 0) {
            $pids = ($procs | ForEach-Object { $_.Id }) -join ", "
            $lblSuspPidVal.Text = $pids
            if ($Global:IsSuspended) {
                $lblSuspStateVal.Text      = "SUSPENDED (BEFAGYASZTVA)"
                $lblSuspStateVal.ForeColor = [System.Drawing.Color]::Orange
            } else {
                $lblSuspStateVal.Text      = "RUNNING (FUT)"
                $lblSuspStateVal.ForeColor = [System.Drawing.Color]::FromArgb(0,220,0)
            }
        } else {
            $lblSuspStateVal.Text      = "NOT RUNNING"
            $lblSuspStateVal.ForeColor = [System.Drawing.Color]::FromArgb(100,100,100)
            $lblSuspPidVal.Text        = "---"
        }
    } else {
        $lblSuspName.Text      = "Target: --- (allits be targetet a TERMINATOR tabban)"
        $lblSuspStateVal.Text  = "---"
        $lblSuspPidVal.Text    = "---"
    }
}

function Refresh-ProcessList {
    $listProcs.Items.Clear()
    $procs = Get-Process | Where-Object { $_.Id -gt 0 } | Sort-Object Name
    foreach ($p in $procs) {
        try {
            $item = New-Object System.Windows.Forms.ListViewItem($p.Name)
            $item.SubItems.Add($p.Id.ToString()) | Out-Null
            $item.SubItems.Add([Math]::Round($p.TotalProcessorTime.TotalSeconds, 1).ToString()) | Out-Null
            $item.SubItems.Add([Math]::Round($p.WorkingSet64 / 1MB, 1).ToString()) | Out-Null
            try { $path = $p.MainModule.FileName } catch { $path = "" }
            $item.SubItems.Add($path) | Out-Null
            $item.Tag = $path
            $listProcs.Items.Add($item) | Out-Null
        } catch {}
    }
    $lblProcCount.Text = "$($listProcs.Items.Count) folyamat"
}

# ============================================================
# TIMER
# ============================================================
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000

$timer.Add_Tick({
    $Global:Uptime++
    $ts = [TimeSpan]::FromSeconds($Global:Uptime)
    $lblUptimeVal.Text = $ts.ToString("hh\:mm\:ss")

    if ($Global:TargetPath -ne "") {
        $procs = @(Get-Process | Where-Object {
            try { $_.Path -eq $Global:TargetPath } catch { $false }
        })

        if ($procs.Count -gt 0) {
            $pids = ($procs | ForEach-Object { $_.Id }) -join ", "
            if ($Global:IsSuspended) {
                $lblStatusVal.Text      = "SUSPENDED -- $($procs.Count) INSTANCE(S)"
                $lblStatusVal.ForeColor = [System.Drawing.Color]::Orange
            } else {
                $lblStatusVal.Text      = "DETECTED -- $($procs.Count) INSTANCE(S) RUNNING"
                $lblStatusVal.ForeColor = [System.Drawing.Color]::FromArgb(255,50,50)
            }
            $lblInstVal.Text     = "$($procs.Count) x $Global:TargetName  (PID: $pids)"
            $progressBar.Visible = $true

            if ($chkAuto.Checked -and -not $Global:IsSuspended) {
                $procs | Stop-Process -Force -ErrorAction SilentlyContinue
                $Global:KillCount += $procs.Count
                $lblKillCounter.Text = "KILLS: $Global:KillCount"
                Write-Log "AUTO-KILL: $($procs.Count)x '$Global:TargetName' leallitva." "KILL"
                if ($chkSound.Checked) { [Console]::Beep(880,120) }
            }
        } else {
            if ($Global:IsSuspended) { $Global:IsSuspended = $false }
            $lblStatusVal.Text      = "TARGET NOT RUNNING -- MONITORING..."
            $lblStatusVal.ForeColor = [System.Drawing.Color]::Cyan
            $lblInstVal.Text        = "0 aktiv peldany"
            $progressBar.Visible    = $false
        }
        Update-SuspendTab
    }
})

# ============================================================
# ESEMENYKEZELOK
# ============================================================

$btnBrowse.Add_Click({
    $fd = New-Object System.Windows.Forms.OpenFileDialog
    $fd.Filter = "Executable (*.exe)|*.exe|Minden fajl (*.*)|*.*"
    if ($fd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $Global:TargetPath    = $fd.FileName
        $Global:TargetName    = $fd.SafeFileName
        $Global:IsSuspended   = $false
        $txtTarget.Text       = $fd.FileName
        $lblInstVal.Text      = "---"
        Write-Log "TARGET LOCKED: $($fd.SafeFileName)  [$($fd.FileName)]" "SYS"
        Update-SuspendTab
    }
})

$btnKill.Add_Click({
    if ($Global:TargetPath -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Nincs target kivalasztva!", "Hiba", "OK", "Warning") | Out-Null
        return
    }
    $procs = @(Get-Process | Where-Object { try { $_.Path -eq $Global:TargetPath } catch { $false } })
    if ($procs.Count -gt 0) {
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        $Global:KillCount += $procs.Count
        $Global:IsSuspended = $false
        $lblKillCounter.Text = "KILLS: $Global:KillCount"
        Write-Log "MANUAL NUKE: $($procs.Count)x '$Global:TargetName' megsemmisitve." "KILL"
        if ($chkSound.Checked) { [Console]::Beep(440,200); [Console]::Beep(220,300) }
        [System.Windows.Forms.MessageBox]::Show("$($procs.Count) peldany leallitva.", "NUKE COMPLETE", "OK", "Information") | Out-Null
    } else {
        Write-Log "NUKE: '$Global:TargetName' nem fut." "WARN"
        [System.Windows.Forms.MessageBox]::Show("A celprogram nem fut.", "NUKE", "OK", "Information") | Out-Null
    }
})

$btnClear.Add_Click({
    $Global:TargetPath  = ""
    $Global:TargetName  = ""
    $Global:IsSuspended = $false
    $txtTarget.Text     = ">>> Nincs target kivalasztva <<<"
    $lblStatusVal.Text       = "STANDBY"
    $lblStatusVal.ForeColor  = [System.Drawing.Color]::Cyan
    $lblInstVal.Text         = "---"
    $progressBar.Visible     = $false
    Write-Log "Target torolve." "SYS"
    Update-SuspendTab
})

$btnSuspend.Add_Click({
    if ($Global:TargetPath -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Nincs target! Allits be targetet a TERMINATOR tabban.", "Hiba", "OK", "Warning") | Out-Null
        return
    }
    $procs = @(Get-Process | Where-Object { try { $_.Path -eq $Global:TargetPath } catch { $false } })
    if ($procs.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("A celprogram nem fut.", "Suspend", "OK", "Information") | Out-Null
        return
    }
    foreach ($p in $procs) { Suspend-Process $p }
    $Global:IsSuspended = $true
    Write-Log "SUSPEND: '$Global:TargetName' befagyasztva ($($procs.Count) peldany)." "SUSPEND"
    if ($chkSound.Checked) { [Console]::Beep(600,150) }
    Update-SuspendTab
})

$btnResume.Add_Click({
    if ($Global:TargetPath -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Nincs target! Allits be targetet a TERMINATOR tabban.", "Hiba", "OK", "Warning") | Out-Null
        return
    }
    $procs = @(Get-Process | Where-Object { try { $_.Path -eq $Global:TargetPath } catch { $false } })
    if ($procs.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("A celprogram nem fut.", "Resume", "OK", "Information") | Out-Null
        return
    }
    foreach ($p in $procs) { Resume-Process $p }
    $Global:IsSuspended = $false
    Write-Log "RESUME: '$Global:TargetName' folytatas ($($procs.Count) peldany)." "RESUME"
    if ($chkSound.Checked) { [Console]::Beep(880,100); [Console]::Beep(1100,100) }
    Update-SuspendTab
})

$btnKillFromSusp.Add_Click({
    if ($Global:TargetPath -eq "") {
        [System.Windows.Forms.MessageBox]::Show("Nincs target!", "Hiba", "OK", "Warning") | Out-Null
        return
    }
    $procs = @(Get-Process | Where-Object { try { $_.Path -eq $Global:TargetPath } catch { $false } })
    if ($procs.Count -gt 0) {
        foreach ($p in $procs) {
            try { Resume-Process $p } catch {}
        }
        Start-Sleep -Milliseconds 100
        $procs | Stop-Process -Force -ErrorAction SilentlyContinue
        $Global:KillCount += $procs.Count
        $Global:IsSuspended = $false
        $lblKillCounter.Text = "KILLS: $Global:KillCount"
        Write-Log "KILL SUSPENDED: $($procs.Count)x '$Global:TargetName' leallitva." "KILL"
        if ($chkSound.Checked) { [Console]::Beep(220,400) }
    } else {
        [System.Windows.Forms.MessageBox]::Show("A celprogram nem fut.", "Kill", "OK", "Information") | Out-Null
    }
    Update-SuspendTab
})

$btnClearLog.Add_Click({
    $logBox.Clear()
    Write-Log "Log torolve." "SYS"
})

$btnExportLog.Add_Click({
    $sfd = New-Object System.Windows.Forms.SaveFileDialog
    $sfd.Filter = "Szovegfajl (*.txt)|*.txt"
    $sfd.FileName = "digi_killer_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    if ($sfd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $logBox.Text | Out-File -FilePath $sfd.FileName -Encoding UTF8
        Write-Log "Log exportalva: $($sfd.FileName)" "SYS"
    }
})

$btnRefreshProcs.Add_Click({
    Refresh-ProcessList
})

$listProcs.Add_DoubleClick({
    $sel = $listProcs.SelectedItems
    if ($sel.Count -gt 0) {
        $path = $sel[0].Tag
        if ($path -ne "" -and $path -ne $null -and (Test-Path $path)) {
            $Global:TargetPath  = $path
            $Global:TargetName  = Split-Path $path -Leaf
            $Global:IsSuspended = $false
            $txtTarget.Text     = $path
            Write-Log "TARGET LOCKED (ProcessList): $Global:TargetName" "SYS"
            Update-SuspendTab
            $tabs.SelectedTab = $tabKill
        } else {
            [System.Windows.Forms.MessageBox]::Show("Ennek a folyamatnak nem olvashato az eleresi utja.", "Hiba", "OK", "Warning") | Out-Null
        }
    }
})

# ============================================================
# START
# ============================================================
Write-Log "DIGI KILLER IRONCLAD v5.0 elinditva." "SYS"
Write-Log "Valassz targetet BROWSE gombbal vagy a PROCESS LIST tabban." "INFO"
Refresh-ProcessList
$timer.Start()
$form.ShowDialog() | Out-Null
$timer.Stop()