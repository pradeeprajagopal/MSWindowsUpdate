Param(
    $Computer= "$ENV:Computername",
    [Int]$Numberofdays="0"
)
If($Numberofdays -eq "0")
    {
        Get-HotFix -ComputerName $Computer
}
else {
        Get-Hotfix -ComputerName $Computer | Select-Object CSNAME, Installedby, installedon, hotfixid | Where-Object {$_.InstalledOn -lt(get-date).adddays($Numberofdays)} |Sort-Object InstalledOn -Descending
}
