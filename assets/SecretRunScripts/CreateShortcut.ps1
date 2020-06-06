Set-StrictMode -Version Latest

function Invoke-Administrator([String] $FilePath, [String[]] $ArgumentList = '') {
  $Current = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
  $Administrator = [Security.Principal.WindowsBuiltInRole]::Administrator

  if (-not $Current.IsInRole($Administrator)) {
    $PowerShellPath = (Get-Process -Id $PID).Path
    $Command = "" + $FilePath + "$ArgumentList" + ""
    Start-Process $PowerShellPath "-NoProfile -ExecutionPolicy Bypass -File $Command" -Verb RunAs
    exit
  } else {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy ByPass
  }
}

Invoke-Administrator $PSCommandPath

function Set-Shortcut ([string] $ShortcutPath) {
  $Shell = New-Object -comObject WScript.Shell
  Return $Shell.CreateShortcut($ShortcutPath)
}

function Main () {
  $DesktopPath = $env:HOMEDRIVE + $env:HOMEPATH + '\Desktop'
  $BinPath = $PSScriptRoot + '\bin'

  Write-Host 'Set Nox Shortcut...'
  $Nox = Set-Shortcut ($DesktopPath + '\Nox.lnk')
  $Nox.TargetPath = $BinPath + '\Nox.exe'
  $Nox.Save()

  Write-Host 'Set MultiPlayerManager Shortcut...'
  $MultiPlayerManager = Set-Shortcut ($DesktopPath + '\MultiPlayerManager.lnk')
  $MultiPlayerManager.TargetPath = $BinPath + '\MultiPlayerManager.exe'
  $MultiPlayerManager.Save()
}

Main
