# MSWindowsUpdate

This Module will help in Auditing Patches across Windows Environment and Validating the Services before and After Patch Reboot.

Create a Folder named MSWindowsUpdate under C:\Windows\System32\WindowsPowerShell\v1.0\Modules
Place PSM1 and PSD1 File

To Start using Launch Powershell as Administrator and if required execute 
(Optional)
Set-Executionpolicy Unrestrcted -Force

(Mandatory)
Import-Module MSWindowsUpdate -DisableNameChecking

PS C:\WINDOWS\system32> get-command -Module MSwindowsupdate

CommandType     Name                                               Version    Source
-----------     ----                                               -------    ------
Function        Get-RunningService                                 1.0.0.0    MSwindowsupdate
Function        Post-PatchValidation                               1.0.0.0    MSwindowsupdate
Function        Validate-PatchStatus                               1.0.0.0    MSwindowsupdate

PS C:\WINDOWS\system32> Get-Help Validate-PatchStatus -Full

NAME
    Validate-PatchStatus

SYNOPSIS
    This function will get the Number of Patches missing on the remote server and If there is any reboot pending due
    to patching.


SYNTAX
    Validate-PatchStatus [-File] <String> [<CommonParameters>]


DESCRIPTION


PARAMETERS
    -File <String>
        Specify the File Path Containing Server List

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

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


PS C:\WINDOWS\system32> Get-Help Post-PatchValidation -Full

NAME
    Post-PatchValidation

SYNOPSIS
    This function will help you validate the servers after Patch installation


SYNTAX
    Post-PatchValidation [-File] <String> [<CommonParameters>]


DESCRIPTION


PARAMETERS
    -File <String>
        Specify the File Path Containing Server List

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

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


PS C:\WINDOWS\system32> Get-Help Get-RunningService -Full

NAME
    Get-RunningService

SYNOPSIS
    This function will get the list of service running on a remote computer using the input file. The outut will be
    stored in C:\Windows\Temp\PrePatch_Service.txt


SYNTAX
    Get-RunningService [-File] <String> [<CommonParameters>]


DESCRIPTION


PARAMETERS
    -File <String>
        Specify the File Path Containing Server List

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>Get-RunningService -File "C:\temp\Servicetest.txt"

    Info : Fetching Service status from 5 Servers
    Info : Providing Sufficent time for the execution

    Status :Total:5 | Success:5 | Failure:0

PS C:\WINDOWS\system32> Get-Help Restart-WindowsServer -Full

NAME
    Restart-WindowsServer

SYNOPSIS
    This function will restart the windows computer based on the Input file in Parallel with optional paramaters like sleep time and Throttlelimit


SYNTAX
    Restart-WindowsServer [[-InputFile] <String>] [[-Parallel] <Int32>] [[-Sleep] <Int32>] [[-OutputFile] <String>] [<CommonParameters>]


DESCRIPTION


PARAMETERS
    -InputFile <String>

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Parallel <Int32>

        Required?                    false
        Position?                    2
        Default value                10
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Sleep <Int32>

        Required?                    false
        Position?                    3
        Default value                600
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -OutputFile <String>

        Required?                    false
        Position?                    4
        Default value                "C:\Windows\Temp\Restart_Status_$(Get-date -Format MMddyyyy).csv"
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\Windows\system32>Restart-WindowsServer -InputFile "C:\temp\Servers.txt" -OutputFile "C:\Windows\temp\Output.csv"

    -------------------------- EXAMPLE 2 --------------------------

    PS C:\Windows\system32>Restart-WindowsServer -InputFile "C:\temp\Servers.txt" -Parallel 25 -Sleep 300


PS C:\WINDOWS\system32> Get-Help Get-PatchReport -Full

NAME
    Get-PatchReport

SYNOPSIS
    This function will help you get the Patch Report from the Input file and Exports the content to output file


SYNTAX
    Get-PatchReport [[-InputFile] <String>] [[-OutputFile] <String>] [<CommonParameters>]


DESCRIPTION


PARAMETERS
    -InputFile <String>

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -OutputFile <String>

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\Windows\system32>Get-PatchReport -InputFile "C:\temp\Servers.txt" -OutputFile "C:\Windows\temp\Output.csv"
    

PS C:\WINDOWS\system32> Get-Help Install-MSWindowsUpdate -Full

NAME
    Install-MSWindowsUpdate

SYNOPSIS
    This function will install the patches on servers based on input file. This will install all missing patches


SYNTAX
    Install-MSWindowsUpdate [[-Inputfile] <String>] [[-Throttle] <Int32>] [<CommonParameters>]


DESCRIPTION


PARAMETERS
    -Inputfile <String>

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

    -Throttle <Int32>

        Required?                    false
        Position?                    2
        Default value                10
        Accept pipeline input?       false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https:/go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\Windows\system32>Install-MSWindowsUpdate -InputFile "C:\temp\Servers.txt"
