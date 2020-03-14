Configuration WebServerRole {

     # Template DSC Resources
     Import-DscResource -ModuleName 'PsDesiredStateConfiguration'
     Import-DscResource -ModuleName 'ComputerManagementDsc'
     Import-DscResource -ModuleName 'xDSCDomainJoin'
 
     #Specific DSC resources
 
 
     #Template variables
     $DomainJoinCredential = Get-AutomationPSCredential -Name 'domainJoinCredential'
     $DomainName = Get-AutomationVariable -Name 'DomainName'

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {

        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        WindowsFeature WebServer {
            Ensure = "Present"
            Name =  "Web-Server"
        }
        #
        #   Domain Join
        #
        xDSCDomainjoin JoinDomain
        {
            Domain = $DomainName
            Credential = $domainjoinCredential
        }
    }
} 