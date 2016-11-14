
$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName= 'jenkins' # arbitrary name for the package, used in messages
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url = ''
$checkSum = ''

$filename = Join-Path $toolsDir ($url.Substring($url.LastIndexOf("/") + 1))

Get-ChocolateyWebFile -PackageName $packageName -FileFullPath $filename -Url $url -Checksum $checkSum -ChecksumType 'sha256'
Get-ChocolateyUnzip -FileFullPath $fileName -Destination $toolsDir -PackageName $packageName

$msiPath = Join-Path $toolsDir 'jenkins.msi'

$checkSumMsi = (Get-FileHash $msiPath).Hash

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'msi'
  url           = $msiPath

  softwareName  = 'jenkins*' #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique

  checksum      = $checkSumMsi
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package


