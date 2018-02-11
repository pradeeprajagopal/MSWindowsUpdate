
########################################################################
# Module : MS Windows Update
# Author : Pradeep Rajagopal
# Version: 1.0.0.0
# Version History : 1.0.0.0
#                  : Three Commandlets Get-RunningService
#                                      Validate-PatchStatus
#                                      Post-PatchValidation
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
    Invoke-Command -ComputerName $Server -ScriptBlock {Get-Service | where {($_.Status -eq "Running") -and ($_.Starttype -ne "Disabled")} | Select Name | Export-csv C:\Windows\Temp\PrePatch_Service.Csv -NoTypeInformation} -AsJob -ThrottleLimit 50 | Out-Null
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

$Servers = GC $File 

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

$Servers = GC $File 

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

                                                    Get-Service | where {($_.Status -eq "Running") -and ($_.Starttype -ne "Disabled")} | Select Name | export-csv C:\Windows\Temp\PostPatch_Service.Csv -NoTypeInformation

                                                    $Pre_Services = gc C:\Windows\Temp\PrePatch_Service.Csv

                                                    $Post_Services = gc C:\Windows\Temp\PostPatch_Service.Csv

                                                    $Differences = Compare-Object -ReferenceObject $Pre_Services -DifferenceObject $Post_Services | where {$_.Sideindicator -eq "<="}

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

  }

export-modulemember -function Get-RunningService
export-modulemember -function Validate-PatchStatus
export-modulemember -function Post-PatchValidation
