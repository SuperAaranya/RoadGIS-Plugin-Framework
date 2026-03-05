param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRoot
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$DistDir = Join-Path $ProjectRoot "dist\windows"
New-Item -ItemType Directory -Force -Path $DistDir | Out-Null

Write-Host "Building Windows executable..."
python -m pip install --upgrade pyinstaller | Out-Null
pyinstaller --noconfirm --clean --name RoadGISPro --onefile --windowed (Join-Path $ProjectRoot "RoadGISPro.py")

$ExeSource = Join-Path $ProjectRoot "dist\RoadGISPro.exe"
$ExeTarget = Join-Path $DistDir "RoadGISPro.exe"
Copy-Item -LiteralPath $ExeSource -Destination $ExeTarget -Force

Write-Host "Preparing MSI scaffold..."
$WixTemplate = @"
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
  <Product Id="*" Name="RoadGIS Pro" Language="1033" Version="1.0.0.0" Manufacturer="RoadGIS" UpgradeCode="PUT-GUID-HERE">
    <Package InstallerVersion="500" Compressed="yes" InstallScope="perMachine" />
    <MediaTemplate />
    <Directory Id="TARGETDIR" Name="SourceDir">
      <Directory Id="ProgramFilesFolder">
        <Directory Id="INSTALLFOLDER" Name="RoadGISPro" />
      </Directory>
    </Directory>
    <DirectoryRef Id="INSTALLFOLDER">
      <Component Id="RoadGISExeComponent" Guid="PUT-GUID-HERE">
        <File Id="RoadGISExeFile" Source="$ExeTarget" KeyPath="yes" />
      </Component>
    </DirectoryRef>
    <Feature Id="MainFeature" Title="RoadGIS Pro" Level="1">
      <ComponentRef Id="RoadGISExeComponent" />
    </Feature>
  </Product>
</Wix>
"@

$WixFile = Join-Path $DistDir "RoadGISPro.wxs"
$WixTemplate | Out-File -LiteralPath $WixFile -Encoding utf8

Write-Host "Build complete:"
Write-Host "  EXE: $ExeTarget"
Write-Host "  MSI template: $WixFile"
Write-Host "Compile MSI with WiX candle/light after replacing GUID placeholders."
