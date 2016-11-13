
$ErrorActionPreference = 'Stop'; # stop on all errors

#Items that could be replaced based on what you call chocopkgup.exe with
#{{PackageName}} - Package Name (should be same as nuspec file and folder) |/p
#{{PackageVersion}} - The updated version | /v
#{{DownloadUrl}} - The url for the native file | /u
#{{PackageFilePath}} - Downloaded file if including it in package | /pp
#{{PackageGuid}} - This will be used later | /pg
#{{DownloadUrlx64}} - The 64-bit url for the native file | /u64
#{{Checksum}} - The checksum for the url | /c
#{{Checksumx64}} - The checksum for the 64-bit url | /c64
#{{ChecksumType}} - The checksum type for the url | /ct
#{{ChecksumTypex64}} - The checksum type for the 64-bit url | /ct64

$packageName= 'jenkins' # arbitrary name for the package, used in messages
$toolsDir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url = 'Location: http://mirrors.jenkins-ci.org/windows-stable/jenkins-2.19.2.zip'
$checkSum = 'a371cc0971ae62d1b8d4ab1210d804ed0a379c9d0c9c6394826b072b61146bee'
#$filename = $URL.Substring($url.LastIndexOf("/") + 1)

#Get-ChocolateyWebFile $packageName $file $url $url64
#Get-ChocolateyUnzip $file $toolsDir "" $packageName


#$fileLocation = Join-Path $toolsDir 'jenkins.msi'

$packageArgs = @{
  packageName   = $packageName
  unzipLocation = $toolsDir
  fileType      = 'msi'
  url = $url
#  file         = $fileLocation

  softwareName  = 'jenkins*' #part or all of the Display Name as you see it in Programs and Features. It should be enough to be unique

  checksum      = $checkSum
  checksumType  = 'sha256' #default is md5, can also be sha1, sha256 or sha512

  silentArgs    = "/qn /norestart /l*v `"$($env:TEMP)\$($packageName).$($env:chocolateyPackageVersion).MsiInstall.log`"" # ALLUSERS=1 DISABLEDESKTOPSHORTCUT=1 ADDDESKTOPICON=0 ADDSTARTMENU=0
  validExitCodes= @(0, 3010, 1641)
}

Install-ChocolateyPackage @packageArgs # https://chocolatey.org/docs/helpers-install-chocolatey-package


