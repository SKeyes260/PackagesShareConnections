
Function Get-DistributionPoints() {
[CmdletBinding()]   
PARAM 
(   [Parameter(Position=1)] $SiteServer,
    [Parameter(Position=2)] $SiteCode )

    $objDPs = Get-WMIObject -ComputerName $SiteServer -NameSpace "Root\SMS\Site_$SiteCode"  -Query "SELECT * FROM SMS_DistributionPointInfo"
    Return $objDPs
}


Function Get-ServerConnections() {
[CmdletBinding()]   
PARAM 
(   [Parameter(Position=1)] $ServerName )

    If ( $ServerName ) {
        $UserConnections = Get-WmiObject -Computer $ServerName  -namespace "root\CIMV2" -Query "SELECT * FROM Win32_ServerConnection  WHERE ShareName = 'Packages$'" -ErrorAction SilentlyContinue
    }
    Return $UserConnections
}


Function Get-ServerSessions() {
[CmdletBinding()]   
PARAM 
(   [Parameter(Position=1)] $ServerName,
    [Parameter(Position=2)] $UserName,
    [Parameter(Position=3)] $ComputerName)

    If ( $ServerName ) {
        $UserSessions = Get-WmiObject -Computer $ServerName  -namespace "root\CIMV2" -Query "SELECT * FROM Win32_ServerSessions  WHERE UserName = '$UserName' and ComputerName = '$ComputerName'" -ErrorAction SilentlyContinue
    }
    Return $UserSessions
}

##################################
# MAIN
##################################

$SiteServer = "RESSWCMSPRIP01"
$SiteCode = "EC0"

$DPs = Get-DistributionPoints -SiteServer $SiteServer  -SiteCode $SiteCode

Write-Host "ServerName       ShareName    UserName         ComputerName         ActiveTime       OpenFiles"

ForEach ( $DP in $DPs ) {
    $Connections = Get-ServerConnections -ServerName $DP.ServerName 
    
    if ($Connections -ne $null)  {
        foreach ($Connection in $Connections) { 
            If ( $Connection.UserName.Substring($Connection.UserName.Length-1, 1) -ne "$") {
                $Session = Get-ServerSessions -ServerName $DP.ServerName -UserName $Connection.UserName  -ComputerName $Connection.ComputerName
                Write-Host $DP.ServerName.PadRight(16) $Connection.ShareName.PadRight(12) $Connection.UserName.PadRight(16) $Connection.ComputerName.PadRight(20) $Connection.ActiveTime.ToString().PadRight(16) $Connection.NumberOfFiles  
            }  
        }  
    }
}

READ-Host