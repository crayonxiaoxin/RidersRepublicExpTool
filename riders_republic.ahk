#Requires AutoHotkey v2.0.19
#SingleInstance Force
Persistent

HotkeyToggle := "F8"
ProcessName   := "RidersRepublic.exe"

global g_Running := false
global Interval  := 20

MyGui := Gui("-MinimizeBox +AlwaysOnTop +ToolWindow", "极限国度 · 自动连发器")
MyGui.BackColor := "1e1e1e"
MyGui.SetFont("s11 cWhite", "Microsoft YaHei UI")

WinW := 420

MyGui.AddText("w" WinW " Center BackgroundTrans c00ff88", "极限国度 W + Enter 自动连发器")
MyGui.SetFont("s26 bold")
StatusText := MyGui.AddText("w" WinW " Center BackgroundTrans cRed", "已停止")

MyGui.SetFont("s12 cSilver")
MyGui.AddText("w" WinW " Center BackgroundTrans", "连发间隔（ms）")

MyGui.SetFont("s18 c00ff00", "Consolas")
EditBox := MyGui.AddEdit("w160 h44 Number Limit4 Background1e1e1e vUserInterval +Center", "20")
EditBox.Opt("+0x200")
EditBox.GetPos(,, &ew)
EditBox.Move((WinW - ew) // 2)

MyGui.SetFont("s14 c66ff66")
CurrText := MyGui.AddText("w" WinW " Center BackgroundTrans", "当前：" Interval " ms")

MyGui.SetFont("s18 bold", "Microsoft YaHei UI")
Btn := MyGui.AddButton("w340 h70 Default", "启动连发")
Btn.Opt("cWhite +Background0x007acc")
Btn.GetPos(,, &bw)
Btn.Move((WinW - bw) // 2)

MyGui.SetFont("s10 cCCCCCC")

MyGui.AddText("w" WinW " Center BackgroundTrans", "游戏窗口化 + 管理员运行")
MyGui.AddText("w" WinW " Center BackgroundTrans", "运行后不要操作其他东西！")

MyGui.Show("AutoSize Center")

Hotkey(HotkeyToggle, Toggle)
Btn.OnEvent("Click", Toggle)

; 新增：输入框内容改变时实时更新显示
MyGui["UserInterval"].OnEvent("Change", UpdateIntervalDisplay)

UpdateIntervalDisplay(*) {
    val := Integer(MyGui["UserInterval"].Value)
    if (val >= 10 && val <= 200)
        CurrText.Text := "当前：" val " ms"
    else
        CurrText.Text := "当前：20 ms（已限制）"
}

Toggle(*) {
    global g_Running, Interval

    if !WinExist("ahk_exe " ProcessName) {
        MsgBox "游戏未运行！", , "OK T3 Icon!"
        return
    }

    g_Running := !g_Running

    if g_Running {
        Interval := Integer(MyGui["UserInterval"].Value)
        if (Interval < 20 || Interval > 200)
            Interval := 20
        CurrText.Text := "当前：" Interval " ms"

        if !WinActive("ahk_exe " ProcessName)
            WinActivate "ahk_exe " ProcessName
        Sleep 400
        SetKeyDelay 50, 50

        UpdateStatus()
        SetTimer UpdateStatus, 200
        SetTimer SendToGame, Interval
    } else {
        SetTimer SendToGame, 0
        SetTimer UpdateStatus, 0
        SetKeyDelay -1

        StatusText.Text := "已停止"
        StatusText.Opt "cRed"
        Btn.Text := "启动"
        Btn.Opt "+Background0x007acc"
        MyGui.Title := "极限国度连发器"
    }
}

UpdateStatus() {
    if WinActive("ahk_exe " ProcessName) {
        StatusText.Text := "狂刷中"
        StatusText.Opt "c00ff00"
        MyGui.Title := "极限国度 · 狂刷中 " Interval "ms"
        Btn.Text := "停止"
    } else {
        StatusText.Text := "已暂停（切回游戏继续）"
        StatusText.Opt "cGray"
        MyGui.Title := "极限国度 · 已暂停"
        Btn.Text := "启动"
    }
}

SendToGame() {
    if !g_Running || !ProcessExist(ProcessName) || !WinActive("ahk_exe " ProcessName)
        return

    SendEvent "{w down}"
    Sleep Random(12,28)
    SendEvent "{w up}"
    Sleep 10
    SendEvent "{Enter}"
}

MyGui.OnEvent("Close", (*) => ExitApp())
OnExit(*) => (SetTimer(SendToGame, 0), SetTimer(UpdateStatus, 0))