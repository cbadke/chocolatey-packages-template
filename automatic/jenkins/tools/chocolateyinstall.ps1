
$ErrorActionPreference = 'Stop'; # stop on all errors

$packageName= 'jenkins' # arbitrary name for the package, used in messages
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url = 'http://mirrors.jenkins-ci.org/windows-stable/jenkins-2.73.3.zip'
$checkSum = '18c5ffbd96e60ff9708bcbf1437f4b740246e45d278aa6f23bc69f5d77c54862'
$checkSumMsi = '1324ddd7333e9a0dfbd1240f0f45de76e827657f5c5a0ce4f7a18e16b8092198'

$filename = Join-Path $toolsDir ($url.Substring($url.LastIndexOf("/") + 1))

Get-ChocolateyWebFile -PackageName $packageName -FileFullPath $filename -Url $url -Checksum $checkSum -ChecksumType 'sha256'
Get-ChocolateyUnzip -FileFullPath $fileName -Destination $toolsDir -PackageName $packageName

$msiPath = Join-Path $toolsDir 'jenkins.msi'

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


