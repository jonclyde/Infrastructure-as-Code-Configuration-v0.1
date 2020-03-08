Configuration ServerConfiguration {
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullorEmpty()]
        [System.Management.Automation.PSCredential]
        $DomainAdminCredential,
        [Parameter(Mandatory = $true)]
        $JoinOUDN,
        [Parameter(Mandatory = $true)]
        $TimezoneId
    )

    # Import the module that contains the resources we're using.
    Import-DscResource -ModuleName PsDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    <#
        Section 2 - Templated changes
    #>
    # The Node statement specifies which targets this configuration will be applied to.
    Node 'localhost' {

        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        Computer JoinDomain
        {
            Name       = 'Server01'
            DomainName = 'Contoso'
            Credential = $DomainAdminCredential # Credential to join to domain
            JoinOU     = $JoinOUDN
        }
        
        PendingReboot RebootAfterDomainJoin
        {
            Name = 'DomainJoin'
        }

        #get-timezone -ListAvailable | select id - for timezone name
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
} 