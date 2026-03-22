param(
    [string]$UvprojPath = "Elevator_stm32.uvprojx",
    [string]$CprojectPath = "Elevator_stm32.cproject.yml"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $UvprojPath)) {
    throw "Keil project file not found: $UvprojPath"
}

if (-not (Test-Path -LiteralPath $CprojectPath)) {
    throw "CMSIS project file not found: $CprojectPath"
}

$xml = New-Object System.Xml.XmlDocument
$xml.PreserveWhitespace = $true
$xml.Load((Resolve-Path -LiteralPath $UvprojPath))

$groupNodes = @($xml.SelectNodes('/Project/Targets/Target/Groups/Group'))
if ($groupNodes.Count -eq 0) {
    throw "No groups found in Keil project"
}

$groups = New-Object System.Collections.Generic.List[object]
foreach ($groupNode in $groupNodes) {
    $nameNode = $groupNode.SelectSingleNode('GroupName')
    if ($null -eq $nameNode) {
        continue
    }

    $groupName = $nameNode.InnerText
    if ([string]::IsNullOrWhiteSpace($groupName)) {
        continue
    }

    # Keep CMSIS cproject groups clean: skip Keil virtual/system groups.
    if ($groupName.StartsWith('::')) {
        continue
    }

    $fileNodes = @($groupNode.SelectNodes('Files/File'))
    $files = New-Object System.Collections.Generic.List[string]
    foreach ($fileNode in $fileNodes) {
        $filePathNode = $fileNode.SelectSingleNode('FilePath')
        $fileNameNode = $fileNode.SelectSingleNode('FileName')

        if ($null -ne $filePathNode -and -not [string]::IsNullOrWhiteSpace($filePathNode.InnerText)) {
            $candidate = $filePathNode.InnerText.Trim()
            $candidate = $candidate -replace '^\.\\', ''
            $candidate = $candidate -replace '/', '\\'
            $candidate = $candidate -replace '\\', '/'
            $files.Add($candidate)
            continue
        }

        if ($null -ne $fileNameNode -and -not [string]::IsNullOrWhiteSpace($fileNameNode.InnerText)) {
            $files.Add($fileNameNode.InnerText.Trim())
        }
    }

    $groups.Add([PSCustomObject]@{
        Name = $groupName
        Files = @($files)
    })
}

if ($groups.Count -eq 0) {
    throw "No user groups found in Keil project"
}

$content = Get-Content -LiteralPath $CprojectPath -Raw

$groupLines = New-Object System.Collections.Generic.List[string]
$groupLines.Add('  groups:')
foreach ($group in $groups) {
    $groupLines.Add("    - group: $($group.Name)")
    $groupLines.Add('      files:')
    foreach ($file in $group.Files) {
        $groupLines.Add("        - file: $file")
    }
}
$newGroupsBlock = ($groupLines -join "`r`n") + "`r`n"

$groupsPattern = '(?ms)^\s{2}groups:\s*\r?\n.*?(?=^\s{2}[A-Za-z][^\r\n]*:|\z)'
if ([Regex]::IsMatch($content, $groupsPattern)) {
    $updated = [Regex]::Replace($content, $groupsPattern, $newGroupsBlock, 1)
} else {
    throw "Could not find groups section in $CprojectPath"
}

[System.IO.File]::WriteAllText((Resolve-Path -LiteralPath $CprojectPath), $updated, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Synced $($groups.Count) group(s) from Keil to CMSIS:"
foreach ($group in $groups) {
    Write-Host " - $($group.Name): $($group.Files.Count) file(s)"
}
