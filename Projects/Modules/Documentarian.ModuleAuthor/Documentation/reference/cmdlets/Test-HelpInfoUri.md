---
external help file: Documentarian.ModuleAuthor-help.xml
Locale: en-US
Module Name: Documentarian.ModuleAuthor
ms.date: 04/21/2023
online version: https://microsoft.github.io/Documentarian/modules/moduleauthor/reference/cmdlets/test-helpinfouri
schema: 2.0.0
---
# Test-HelpInfoUri

## SYNOPSIS
Checks for the existence of the help info XML file used to update help for a module.

## SYNTAX

### ByName (Default)

```
Test-HelpInfoUri [-Module] <String[]> [-OutPath <String>] [<CommonParameters>]
```

### ByObject

```
Test-HelpInfoUri [-InputObject <Object>] [-OutPath <String>] [<CommonParameters>]
```

## DESCRIPTION

To support updateable help, a module must have a `*_HelpInfo.xml` file published to a web server
and the module manifest must have a **HelpInfoUri** property that points to the location of the
file. This cmdlet attempts to download the `*_HelpInfo.xml` file for a module.

This is useful to test that your module has a valid **HelpInfoUri** and that the `*_HelpInfo.xml`
file was published properly.

The module being tested must be installed on your system but it doesn't need to be loaded in the
current session. If you have multiple versions of the module installed, the cmdlet only tests the
newest version.

## EXAMPLES

### Example 1 - Test a module by name

```powershell
Test-HelpInfoUri -Module Documentarian, PSReadLine
```

```Output
Module        Code Message
------        ---- -------
Documentarian 5007 HelpInfoUri is null or empty
PSReadLine     200 HelpInfoUri is valid
```

### Example 2 - Test a group modules from the pipeline

```powershell
Get-Module | Test-HelpInfoUri
```

```Output
Module                      Code Message
------                      ---- -------
CompletionPredictor         5007 HelpInfoUri is null or empty
Documentarian               5007 HelpInfoUri is null or empty
Documentarian.MicrosoftDocs 5007 HelpInfoUri is null or empty
Documentarian.ModuleAuthor  5007 HelpInfoUri is null or empty
Documentarian.Vale          5007 HelpInfoUri is null or empty
Load-Assemblies                2 Module not found
Microsoft.PowerShell.Manag…  200 HelpInfoUri is valid
Microsoft.PowerShell.Secur…  200 HelpInfoUri is valid
Microsoft.PowerShell.Utili…  200 HelpInfoUri is valid
Microsoft.WSMan.Management   200 HelpInfoUri is valid
posh-git                    5007 HelpInfoUri is null or empty
powershell-yaml             5007 HelpInfoUri is null or empty
PowerShellEditorServices.C…    2 Module not found
PowerShellEditorServices.V… 5007 HelpInfoUri is null or empty
PsIni                       5007 HelpInfoUri is null or empty
PSReadLine                   200 HelpInfoUri is valid
```

### Example 3 - Test a module by command name

The following tests the **HelpInfoUri** for the module that contains the `Get-FileHash` cmdlet.

```powershell
Get-Command Get-FileHash | Test-HelpInfoUri
```

```Output
Module                       Code Message
------                       ---- -------
Microsoft.PowerShell.Utility  200 HelpInfoUri is valid
```

### Example 4 - Test a module and download the `*_HelpInfo.xml` file

```powershell
Test-HelpInfoUri -Module Documentarian, PSReadLine -OutPath C:\Temp
Get-ChildItem C:\Temp\*_HelpInfo.xml
```

```Output
Module        Code Message
------        ---- -------
Documentarian 5007 HelpInfoUri is null or empty
PSReadLine     200 HelpInfoUri is valid

    Directory: C:\Temp

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---           4/21/2023  7:10 PM            378 PSReadLine_5714753b-2afd-4492-a5fd-01d9e2cff8b5_HelpInfo.xml
```

## PARAMETERS

### -InputObject

This parameter is used to pipe objects to the cmdlet. The objects can be module names (strings),
**PSModuleInfo** objects, or **PSCommandInfo** objects.

```yaml
Type: System.Object
Parameter Sets: ByObject
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Module

One or more module names to be tested.

```yaml
Type: System.String[]
Parameter Sets: ByName
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutPath

The location where you want to the `*_HelpInfo.xml` file to be downloaded.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
