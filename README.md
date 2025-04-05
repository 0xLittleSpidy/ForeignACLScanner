# ForeignACLScanner

## Description
A PowerShell tool to enumerate Foreign ACLs in an Active Directory forest where external security principals from another forest/domain have excessive permissions. Designed for red teams and penetration testers auditing cross-forest trust relationships.

## Features
- Dynamic resolution of current/foreign domain SIDs
- Color-coded console output (highlights dangerous permissions)
- Progress bar for long enumeration tasks
- CSV export capability
- Debug mode with verbose LDAP query diagnostics
- Optimized pipeline processing for performance

## Installation
1. Download the script:
   ```powershell
   Invoke-WebRequest -Uri https://raw.githubusercontent.com/0xLittleSpidy/ForeignACLScanner/refs/heads/master/Invoke-ForeignACLScanner.ps1 -OutFile Invoke-ForeignACLScanner.ps1
   ```
2. Import into your PowerShell session:
   ```powershell
   . .\Invoke-ForeignACLScanner.ps1
   ```

**Prerequisites**:
- PowerShell 5.1+
- ActiveDirectory PowerShell module
- Domain-joined machine with AD WS management access

## Usage

### Basic Scan
```powershell
Invoke-ForeignACLScanner -ForestDomain external.com
```

### Debug Mode
```powershell
Invoke-ForeignACLScanner -f external.com -d
```

### Save Results to File
```powershell
Invoke-ForeignACLScanner -f external.com -o results.csv
```

## Parameters

| Parameter       | Alias | Description                                      |
|-----------------|-------|--------------------------------------------------|
| -ForestDomain   | -f    | Target foreign domain/forest name (FQDN)         |
| -OutputFile     | -o    | Output file path (CSV format)                    |
| -DebugMode      | -d    | Enable verbose debug output                      |
| -Help           | -h    | Show help message                                |

## Output Handling

**Default Behavior**:
- Colors dangerous permissions (GenericAll/WriteDacl) in red
- Displays results in tabular format

**File Output**:
- CSV format with columns:
  - ObjectDN
  - ForeignPrincipal
  - Permission
  - ObjectType
- No color formatting

**Sample Output**:
```
IdentityReference           ActiveDirectoryRights  ObjectType                
-----------------           ---------------------  -----------                
EXTERNAL\PentestGroup       GenericAll             user                       
S-1-5-21-...-1107           WriteProperty          groupManagedServiceAccount
```

## Troubleshooting

**Common Errors**:
1. `Missing ActiveDirectory module`:
   ```powershell
   Add-WindowsFeature RSAT-AD-PowerShell
   ```
2. `Access denied`:
   - Run as Domain Admin
   - Check network connectivity to Domain Controller
3. `Foreign SID resolution failed`:
   - Verify DNS resolution of target forest
   - Confirm trust relationship exists

**Debug Tips**:
- Use `-d` flag to see raw LDAP queries
- Check event logs on Domain Controller for access errors
- Test with known foreign principal first


## Contributing
Contributions are welcome! If you'd like to contribute to this project, please follow these steps:
1. Fork the repository.
2. Create a new branch for your feature or bugfix.
3. Commit your changes.
4. Submit a pull request.

---

# **Ethical Use Only**  

This tool is intended for **legal and authorized security assessments only**. By using this software, you agree to comply with all applicable laws and regulations.  

## **Legal Disclaimer**  
The developers of this tool are **not responsible** for any misuse or illegal activities conducted with it.

**Use responsibly and ethically.** Always obtain **written permission** before scanning third-party systems.  

---  
*By using this tool, you acknowledge that you understand and agree to these terms.*
