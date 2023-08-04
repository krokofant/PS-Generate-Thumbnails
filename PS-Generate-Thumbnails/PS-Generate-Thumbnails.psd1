@{
    RootModule        = 'PS-Generate-Thumbnails.psm1'

    ModuleVersion     = '2.0'

    GUID              = 'a5b82c5a-bff1-4658-8d86-e8f60a096c78'

    Author            = 'Krokofant'

    Description       = "Generate thumbnails using mtn"

    PowerShellVersion = '7.0.0'

    FunctionsToExport = @(
        'New-Thumbnails'
        )
}
