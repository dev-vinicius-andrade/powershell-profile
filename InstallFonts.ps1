# InstallFonts.ps1
# Script to intelligently install fonts from the Fonts folder

# Define script parameters
param (
    [Parameter(Mandatory = $false)]
    [bool]$LogInstalledFonts = $true
)

# Define fonts directory
$fontsFolder = Join-Path $PSScriptRoot "Fonts"
$systemFontsFolder = Join-Path $env:SystemRoot "Fonts"

# Function to check if a font is already installed
function Test-FontInstalled {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FontName
    )
    
    # Remove file extension and any nerd font indicators for comparison
    $fontBaseName = [System.IO.Path]::GetFileNameWithoutExtension($FontName)
    
    # Check in Windows Registry
    $fontRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
    $installedFonts = Get-ItemProperty -Path $fontRegistryPath
    
    foreach ($property in $installedFonts.PSObject.Properties) {
        if ($property.Name -like "*$fontBaseName*") {
            return $true
        }
    }
    
    # Also check if the font file exists in the system fonts folder
    $fontFileInSystem = Join-Path $systemFontsFolder $FontName
    if (Test-Path $fontFileInSystem) {
        return $true
    }
    
    return $false
}

# Function to install a font
function Install-Font {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FontPath,
        
        [Parameter(Mandatory = $false)]
        [bool]$LogInstalledFonts = $true
    )
    
    $fontName = Split-Path $FontPath -Leaf
    
    # Check if already installed
    if (Test-FontInstalled -FontName $fontName) {
        # Only log if the parameter is set to true
        if ($LogInstalledFonts) {
            Write-Host "Font already installed: $fontName" -ForegroundColor Yellow
        }
        return
    }
    
    try {
        # Copy the font to the Windows Fonts directory
        Copy-Item $FontPath -Destination $systemFontsFolder -Force

        # Add the font to the registry
        $fontRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontRegistryName = [System.IO.Path]::GetFileNameWithoutExtension($fontName)
        $fontRegistryValue = $fontName
        
        # Need admin rights for this
        New-ItemProperty -Path $fontRegistryPath -Name "$fontRegistryName (TrueType)" -Value $fontRegistryValue -PropertyType String -Force | Out-Null
        
        Write-Host "Successfully installed: $fontName" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to install font: $fontName" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main script execution
function Install-Fonts {
    param (
        [Parameter(Mandatory = $false)]
        [bool]$LogInstalledFonts = $true
    )

    # Check if running as administrator
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if (-not $isAdmin) {
        Write-Host "This script needs to be run as Administrator to install fonts." -ForegroundColor Red
        Write-Host "Please restart PowerShell as Administrator and run this script again." -ForegroundColor Red
        return
    }
    
    # Check if Fonts folder exists
    if (-not (Test-Path $fontsFolder)) {
        Write-Host "Fonts folder not found: $fontsFolder" -ForegroundColor Red
        return
    }
    
    # Get all font files (ttf and otf)
    $fontFiles = Get-ChildItem -Path $fontsFolder -Recurse -Include *.ttf, *.otf
    
    if ($fontFiles.Count -eq 0) {
        Write-Host "No font files found in $fontsFolder" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Found $($fontFiles.Count) font files. Starting installation..." -ForegroundColor Cyan
    
    # Install each font
    foreach ($fontFile in $fontFiles) {
        Install-Font -FontPath $fontFile.FullName -LogInstalledFonts $LogInstalledFonts
    }
    
    Write-Host "Font installation complete." -ForegroundColor Cyan
}

# Run the install function with the parameter
Install-Fonts -LogInstalledFonts $LogInstalledFonts
