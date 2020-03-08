Configuration Management {
    
    # Template DSC Resources
    Import-DscResource -ModuleName 'PsDesiredStateConfiguration'
    Import-DscResource -ModuleName 'ComputerManagementDsc'
    Import-DscResource -ModuleName 'xDSCDomainJoin'

    #Specific DSC resources


    #Template variables
    $DomainJoinCredential = Get-AutomationPSCredential -Name 'domainJoinCredential'
    $SafeModePassword = Get-AutomationPSCredential -Name 'safeModeCredential'
    $DomainName = Get-AutomationVariable -Name 'DomainName'

    #Specific variables
    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {
        
        <#
            Section 1 - Specific configuration
        #>
            WindowsFeature RSATTools 
            { 
                Ensure = 'Present'
                Name = 'RSAT-AD-Tools'
                IncludeAllSubFeature = $true
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
}
}