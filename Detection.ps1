function Detect-NPP()
{
    # Define the URL of the GitHub releases page
    $url = "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/"

    try {
        # Use Invoke-WebRequest to download the HTML content of the page
        $response = Invoke-WebRequest -Uri $url
        
        # Collect most recent version number
        $latestReleaseVersion = ($response.ParsedHtml.body.getElementsByClassName('Link--primary Link') | Select-Object @{l="Version"; e={($_.nameProp).replace("v","")}} -first 1).Version
    }
    catch {
        Write-Error "Failed to collect Notepad++ version information from Github."
    }

    $installedversion = (Get-Item "C:\Program Files\Notepad++\notepad++.exe").VersionInfo.FileVersion

    if([version]$installedversion -eq [version]$latestReleaseVersion) {
        Write-Host "Notepad++ detected!"
        # Exit 0
    }
}

Detect-NPP