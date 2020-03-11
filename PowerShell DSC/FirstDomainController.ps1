configuration FirstDomainController
{
    # Import the modules needed to run the DSC script
    Import-DscResource -ModuleName 'xActiveDirectory'
    Import-DscResource -ModuleName 'xStorage'
    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
 
    # When using with Azure Automation, modify these values to match your stored credential names
    $DomainAdminCredential = Get-AutomationPSCredential -Name 'domainCredential'
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
        PendingReboot RebootBeforeDC
        {
            Name = 'RebootBeforeDC'
            SkipCcmClientSDK = $true
            DependsOn = '[WindowsFeature]ADDSInstall','[xDisk]DiskF'
        }
        
        xADDomain Domain
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainAdminCredential
            SafemodeAdministratorPassword = $SafeModePassword
            DatabasePath = 'F:\NTDS'
            LogPath = 'F:\NTDS'
            SysvolPath = 'F:\SYSVOL'
            DependsOn = '[WindowsFeature]ADDSInstall','[xDisk]DiskF','[PendingReboot]RebootBeforeDC'
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