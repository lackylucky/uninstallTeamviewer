#Define the variables
Clear-Variable software 
Clear-Variable maxversion
$software = "TeamViewer" #Name of the software
$maxversion = "15.30.3" #Up to which version should be the program uninstalled


#Ask the package manager for the program you want
$installed = Get-Package -Name $software -MaximumVersion $maxversion

#If it installed?
If($installed) {
    Write-Debug "'$software' is installed."
    #Try to uninstall the package with the package manager
    Uninstall-Package -Name $software -MaximumVersion $maxersion -ForceBootstrap

    #If it still installed?
    $stillinstalled = Get-Package $-Name $software -MaximumVersion $maxversion
    If($stillinstalled) {
        Write-Debug "'$software' is still installed."
        #Hmmm the uninstall over the package manager doesn't work...
        #Let's check the registry for the uninstall path
        $regkey = Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall | ForEach-Object { Get-ItemProperty $_.PsPath } | Select-Object DisplayName,DisplayVersion,UninstallString | Where-Object {$_.DisplayName -eq "$software"} | Where-Object {$_.DisplayVersion -CLE "$maxversion"}
        If(-Not $regkey) {
            $regkey = Get-ChildItem HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ | ForEach-Object { Get-ItemProperty $_.PsPath } | Select-Object DisplayName,DisplayVersion,UninstallString | Where-Object {$_.DisplayName -eq "$software"} | Where-Object {$_.DisplayVersion -CLE "$maxversion"}
        }
        #If ther a uninstall path, run the uninstall.exe silent
        If($regkey) {
            Start-Process -FilePath $regkey.UninstallString -ArgumentList "/S /F"
        } else {
            Write-Debug "'$software' has no uninstall Reg-Key"
        }

        #Check the package manager again
        $stillinstalled = Get-Package -Name $software -MaximumVersion $maxversion
        If($stillinstalled) {
            Write-Debug "The uninstall of '$software' was unsuccessful, sorry"
            exit 1
        } else {
            Write-Debug "'$software' is no loger installed."
        }

	
    } else {
        Write-Debug "'$software' is no loger installed."
    }
	
} else {
    Write-Output "'$software' is not installed."

}
exit 0
