
########################################################################
# Module : MS Windows Update
# Author : Pradeep Rajagopal
# Version: 2.0.0.0
# Version History : 2.0.0.0
#                  : Three Commandlets Get-RunningService
#                                      Validate-PatchStatus
#                                      Post-PatchValidation
#                  : Added three more function
######################################################################### 

Function Get-RunningService

{
<#
    .SYNOPSIS
        
        This function will get the list of service running on a remote computer using the input file. The outut will be stored in C:\Windows\Temp\PrePatch_Service.txt

    .EXAMPLE

        Get-RunningService -File "C:\temp\Servicetest.txt"

        Info : Fetching Service status from 5 Servers
        Info : Providing Sufficent time for the execution

        Status :Total:5 | Success:5 | Failure:0
#>

[CmdletBinding()]
Param(
        #Specify the File Path Containing Server List
        [Parameter(Mandatory)]
        [string]$File
        )

if((!($File)))
{
    Write-Host "Error : File name is mandatory.Exiting...." -BackgroundColor Red 
    Continue
    }

If(!(Test-Path C:\Windows\Temp\PrePatching))
{
    New-Item -Name PrePatching -Path C:\Windows\Temp -ItemType Directory -Force -Confirm:$false
}

    if($File)
{
    $Servers = Get-Content $File
    $Count = $Servers.Count
}

#$Servers
Write-Host ""

Write-Host "Info : Fetching Service status from $Count Servers"

Foreach($Server in $Servers)

{
    Invoke-Command -ComputerName $Server -ScriptBlock {Get-Service | Where-Object {($_.Status -eq "Running") -and ($_.Starttype -ne "Disabled")} | Select-Object Name | Export-csv C:\Windows\Temp\PrePatch_Service.Csv -NoTypeInformation} -AsJob -ThrottleLimit 50 | Out-Null
}


Write-Host "Info : Providing Sufficent time for the execution"

Start-Sleep 30

[int]$Success =[int]$Failure = 0

[int]$i ="0"

Do{
    $Jobs =Get-Job

    if($i -ge "1"){Start-Sleep 30}

    Foreach($Job in $Jobs)
    {
        if($job.state -eq "Completed"){
                                        
                                        $job | Remove-Job
                                        $Success++
                                        }
        elseif(($job.state -eq "Failed") -or ($job.state -eq "Blocked")){
                                        $JOb | Remove-Job
                                        $Failure++
                                        }
        else{}  
       }

    $i++

    $Jobs =Get-Job
}
until($Jobs.count -eq "0")

Write-Host ""
Write-Host "Status :Total:$Count | Success:$Success | Failure:$Failure"
Write-Host "Info : Fetching Service Status complete"
Write-Host "Info : Copying File to local Machine. This may take few seconds to several minutes based on the number of servers"

Foreach
($Server in $Servers)
{
    Copy-Item \\$Server\c$\Windows\Temp\PrePatch_Service.Csv C:\Windows\Temp\PrePatching\$Server.csv -Force
}

}

Function Validate-PatchStatus

{

<#
    .SYNOPSIS
        
        This function will get the Number of Patches missing on the remote server and If there is any reboot pending due to patching.

    .EXAMPLE

        PS C:\Windows\system32> Validate-PatchStatus -File "C:\temp\Servers.txt"




        Computername        : Server1
        Missing Patch Count : 6
        Pending Restart     : True
        PSComputerName      : Server1
        RunspaceId          : 3c4f2d8b-4e11-4b91-9654-8fea9621ec32

        Computername        : Server2
        Missing Patch Count : 6
        Pending Restart     : False
        PSComputerName      : Server2
        RunspaceId          : 697c2d8d-451d-40bd-80ae-1fc6d8b241f5

        Computername        : Server3
        Missing Patch Count : 6
        Pending Restart     : True
        PSComputerName      : Server3
        RunspaceId          : df62d5b6-f974-4794-ae48-4114b4efb62e

        Computername        : Server4
        Missing Patch Count : 5
        Pending Restart     : False
        PSComputerName      : Server4
        RunspaceId          : 0274387f-6734-409b-9688-a21df69eb542

        Computername        : Server5
        Missing Patch Count : 0
        Pending Restart     : False
        PSComputerName      : Server5
        RunspaceId          : af545dbf-46a1-4b0e-8ad8-f81cbfc44d3a

     .EXAMPLE

        PS C:\Windows\system32> Validate-PatchStatus -File "C:\temp\Servers.txt" | Export-Csv C:\Temp\Output.csv


#>

[CmdletBinding()]
Param(
        #Specify the File Path Containing Server List
        [Parameter(Mandatory)]
        [string]$File
        )

$Servers = Get-Content $File 

Foreach($Server in $Servers)
{

#Validation - Patch Validation

$Server= $Server.Trim()

Invoke-Command -ComputerName $Server -ScriptBlock { $updatesession=[activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session","$env:computername"))

                                                    $updatesearcher=$updatesession.CreateUpdateSearcher()

                                                    $searchresult = $updatesearcher.Search("IsInstalled=0")

                                                    $Patch_Count=$searchresult.Updates.Count

                                                    $Restart =$False

                                                    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { $Restart= $true }

                                                    $OutputObj = New-Object -TypeName PSObject
                                                    
                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name Computername -Value $env:computername
                                                    
                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name "Missing Patch Count" -Value $Patch_Count
                                                    
                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name "Pending Restart" -Value $Restart

                                                    $OutputObj
                                                    
                                                    } -AsJob | out-null

}

start-sleep 30

Write-Host ""

Write-Host ""

#Write-host "Server|Missing Patch count|Pending Reboot"


do{

    $Jobs = Get-Job

    Foreach($Job in $Jobs)

    {

    if($JOb.State -ne "Running")

    {

        $Job | Receive-job

        $Job | remove-Job

        }

    }

    }

  until($(get-Job) -eq $Null)

  }

Function Post-PatchValidation

{

<#
    .SYNOPSIS
        
        This function will help you validate the servers after Patch installation

    .EXAMPLE

        PS C:\Windows\system32> Post-PatchValidation -File "C:\temp\Servers.txt"




        Computername        : Server1
        Missing Patch Count : 6
        Pending Restart     : True
        Service Validation  : Failed
        Service Remediated  : True
        PSComputerName      : Server1
        RunspaceId          : 3c4f2d8b-4e11-4b91-9654-8fea9621ec32

        Computername        : Server2
        Missing Patch Count : 6
        Pending Restart     : False
        Service Validation  : Passed
        Service Remediated  : 
        PSComputerName      : Server2
        RunspaceId          : 697c2d8d-451d-40bd-80ae-1fc6d8b241f5

        Computername        : Server3
        Missing Patch Count : 6
        Pending Restart     : True
        Service Validation  : Passed
        Service Remediated  : 
        PSComputerName      : Server3
        RunspaceId          : df62d5b6-f974-4794-ae48-4114b4efb62e

        Computername        : Server4
        Missing Patch Count : 5
        Pending Restart     : False
        Service Validation  : Passed
        Service Remediated  : 
        PSComputerName      : Server4
        RunspaceId          : 0274387f-6734-409b-9688-a21df69eb542

        Computername        : Server5
        Missing Patch Count : 0
        Pending Restart     : False
        Service Validation  : Passed
        Service Remediated  : 
        PSComputerName      : Server5
        RunspaceId          : af545dbf-46a1-4b0e-8ad8-f81cbfc44d3a

     .EXAMPLE

        PS C:\Windows\system32> Post-PatchValidation -File "C:\temp\Servers.txt" | Export-Csv C:\Temp\Output.csv


#>

[CmdletBinding()]
Param(
        #Specify the File Path Containing Server List
        [Parameter(Mandatory)]
        [string]$File
        )

$Servers = Get-Content $File 

If(!(Test-Path C:\Windows\Temp\PostPatching))
{
    New-Item -Name PostPatching -Path C:\Windows\Temp -ItemType Directory -Force -Confirm:$false
}

Foreach($Server in $Servers)
{

#Validation - Patch Validation

$Server= $Server.Trim()

Invoke-Command -ComputerName $Server -ScriptBlock { $updatesession=[activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session","$env:computername"))

                                                    $updatesearcher=$updatesession.CreateUpdateSearcher()

                                                    $searchresult = $updatesearcher.Search("IsInstalled=0")

                                                    $Patch_Count=$searchresult.Updates.Count

                                                    $Restart =$False

                                                    if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { $Restart= $true }

                                                    Get-Service | Where-Object {($_.Status -eq "Running") -and ($_.Starttype -ne "Disabled")} | Select-Object Name | export-csv C:\Windows\Temp\PostPatch_Service.Csv -NoTypeInformation

                                                    $Pre_Services = Get-Content C:\Windows\Temp\PrePatch_Service.Csv

                                                    $Post_Services = Get-Content C:\Windows\Temp\PostPatch_Service.Csv

                                                    $Differences = Compare-Object -ReferenceObject $Pre_Services -DifferenceObject $Post_Services | Where-Object {$_.Sideindicator -eq "<="}

                                                    $Count =$Differences.InputObject.Count
                                                    
                                                    iF($Count -eq "0"){$Validation = "Passed"}
                                                    
                                                    else{$Validation="Failed"
                                                    
                                                         $Remediated = $True
                                                         
                                                         Foreach($Objitem in $Differences.InputObject)
                                                         
                                                         {
                                                         
                                                         $Objitem = $Objitem -replace '"',''
                                                         
                                                         Get-Service $Objitem -ErrorAction 0| Start-Service
                                                         
                                                         

                                                         if($(Get-Service $Objitem -ErrorAction 0).Status -ne "Running"){$Remediated = $False}
                                                        
                                                        }

                                                    }

                                                    $OutputObj = New-Object -TypeName PSObject
                                                    
                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name Computername -Value $env:computername
                                                    
                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name "Missing Patch Count" -Value $Patch_Count
                                                    
                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name "Pending Restart" -Value $Restart

                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name "Service Validation" -Value $Validation

                                                    $OutputObj | Add-Member -MemberType NoteProperty -Name "Service Remediated" -Value $Remediated

                                                    $OutputObj
                                                    
                                                    } -AsJob | out-null

}

start-sleep 30

Write-Host ""

Write-Host ""

#Write-host "Server|Missing Patch count|Pending Reboot"

do{

    $Jobs = Get-Job

    Foreach($Job in $Jobs)

    {

    if($JOb.State -ne "Running")

    {

        $Job | Receive-job

        $Job | remove-Job

        }

    }

    }

  until($(get-Job) -eq $Null)

  Write-Host "Info : Post Patch Validation is complete"
  Write-Host "Info : Copying File to local Machine. This may take few seconds to several minutes based on the number of servers"
  
  Foreach
  ($Server in $Servers)
  {
      Copy-Item \\$Server\c$\Windows\Temp\PostPatch_Service.Csv C:\Windows\Temp\PostPatching\$Server.csv -Force
  }
  
  }

Function Get-PatchReport{
<#
    .SYNOPSIS
        
        This function will help you get the Patch Report from the Input file and Exports the content to output file 

    .EXAMPLE

        PS C:\Windows\system32> Get-PatchReport -InputFile "C:\temp\Servers.txt" -OutputFile "C:\Windows\temp\Output.csv"

#>

    Param(
        [string]$InputFile,
        [string]$OutputFile
    )

    If(!(Test-Path $InputFile))
    {
        Write-Host "Error : $Inputfile does not exist.Hence Aborting.."
        Continue
    }
    Foreach($Server in $InputFile)
    {
        $Server=$Server.Trim()
        Invoke-Command -ComputerName $Server -ScriptBlock{
                                                            $Installed_Patch_Count = (Get-HotFix | Where-Object { $_.InstalledOn -gt (get-date).AddDays(-30) }).Count

                                                            $updatesession=[activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session","$env:computername"))

                                                            $updatesearcher=$updatesession.CreateUpdateSearcher()

                                                            $searchresult = $updatesearcher.Search("IsInstalled=0")

                                                            $Missing_Patch_Count=$searchresult.Updates.Count

                                                            $Restart =$False

                                                            if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { $Restart= $true }

                                                            $OutputObj = New-Object -TypeName PSObject
                                                    
                                                            $OutputObj | Add-Member -MemberType NoteProperty -Name Computername -Value $env:computername
                                                            
                                                            $OutputObj | Add-Member -MemberType NoteProperty -Name "Missing Patch Count" -Value $Missing_Patch_Count
                                                            
                                                            $OutputObj | Add-Member -MemberType NoteProperty -Name "Pending Restart" -Value $Restart
        
                                                            $OutputObj | Add-Member -MemberType NoteProperty -Name "Patch Installed 30" -Value $Installed_Patch_Count
        
                                                            $OutputObj
                                                            
                                                            } -AsJob | out-null
        
    }
        
    start-sleep 30
        
    Write-Host ""
        
    Write-Host ""
        
    do{
        
        $Jobs = Get-Job
        
        Foreach($Job in $Jobs)
        
        {
        If($Job.State -eq "Failed")
        {
            $Job | Remove-Job

            $Failure++
        }
        if($JOb.State -ne "Running")
        
            {
        
            $Job | Receive-job | Export-Csv $OutputFile -Append -NoTypeInformation
        
            $Job | remove-Job

            $Success++
        
            }
        
        }
        
    }
        
    until($(get-Job) -eq $Null)
 
 Write-Host "Total Server : $InputFile.Count | Success : $Success | Failed : $Failure"

}

Function Install-MSWindowsUpdate{
<#
    .SYNOPSIS
        
        This function will install the patches on servers based on input file. This will install all missing patches

    .EXAMPLE

        PS C:\Windows\system32> Install-MSWindowsUpdate -InputFile "C:\temp\Servers.txt"

#>
    
    Param(
        [String]$Inputfile,
        [Int]$Throttle=10
    )
    If(!(Test-Path $Inputfile))
    {
        Write-Host " Error : Input file not found" -BackgroundColor Red
        Continue
    }
    $Servers = Get-Content $Inputfile
    Foreach($Server in $Servers)
    {
        $Server = $Server.Trim()
        Invoke-Command -ComputerName $Server -ScriptBlock{
                                                            $waar = $True 
                                                            $Session = New-Object -com "Microsoft.Update.Session" 
                                                            $Search = $Session.CreateUpdateSearcher()  
                                                            $SearchResults = $Search.Search("IsInstalled=0 and IsHidden=0")  
                                                            $DownloadCollection = New-Object -com "Microsoft.Update.UpdateColl" 
                                                            $SearchResults.Updates | ForEach-Object {  
                                                                if ($_.InstallationBehavior.CanRequestUserInput -ne $waar) 
                                                                {  
                                                                $DownloadCollection.Add($_) | Out-Null  
                                                                }  
                                                            }  
                                                            if ($($SearchResults.Updates.Count -gt 0)) { 
                                                                $Downloader = $Session.CreateUpdateDownloader() 
                                                                $Downloader.Updates = $DownloadCollection  
                                                                $Downloader.Download() 
                                                            } 
                                                        
                                                        
                                                        $objServiceManager = New-Object -ComObject "Microsoft.Update.ServiceManager" 
                                                        $objSession = New-Object -ComObject "Microsoft.Update.Session" 
                                                        $objSearcher = $objSession.CreateUpdateSearcher() 
                                                        Foreach ($objService in $objServiceManager.Services){ 
                                                            if($ServiceID){ 
                                                                if($objService.ServiceID -eq $ServiceID){ 
                                                                    $objSearcher.ServiceID = $ServiceID 
                                                                    $objSearcher.ServerSelection = 3 
                                                                    $serviceName = $objService.Name 
                                                                } 
                                                        }
                                                            else{ 
                                                                if($objService.IsDefaultAUService -eq $True){ 
                                                                    $serviceName = $objService.Name 
                                                                } 
                                                            } 
                                                        } 
                                                        $objCollection = New-Object -ComObject "Microsoft.Update.UpdateColl" 
                                                        $objResults = $objSearcher.Search("IsInstalled=0") 
                                                        $FoundUpdatesToDownload = $objResults.Updates.count 
                                                        if ($objResults.Updates.count -gt 0){ 
                                                            foreach($Update in $objResults.Updates){ 
                                                                if($Update.EulaAccepted -eq 0 ){ 
                                                                    $Update.AcceptEula() 
                                                                } 
                                                                if($Update.isdownloaded -eq 0){ 
                                                                    $objCollectionTmp = New-Object -ComObject "Microsoft.Update.UpdateColl" 
                                                                    $objCollectionTmp.Add($Update) | out-null 
                                                                    $Downloader = $objSession.CreateUpdateDownloader() 
                                                                    $Downloader.Updates = $objCollectionTmp 
                                                                } 
                                                            } 
                                                            $objCollectionTmp = New-Object -ComObject "Microsoft.Update.UpdateColl" 
                                                            foreach($Update in $objResults.Updates){ 
                                                                    $objCollectionTmp.Add($Update) | out-null 
                                                            } 
                                                            $objInstaller = $objSession.CreateUpdateInstaller() 
                                                            $objInstaller.Updates = $objCollectionTmp 
                                                            $InstallResult = $objInstaller.Install() 
                    } 
            } -AsJob -ThrottleLimit $Throttle

    }
Start-Sleep 600
    do{
        $Jobs = Get-Job
        Foreach($Job in $Jobs)
        {
        If($Job.State -eq "Failed")
        {
            Write-Host "$JOb.Location | Status:$JOb.State" -BackgroundColor Red
            $Job | Remove-Job
        }
        if($JOb.State -ne "Running")
        {
            Write-Host "$JOb.Location | Status:$JOb.State" -BackgroundColor Green
            $Job | remove-Job
        }
        }
    }
    until($(get-Job) -eq $Null)

}

Function Restart-WindowsServer{
<#
    .SYNOPSIS
        
        This function will restart the windows computer based on the Input file in Parallel with optional paramaters like sleep time and Throttlelimit

    .EXAMPLE

        PS C:\Windows\system32> Restart-WindowsServer -InputFile "C:\temp\Servers.txt" -OutputFile "C:\Windows\temp\Output.csv"
    .EXAMPLE

        PS C:\Windows\system32> Restart-WindowsServer -InputFile "C:\temp\Servers.txt" -Parallel 25 -Sleep 300

#>

    Param(
        [string]$InputFile,
        [int]$Parallel=10,
        [Int]$Sleep=600,
        [string]$OutputFile="C:\Windows\Temp\Restart_Status_$(Get-date -Format MMddyyyy).csv"
    )
    If(!(Test-Path $InputFile))
    {
        Write-Host "Error : $Inputfile is not found.Hence Aborting.." -BackgroundColor Red
        Continue
    }
    $Servers = Get-Content $InputFile
    Write-Host "Info : Restarting $Servers.Count"
    Write-Host "Info : $Parallel Servers will be rebooted in Parallel"
    Restart-Computer -ComputerName $Servers -AsJob -ThrottleLimit $Parallel -Force -Confirm:$false 
    Write-Host "Info : Performing wait for 10 minutes"
    Start-Sleep $Sleep
    do{
        $Jobs = Get-Job
        Foreach($Job in $Jobs)
        {
        If($Job.State -eq "Failed")
        {
            $Job | Remove-Job
        }
        if($JOb.State -ne "Running")
        {
            $Job | remove-Job
        }
        }
    }
    until($(get-Job) -eq $Null)
    Write-Host "Info : Validating if the serves are back online"
    Foreach($Server in $Servers)
    {
        $Service = $Null
        $Service = Get-Service -ComputerName $Server -Name Spooler -ErrorAction SilentlyContinue
        if($Service.Name -eq "spooler"){
            "$Server,Success" | Export-CSV $OutputFile -Append -NoTypeInformation -Force -Confirm:$false 
        }
        else{
            "$Server,Failed" | Export-CSV $OutputFile -Append -NoTypeInformation -Force -Confirm:$false 
        }
    }

}
  
Export-ModuleMember -Function Get-RunningService
Export-ModuleMember -Function Validate-PatchStatus
Export-ModuleMember -Function Post-PatchValidation
Export-ModuleMember -Function Get-PatchReport
Export-ModuleMember -Function Install-MSWindowsUpdate
Export-ModuleMember -Function Restart-WindowsServer
