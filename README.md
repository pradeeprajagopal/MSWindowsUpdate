# MSWindowsUpdate

Create a Folder named MSWindowsUpdate under C:\Windows\System32\WindowsPowerShell\v1.0\Modules
Place PSM1 and PSD1 File

To Start using Launch Powershell as Administrator and if required execute Set-Executionpolicy Unrestrcted -Force

Import-Module MSWindowsUpdate -DisableNameChecking

PS C:\WINDOWS\system32> get-command -Module MSwindowsupdate

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-RunningService                                 1.0.0.0    MSwindowsupdate
Function        Post-PatchValidation                               1.0.0.0    MSwindowsupdate
Function        Validate-PatchStatus                               1.0.0.0    MSwindowsupdate

PS C:\WINDOWS\system32> Get-Help Validate-PatchStatus -Examples

NAME
    Validate-PatchStatus

SYNOPSIS
    This function will get the Number of Patches missing on the remote server and If there is any reboot pending due
    to patching.


    -------------------------- EXAMPLE 1 --------------------------

    PS C:\Windows\system32>Validate-PatchStatus -File "C:\temp\Servers.txt"

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




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\Windows\system32>Validate-PatchStatus -File "C:\temp\Servers.txt" | Export-Csv C:\Temp\Output.csv

PS C:\WINDOWS\system32> Get-Help Post-PatchValidation -Examples

NAME
    Post-PatchValidation

SYNOPSIS
    This function will help you validate the servers after Patch installation


    -------------------------- EXAMPLE 1 --------------------------

    PS C:\Windows\system32>Post-PatchValidation -File "C:\temp\Servers.txt"

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




    -------------------------- EXAMPLE 2 --------------------------

    PS C:\Windows\system32>Post-PatchValidation -File "C:\temp\Servers.txt" | Export-Csv C:\Temp\Output.csv

PS C:\WINDOWS\system32> Get-Help Get-RunningService -Examples

NAME
    Get-RunningService

SYNOPSIS
    This function will get the list of service running on a remote computer using the input file. The outut will be
    stored in C:\Windows\Temp\PrePatch_Service.txt


    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Get-RunningService -File "C:\temp\Servicetest.txt"

    Info : Fetching Service status from 5 Servers
    Info : Providing Sufficent time for the execution

    Status :Total:5 | Success:5 | Failure:0


