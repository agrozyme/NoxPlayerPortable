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
Import-Module BitsTransfer

function Receive-File([String] $Source, [String] $Destination) {
  Start-BitsTransfer -Source $Source -Destination $Destination
  #  Invoke-WebRequest -Uri $Source -OutFile $Destination
}

function Pause([String] $Text = 'Press any key to continue ...') {
  Write-Output $Text
  [System.Console]::ReadKey($true)
}

function Main {
  $NoxPlayerSetupUri = 'http://res06.bignox.com/full/20200603/b64c981ffd054d61b6ef6f0560a90a86.exe?filename=nox_setup_v6.6.0.9_full_intl.exe'

  $AssetFolder = $PSScriptRoot + '\assets'
  $Expand = $AssetFolder + '\7za.exe'
  $Bignox = $AssetFolder + '\Bignox.7z'
  $Converter = $AssetFolder + '\Bat_To_Exe_Converter.exe'
  $NoxBatCommand = $AssetFolder + '\Nox.cmd'

  $NoxPlayerFolder = $PSScriptRoot + '\NoxPlayer'
  $NoxPlayerSetupFile = $NoxPlayerFolder + '\NoxPlayerSetup.exe'
  $NoxFolder = $NoxPlayerFolder + '\Nox'
  $Icon = $NoxFolder + '\bin\res\shortcut5.ico'
  $NoxExeCommand = $NoxPlayerFolder + '\Nox.exe'

  Write-Host 'Creating NoxPlayer Folder...'
  New-Item -ItemType Directory -Path $NoxPlayerFolder -Force

  Write-Host 'Downloading NoxPlayerSetup Package...'
  Receive-File $NoxPlayerSetupUri $NoxPlayerSetupFile

  Write-Host 'Extracting NoxPlayerSetup Files...'
  & $Expand x $NoxPlayerSetupFile -o"$NoxFolder" -y

  Write-Host 'Extracting Bignox Files...'
  & $Expand x $Bignox -o"$NoxPlayerFolder" -y

  Write-Host 'Removing NoxPlayerSetup Package...'
  Remove-Item -Path $NoxPlayerSetupFile -Force

  Write-Host 'Converting Commands...'
  & $Converter /bat $NoxBatCommand /exe $NoxExeCommand /invisible /icon $Icon

  Write-Host
  Write-Host 'Copy The NoxPlayer Folder To Where Ever You Like, Like A USB-Stick'
  Write-Host 'To Run NoxPlayer Go To The NoxPlayer Folder And Run Nox.exe'
  Write-Host
}

Main
Pause
