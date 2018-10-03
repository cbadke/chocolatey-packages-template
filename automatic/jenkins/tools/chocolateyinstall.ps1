$ErrorActionPreference = 'Stop'

# create temp directory
do {
    $tempPath = Join-Path -Path $env:TEMP -ChildPath ([System.Guid]::NewGuid().ToString())
} while (Test-Path $tempPath)
New-Item -ItemType Directory -Path $tempPath | Out-Null

$zipArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileFullPath   = Join-Path -Path $tempPath -ChildPath 'jenkins.zip';
    destination    = $tempPath
    url            = 'http://mirrors.jenkins-ci.org/windows-stable/jenkins-2.73.3.zip'
    checksum       = '18c5ffbd96e60ff9708bcbf1437f4b740246e45d278aa6f23bc69f5d77c54862'
    checksumType   = 'sha256'
}

Get-ChocolateyWebFile @zipArgs
Get-ChocolateyUnzip @zipArgs

$packageArgs = @{
    packageName   = $env:ChocolateyPackageName
    fileType      = 'msi'
    file = Join-Path -Path $tempPath -ChildPath 'jenkins.msi'
    silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
    validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyInstallPackage @packageArgs
