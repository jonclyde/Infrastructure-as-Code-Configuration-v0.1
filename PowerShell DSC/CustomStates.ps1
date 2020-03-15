Configuration CustomStates {
    
    Import-DscResource -ModuleName 'PsDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'xDSCDomainJoin'
    Import-DscResource -ModuleName 'xStorage'
    Import-DscResource -ModuleName 'SqlServerDsc'
    Import-DscResource -ModuleName 'xActiveDirectory'

    $DomainAdminCredential = Get-AutomationPSCredential -Name 'domainCredential'
    $DomainJoinCredential = Get-AutomationPSCredential -Name 'domainJoinCredential'
    $SafeModePassword = Get-AutomationPSCredential -Name 'safeModeCredential'
    $DomainName = Get-AutomationVariable -Name 'DomainName'
    

    # Configuration
    Node $AllNodes.Where{$_.Elements -contains "FirstDC"}.NodeName
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

    Node $AllNodes.Where{$_.Elements -contains "OtherDC"}.NodeName
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

    Node $AllNodes.Where{$_.Elements -contains "MSSQL"}.NodeName
    {
        SqlServerMemory 'Set_SQLServerMaxMemory'
        {
            Ensure               = 'Present'
            DynamicAlloc         = $false
            MinMemory            = $minmem
            MaxMemory            = $maxmem
            ServerName           = 'localhost'
            InstanceName         = 'MSSQLSERVER'
        }
    }

    Node $AllNodes.Where{$_.Elements -eq "Management"}.NodeName
    {
        WindowsFeature RSATTools 
            { 
                Ensure = 'Present'
                Name = 'RSAT-AD-Tools'
                IncludeAllSubFeature = $true
            }
    }

    Node $AllNodes.Where{$_.Elements -eq "IIS"}.NodeName
    {
        WindowsFeature WebServer {
            Ensure = "Present"
            Name =  "Web-Server"
        }
    }

    Node $AllNodes.Where{$_.Elements -eq "DomainJoin"}.NodeName
    {
        xDSCDomainjoin JoinDomain
        {
            Domain = $DomainName
            Credential = $domainjoinCredential
        }
    }
}