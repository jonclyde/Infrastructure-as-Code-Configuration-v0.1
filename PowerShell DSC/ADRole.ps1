Configuration ADRole {

    # Import the module that contains the resources we're using.
    Import-DscResource -ModuleName PsDesiredStateConfiguration

    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {

        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        WindowsFeature RSATTools 
        { 
            Ensure = 'Present'
            Name = 'RSAT-AD-Tools'
            IncludeAllSubFeature = $true
        }
	WindowsFeature DNSFeature
        { 
            Ensure = 'Present'
            Name = 'DNS'
            IncludeAllSubFeature = $true
        }
	WindowsFeature ADDSFeature
        { 
            Ensure = 'Present'
            Name = 'AD-Domain-Services'
            IncludeAllSubFeature = $true
        }
    }
} 