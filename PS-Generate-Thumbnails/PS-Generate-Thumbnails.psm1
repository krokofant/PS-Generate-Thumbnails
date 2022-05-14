$mtnPath = Join-Path $PSScriptRoot mtn mtn.exe
$processes = New-Object System.Collections.ArrayList

function EscapeString($s) {
    [Management.Automation.WildcardPattern]::Escape($s)
}

function WaitForCompletion {
    "Waiting for thumbnails to be generated..."
    $processes | Wait-Process
    "`n`nDone!"
}

function GenerateThumbnailsInternal($paths) {
    "`nAdding missing thumbnails for:"
    foreach ($path in $paths) {
        $absPath = $path.FullName
        "  $(Resolve-Path -LiteralPath $path.DirectoryName -Relative)"
        "   › $($path.Name)"
        $escapeCwdHack = EscapeString(EscapeString($pwd))
        $generatorProcess = Start-Process "$mtnPath" `
            -WorkingDirectory $escapeCwdHack `
            -WindowStyle Hidden `
            -ArgumentList `
            "-w 3840", "-c 4", "-r 4", `
            "-o .jpg", "-j 80", `
            "-P", "-W", `
            "`"$absPath`"" -PassThru
        $processes.Add($generatorProcess) | Out-Null
    }
}

function New-Thumbnails {
    if (!(Test-Path $mtnPath)) {
        Write-Error "mtn is missing. Run Update-MtnPackage to download mtn"
        return;
    }
    $videosWithoutThumbnails = @()

    if ($args.Count -gt 0) {
        $videosWithoutThumbnails = $args | ForEach-Object { Get-ChildItem (Join-Path $pwd $_) }
    }
    else {
        $videosWithoutThumbnails = Get-ChildItem -LiteralPath $pwd -Depth 2 -Recurse |
        Where-Object {
            $_.Name -match '(?<!sample).(ts|avi|mkv|mp4)$' -and
            !(Test-Path -LiteralPath ($_.FullName -replace "(?!\.)[^.]+$", "jpg"))
        }
    }

    if ($videosWithoutThumbnails.Count -gt 0) {
        GenerateThumbnailsInternal $videosWithoutThumbnails
    }
    else {
        "`n`tFound no videos without thumbnails`n"
    }

    if ($processes.Count -gt 0) {
        WaitForCompletion
    }
}


function Update-MtnPackage {
    [CmdletBinding()]
    param ()
    $mtnFolder = Join-Path $PSScriptRoot 'mtn'
    if (!(Test-Path $mtnFolder)) {
        New-Item -ItemType Directory $mtnFolder | Out-Null
    }

    $tempFolder = Join-Path $PSScriptRoot 'temp'
    if (!(Test-Path $tempFolder)) {
        New-Item -ItemType Directory $tempFolder | Out-Null
    }

    $page = Invoke-WebRequest 'https://bitbucket.org/wahibre/mtn/downloads/'
    $links = $page.Links | Where-Object { $_.href -like '*win64.zip' } | ForEach-Object { "https://bitbucket.org$($_.href)" } | Sort-Object -Property { [version]($_ -replace '.*(\d+\.\d+\.\d+).*', '$1') } -Descending

    Write-Host "Fetching latest: $($links[0])"
    Remove-Item -Recurse "$PSScriptRoot\latest.zip", "$PSScriptRoot\temp" -ErrorAction Ignore
    Invoke-WebRequest $links[0] -OutFile "$PSScriptRoot\latest.zip"
    Expand-Archive "$PSScriptRoot\latest.zip" -DestinationPath "$PSScriptRoot\temp"

    $mtnExe = (Get-ChildItem "$PSScriptRoot\temp" -Recurse -Filter 'mtn.exe')
    Remove-Item "$PSScriptRoot\mtn\*" -Recurse
    Get-ChildItem "$($mtnExe.DirectoryName)" | Copy-Item -Destination "$PSScriptRoot\mtn"
    Remove-Item -Recurse "$PSScriptRoot\latest.zip", "$PSScriptRoot\temp" -ErrorAction Ignore
}
