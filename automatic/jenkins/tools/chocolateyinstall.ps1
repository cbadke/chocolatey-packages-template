$ErrorActionPreference = 'Stop' # stop on all errors
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

do {
    $tempDir = Join-Path -Path $env:TEMP -ChildPath ([System.Guid]::NewGuid().ToString())
} while (Test-Path $tempDir)
$null = New-Item -ItemType Directory -Path $tempDir

$zipArgs = @{
    packageName     = $env:ChocolateyPackageName
    unzipLocation   = $tempDir
    url             = 'jenkins.zip'
    checksum        = '819e3a76e019054d9a7c62f93f7e9d97'
    checksumType    = 'sha256'
}

Install-ChocolateyZipPackage @zipArgs

$packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'MSI'
    file           = (Join-Path -Path $tempDir -ChildPath 'jenkins.msi')
    silentArgs     = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
    validExitCodes = @(0, 3010, 1641)
}

Install-ChocolateyInstallPackage @packageArgs
