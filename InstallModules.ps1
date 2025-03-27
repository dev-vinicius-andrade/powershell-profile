function Install-ModuleIfNotInstalled {
	param (
		[Parameter(Mandatory = $true)]
		[string]$ModuleName,
        
		[Parameter()]
		[string]$RequiredVersion,
        
		[Parameter()]
		[ValidateSet("CurrentUser", "AllUsers")]
		[string]$Scope = "CurrentUser"
	)

	if (-not (Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue)) {
		Write-Host "Installing module '$ModuleName'..."
		if ($PSBoundParameters.ContainsKey('RequiredVersion')) {
			Install-Module -Name $ModuleName -RequiredVersion $RequiredVersion -Scope $Scope -Force
		}
		else {
			Install-Module -Name $ModuleName -Scope $Scope -Force
		}
		Write-Host "Module '$ModuleName' installed."
	}
 else {
		Write-Host "Module '$ModuleName' is already installed."
	}
}

# Use the function for each module
Install-ModuleIfNotInstalled -ModuleName "posh-git"
Install-ModuleIfNotInstalled -ModuleName "PSReadLine" -RequiredVersion "2.1.0"
Install-ModuleIfNotInstalled -ModuleName "syntax-highlighting"
