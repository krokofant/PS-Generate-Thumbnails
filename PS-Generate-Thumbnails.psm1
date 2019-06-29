$mtnPath = "mtn.exe"
$processes = New-Object System.Collections.ArrayList

function EscapeString($s) {
    [Management.Automation.WildcardPattern]::Escape($s)
}

function WaitForCompletion {
    "Waiting for thumbnails to be generated..."
    $processes | Wait-Process
    "`n`nDone!"
}

function GenerateThumbnails($paths) {
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

$videosWithoutThumbnails = @()

if ($args.Count -gt 0) {
    $videosWithoutThumbnails = $args | ForEach-Object { Get-ChildItem (Join-Path $pwd $_)  }
}
else {
    $videosWithoutThumbnails = Get-ChildItem -LiteralPath $pwd -Depth 2 -Recurse |
        Where-Object {
        $_.Name -match '(?<!sample).(ts|avi|mkv|mp4)$' -and
        !(Test-Path -LiteralPath ($_.FullName -replace "(?!\.)[^.]+$", "jpg"))
    }
}

if ($videosWithoutThumbnails.Count -gt 0) {
    GenerateThumbnails $videosWithoutThumbnails
}
else {
    "`n`tFound no videos without thumbnails`n"
}

if ($processes.Count -gt 0) {
    WaitForCompletion
}
