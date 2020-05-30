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

class Setup {
  [String] $NoxPlayerSetupUri = 'http://res06.bignox.com/full/20200525/309a2a31cac647e88653f03d8703830b.exe?filename=nox_setup_v6.6.0.8_full_intl.exe'

  [String] GetNoxPlayerFolder() {
    return $PSScriptRoot + '\NoxPlayer'
  }

  [String] GetNoxPlayerSetupFile() {
    return $this.GetNoxPlayerFolder() + '\NoxPlayerSetup.exe'
  }

  [String] GetAssetFolder() {
    return $PSScriptRoot + '\assets'
  }

  Run() {
    $AssetFolder = $this.GetAssetFolder()
    $Expand = $AssetFolder + '\7za.exe'
    $Bignox = $AssetFolder + '\Bignox.7z'
    $Converter = $AssetFolder + '\Bat_To_Exe_Converter.exe'
    $CommandPattern = $AssetFolder + '\SecretRunScripts\*.cmd'

    $NoxPlayerFolder = $this.GetNoxPlayerFolder()
    $NoxPlayerSetupFile = $NoxPlayerFolder + '\NoxPlayerSetup.exe'
    $NoxFolder = $NoxPlayerFolder + '\Nox'
    $Icon = $NoxFolder + '\bin\res\shortcut5.ico'

    Write-Host 'Creating NoxPlayer Folder...'
    New-Item -ItemType Directory -Path $NoxPlayerFolder -Force

    Write-Host 'Downloading NoxPlayerSetup Package...'
    Receive-File $this.NoxPlayerSetupUri $NoxPlayerSetupFile

    Write-Host 'Extracting NoxPlayerSetup Files...'
    & $Expand x $NoxPlayerSetupFile -o"$NoxFolder" -y

    Write-Host 'Extracting Bignox Files...'
    & $Expand x $Bignox -o"$NoxPlayerFolder" -y

    Write-Host 'Removing NoxPlayerSetup Package...'
    Remove-Item -Path $NoxPlayerSetupFile -Force

    Write-Host 'Converting Commands...'
    Get-ChildItem -Path $CommandPattern | ForEach-Object -Process {
      $Command = $this.GetNoxPlayerFolder() + '\' + $_.BaseName + '.exe'
      & $Converter /bat $_.FullName /exe $Command /invisible /icon $Icon
    }
  }

}

function Show-Usage() {
  Write-Host
  Write-Host 'Copy The NoxPlayer Folder To Where Ever You Like, Like A USB-Stick'
  Write-Host 'To Run NoxPlayer Go To The NoxPlayer Folder And Run Nox.exe'
  Write-Host
}

function Main {
  [Setup]::new().Run()
  Show-Usage
}

Main
Pause
