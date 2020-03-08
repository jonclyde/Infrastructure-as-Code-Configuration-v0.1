Configuration Template {
   
    # Template DSC Resources
    Import-DscResource -ModuleName 'PsDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'xDSCDomainJoin'

    #Specific DSC resources


    #Template variables
    $DomainAdminCredential = Get-AutomationPSCredential -Name 'domainCredential'
    $SafeModePassword = Get-AutomationPSCredential -Name 'safeModeCredential'
    $DomainName = Get-AutomationVariable -Name 'DomainName'

    #Specific variables
    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {
        
        <#
            Section 1 - Specific configuration
        #>
            
        <#
            Section 2 - Template configuration
        #>
        
        #
        #   Domain Join
        #
        xDSCDomainjoin JoinDomain
        {
            Domain = $Domain 
            Credential = $domainCredential
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