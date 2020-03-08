Configuration SQLVM {
   
    # Template DSC Resources
    Import-DscResource -ModuleName 'PsDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'xDSCDomainJoin'
    Import-DscResource -ModuleName 'SqlServerDsc'

    #Specific DSC resources


    #Template variables
    $DomainJoinCredential = Get-AutomationPSCredential -Name 'domainJoinCredential'
    $SafeModePassword = Get-AutomationPSCredential -Name 'safeModeCredential'
    $DomainName = Get-AutomationVariable -Name 'DomainName'

    #Specific variables
    $minmem = 0
    $maxmem = "4444"
    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {
        
        <#
            Section 1 - Specific configuration
        #>
        SqlServerMemory 'Set_SQLServerMaxMemory'
        {
            Ensure               = 'Present'
            DynamicAlloc         = $false
            MinMemory            = $minmem
            MaxMemory            = $maxmem
            ServerName           = 'localhost'
            InstanceName         = 'MSSQLSERVER'
        }
            
        <#
            Section 2 - Template configuration
        #>
        
        #
        #   Domain Join
        #
        xDSCDomainjoin JoinDomain
        {
            Domain = $DomainName
            Credential = $domainJoinCredential
        }
        <#
        Computer JoinDomain
        {
            Name       = $hostname
            DomainName = $DomainName
            Credential = $domainCredential # Credential to join to domain
        }
        
        PendingReboot RebootAfterDomainJoin
        {
            Name = 'DomainJoin'
        }
#>
        <#get-timezone -ListAvailable | select id - for timezone name
        TimeZone TimeZoneSet
        {
            IsSingleInstance = 'Yes'
            TimeZone         = $TimezoneId
        }

        WindowsEventLog Enable-DscAnalytic
        {
            LogName             = 'Microsoft-Windows-Dsc/Analytic'
            IsEnabled           = $True
            LogMode             = 'Retain'
            MaximumSizeInBytes  = 4096kb
            LogFilePath         = "%SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-DSC%4Analytic.evtx"
        }
        #>
}
}