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
            "(url\s*=\s*)('.*')" = "`$1'$($Latest.URL)'"
            "(checksum\s*=\s*)('.*')" = "`$1'$($Latest.CheckSum32)'"
        }
     }
}

function global:au_GetLatest {
    $request = Invoke-WebRequest -Uri $url -MaximumRedirection 0 -ErrorAction Ignore

    if($request.StatusDescription -eq 'found')
    {
       $location = $request.Headers.Location
    }
    $filename = $location.Substring($location.LastIndexOf("/") + 1)
    $filename = "jenkins-2.121.3.zip"
    $version = ($filename -split '-|\.' | select -Last 3 -skip 1) -join '.'

    $zipPath = "$localPath/jenkins.zip"
    $shaPath = "$localPath/$filename.sha256"

    $checkSumUrl = "http://mirrors.jenkins-ci.org/windows-stable/$filename.sha256"
    Invoke-WebRequest -Uri $checkSumUrl -OutFile $shaPath
    $checksum = (Get-Content $shaPath -Raw).Split(' ')[0]

    rm -force -ErrorAction Ignore $zipPath
    rm -force -ErrorAction Ignore $shaPath

    Invoke-WebRequest $location -OutFile $zipPath
    Unzip $zipPath $localPath

    Write-Host "checksum: $checksum"
    Write-Host "version: $version"

    $Latest = @{ URL = $location; Version = $version; CheckSum32 = $checkSum; CheckSumType = 'sha256' }
    return $Latest
}

update -NoCheckChocoVersion -NoCheckUrl -ChecksumFor none -Force
