configuration OtherDomainController
{
    # Import the modules needed to run the DSC script
    Import-DscResource -ModuleName 'xActiveDirectory'
    Import-DscResource -ModuleName 'xStorage'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'xDSCDomainJoin'
 
    # When using with Azure Automation, modify these values to match your stored credential names
    $DomainJoinCredential = Get-AutomationPSCredential -Name 'domainJoinCredential'
    $DomainCredential = Get-AutomationPSCredential -Name 'domainCredential'
    $SafeModePassword = Get-AutomationPSCredential -Name 'safeModeCredential'
    $DomainName = Get-AutomationVariable -Name 'DomainName'
 
    # Configuration
    node localhost
    {
        WindowsFeature ADDSInstall
        {
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
        }
        
        WindowsFeature RSATTools 
        { 
            Ensure = 'Present'
            Name = 'RSAT-AD-Tools'
            IncludeAllSubFeature = $true
        }

        xWaitforDisk Disk3
        {
            DiskId = 3
            RetryIntervalSec = 10
            RetryCount = 30
        }
 
        xDisk DiskF
        {
            DiskId = 3
            DriveLetter = 'F'
            DependsOn = '[xWaitforDisk]Disk3'
            FSLabel = 'Domain'
        }
        xDSCDomainjoin JoinDomain
        {
            Domain = $DomainName 
            Credential = $domainJoinCredential
        }
        <#PendingReboot AfterDomainJoin
        {
            Name = 'AfterDomainJoin'
            SkipCcmClientSDK = $true
            DependsOn = '[WindowsFeature]ADDSInstall','[xDisk]DiskF','[Computer]JoinDomain'
        }#>
        xWaitForADDomain 'DscForestWait'
        {
            DomainName           = $DomainName
            DomainUserCredential = $domainJoinCredential
            RetryCount           = 10
            RetryIntervalSec     = 30
            DependsOn            = '[WindowsFeature]ADDSInstall'
        }
 
        xADDomain Domain
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCredential
            SafemodeAdministratorPassword = $SafeModePassword
            DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = '[WindowsFeature]ADDSInstall','[xDisk]DiskF','[xWaitForADDomain]DscForestWait'
            #'[PendingReboot]AfterDomainJoin'
        }
        
        Registry DisableRDPNLA
        {
            Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
            ValueName = 'UserAuthentication'
            ValueData = 0
            ValueType = 'Dword'
            Ensure = 'Present'
            DependsOn = '[xADDomain]Domain'
        }
    }
}