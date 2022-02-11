#RequireAdmin
#include <File.au3>
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>

$folder = IniRead(@scriptdir & "\config.ini", "PHP", "folder", 0)
If StringRight($folder, 1) <> "\" Then $folder &= "\"
$curVer = IniRead(@scriptdir & "\config.ini", "PHP", "current", 0)
$versions = _FileListToArray($folder, "*", 2)
If @error > 0 Then
	MsgBox(16, "PHP Version Switcher", "Не удалось открыть папку " & $folder & " или папка пуста." & @CRLF & "Пожалуйста отредактируйте config.ini")
	Exit
EndIf


$path = StringSplit(RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "Path"), ";")
$newPath = null

For $i = 1 To $path[0]
	If StringInStr($path[$i], $folder) == 0 Then
		$newPath &= $path[$i]
		If StringRight($newPath, 1) <> ";" Then $newPath &= ";"
	EndIf
Next




; GUI
$hGUI = GUICreate("PHP Version Switcher", 550, 410)
GUICtrlCreateGroup("   Пожалуйста, выберите версию PHP   ", 10, 10, 530, 330)

$radioStartX = 20
$radioStartY = 40

$rbts = $versions[0]
If $rbts > 30 Then
	MsgBox(16, "PHP Version Switcher", "В целевой папке более 30 версий.")
	Exit
EndIf
Local $iRadio[$rbts]

For $i = 1 To $rbts
	$iRadio[$i - 1] = GUICtrlCreateRadio($versions[$i], $radioStartX, $radioStartY, 100, 20)
	If $curVer == $versions[$i] Then GUICtrlSetState($iRadio[$i - 1], $GUI_CHECKED)
	$radioStartY += 30
	If Mod($i, 10) == 0 Then
		$radioStartX = 21.5 * $i
		$radioStartY = 40
	EndIf
Next
$Button_1 = GUICtrlCreateButton("Применить", 215, 360, 120)
If $curVer < 1 Or $curVer > $rbts Then GUICtrlSetState($Button_1, $GUI_DISABLE)
GUISetState()

While 1
	Switch GUIGetMsg()
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Button_1
			ExitLoop
	EndSwitch
	If $curVer < 1 Or $curVer > $rbts Then
		For $i = 1 To $rbts
			If GUICtrlRead($iRadio[$i - 1]) == $GUI_CHECKED Then GUICtrlSetState($Button_1, $GUI_ENABLE)
		Next
	EndIf
	Sleep(50)
WEnd

For $i = 0 To $rbts - 1
	If GUICtrlRead($iRadio[$i]) == $GUI_CHECKED Then
		IniWrite(@scriptdir & "\config.ini", "PHP", "current", $versions[$i + 1])
		$newPath &= $folder & $versions[$i + 1] & ";"
		RegWrite("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment", "Path", "REG_EXPAND_SZ", $newPath)
		EnvUpdate()
		ExitLoop
	EndIf
Next