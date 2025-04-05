<#
.SYNOPSIS
Enumerates Foreign ACLs in the current forest for users/groups from another forest.

.DESCRIPTION
This tool identifies excessive permissions granted to foreign security principals from another forest/domain.

.PARAMETER ForestDomain
Specify the foreign forest/domain name to filter ACLs for its SID.

.PARAMETER OutputFile
Save results to a file (no color formatting).

.PARAMETER DebugMode
Enable verbose debugging output (skips status bar).

.PARAMETER Help
Show this help menu.

.EXAMPLE
PS> Invoke-ForeignACLScanner -ForestDomain external.com

.EXAMPLE
PS> Invoke-ForeignACLScanner -d -o results.txt
#>

param(
    [Parameter(Mandatory=$false)]
    [Alias('f')]
    [string]$ForestDomain,

    [Parameter(Mandatory=$false)]
    [Alias('o')]
    [string]$OutputFile,

    [Parameter(Mandatory=$false)]
    [Alias('d')]
    [switch]$DebugMode,

    [Parameter(Mandatory=$false)]
    [Alias('h')]
    [switch]$Help
)

# Help Menu
if ($Help) {
    Write-Host @"
    
Invoke-ForeignACLScanner - AD Foreign ACL Enumeration Tool

Options:
    -h, --help            Show this help message
    -f, --forest          Foreign forest/domain name to filter
    -o, --output          Output file path (no color)
    -d, --debug           Enable debug output (verbose)

"@
    exit
}

# Debug Handling
if ($DebugMode) {
    $DebugPreference = 'Continue'
    Write-Debug "[DEBUG] Debug mode enabled"
} else {
    $progressParams = @{
        Activity = "Scanning ACLs"
        Status = "Initializing..."
        PercentComplete = 0
    }
    Write-Progress @progressParams
}

# Main Logic
try {
    # Get Current Domain Info
    $currentDomain = (Get-ADDomain).DNSRoot
    $currentSid = (Get-ADDomain).DomainSID.Value
    Write-Debug "[DEBUG] Current Domain: $currentDomain | SID: $currentSid"

    # Get Foreign SID if specified
    if ($ForestDomain) {
        $foreignSid = (Get-ADDomain -Server $ForestDomain).DomainSID.Value
        Write-Debug "[DEBUG] Foreign Domain: $ForestDomain | SID: $foreignSid"
    }

    # Retrieve ACLs
    $acls = Get-ADObject -LDAPFilter "(objectClass=*)" -Properties nTSecurityDescriptor |
        Select-Object -ExpandProperty nTSecurityDescriptor |
        Select-Object -ExpandProperty Access

    # Progress Counter
    $total = $acls.Count
    $processed = 0

    # Filter ACLs
    $results = $acls | ForEach-Object {
        $processed++
        if (-not $DebugMode) {
            $percent = ($processed / $total) * 100
            Write-Progress @progressParams -Status "Checked $processed/$total" -PercentComplete $percent
        }

        # Permission Filter
        $rights = $_.ActiveDirectoryRights -match 'WriteProperty|GenericAll|GenericWrite|WriteDacl|WriteOwner'
        $type = $_.AccessControlType -eq 'Allow'
        $sid = $_.SecurityIdentifier.Value

        # SID Filter
        $validSid = $sid -match '^S-1-5-.*-[1-9]\d{3,}$'
        if ($ForestDomain) {
            $foreignMatch = $sid -like "$foreignSid*"
        } else {
            $foreignMatch = $sid -notlike "$currentSid*"
        }

        if ($rights -and $type -and $validSid -and $foreignMatch) {
            $_
        }
    }

    # Output Handling
    if ($OutputFile) {
        $results | Export-Csv -Path $OutputFile -NoTypeInformation
        Write-Host "[+] Results saved to: $OutputFile" -ForegroundColor Green
    } else {
        $results | Format-Table IdentityReference, ActiveDirectoryRights, ObjectType -AutoSize -Wrap |
            Out-String -Width 4096 |
            ForEach-Object { $_ -replace '(.+)(Allow\s+)(.+)', "`$1`e[32m`$2`e[0m`$3" }
    }
} catch {
    Write-Error "[!] Error: $_"
} finally {
    if (-not $DebugMode) { Write-Progress -Activity "Completed" -Completed }
}
