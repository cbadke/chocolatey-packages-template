Add-Type -AssemblyName System.IO.Compression.FileSystem

import-module au

$url = 'http://mirrors.jenkins-ci.org/windows-stable/latest'
$localPath = $PSScriptRoot

function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function global:au_SearchReplace {
    @{
        'tools\chocolateyinstall.ps1' = @{
            "(url\s*=\s*)('.*')" = "`$1'$($Latest.Url32)'"
            "(checksum\s*=\s*)('.*')" = "`$1'$($Latest.CheckSum32)'"
        }
     }
}

function global:au_BeforeUpdate() {
   $filename2 = $Latest.FileName
   Get-RemoteFiles -Purge -NoSuffix
   $zipPath = "$localPath\tools\$filename2"
   Unzip $zipPath $localPath
}

function global:au_GetLatest {
    $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0 -ErrorAction Ignore

    if($request.StatusDescription -eq 'found')
    {
       $location = $request.Headers.Location
    }

    $location = "http://mirrors.jenkins-ci.org/windows-stable/jenkins-2.121.3.zip"
    $filename = $location.Substring($location.LastIndexOf("/") + 1)
    $version = ($filename -split '-|\.' | select -Last 3 -skip 1) -join '.'

    $shaPath = "$localPath/$filename.sha256"
    $msiPath = "$localPath/jenkins.msi"

    $checkSumUrl = "http://mirrors.jenkins-ci.org/windows-stable/$filename.sha256"
    Invoke-WebRequest -Uri $checkSumUrl -OutFile $shaPath
    $checksum = (Get-Content $shaPath -Raw).Split(' ')[0]

    rm -force -ErrorAction Ignore $shaPath
    rm -force -ErrorAction Ignore $msiPath

    $Latest = @{ Url32 = $location; FileName = $filename; Version = $version; CheckSum32 = $checkSum; CheckSumType = 'sha256' }
    return $Latest
}

update -NoCheckChocoVersion -NoCheckUrl -ChecksumFor none -Force
