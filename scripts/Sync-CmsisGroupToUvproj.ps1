param(
    [string]$CprojectPath = "Elevator_stm32.cproject.yml",
    [string]$UvprojPath = "Elevator_stm32.uvprojx",
    [string]$GroupName = ""
)

$ErrorActionPreference = "Stop"

function Get-CmsisGroups {
    param(
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "CMSIS project file not found: $Path"
    }

    $content = Get-Content -LiteralPath $Path -Raw
    $groupPattern = "(?ms)^\s{4}-\s+group:\s*(?<name>.+?)\s*$\r?\n(?<block>.*?)(?=^\s{4}-\s+group:|^\s{2}[A-Za-z][^\r\n]*:|\z)"
    $groupMatches = [Regex]::Matches($content, $groupPattern)

    if ($groupMatches.Count -eq 0) {
        throw "No CMSIS groups found in $Path"
    }

    $groups = New-Object System.Collections.Generic.List[object]
    foreach ($gm in $groupMatches) {
        $name = $gm.Groups["name"].Value.Trim().Trim('"').Trim("'")
        $block = $gm.Groups["block"].Value
        $fileMatches = [Regex]::Matches($block, "(?m)^\s{8}-\s+file:\s*(?<file>.+?)\s*$")

        $files = New-Object System.Collections.Generic.List[string]
        foreach ($m in $fileMatches) {
            $rawFile = $m.Groups["file"].Value.Trim()
            $cleanFile = $rawFile.Trim('"').Trim("'")
            if ($cleanFile.Length -gt 0) {
                $files.Add($cleanFile)
            }
        }

        $groups.Add([PSCustomObject]@{
            Name = $name
            Files = $files
        })
    }

    return @($groups.ToArray())
}

function Sync-UvprojGroup {
    param(
        [xml]$Xml,
        [string]$TargetGroupName,
        [string[]]$Files
    )

    $groupNode = $Xml.SelectSingleNode("/Project/Targets/Target/Groups/Group[GroupName=`"$TargetGroupName`"]")
    if ($null -eq $groupNode) {
        $groupsNode = $Xml.SelectSingleNode("/Project/Targets/Target/Groups")
        if ($null -eq $groupsNode) {
            throw "Keil project has no <Groups> section"
        }

        $groupNode = $Xml.CreateElement("Group")

        $groupNameNode = $Xml.CreateElement("GroupName")
        $groupNameNode.InnerText = $TargetGroupName
        [void]$groupNode.AppendChild($groupNameNode)

        $filesNode = $Xml.CreateElement("Files")
        [void]$groupNode.AppendChild($filesNode)

        # Keep user groups before auto-generated CMSIS/Device groups.
        $cmsisGroup = $Xml.SelectSingleNode("/Project/Targets/Target/Groups/Group[GroupName='::CMSIS']")
        if ($null -ne $cmsisGroup) {
            [void]$groupsNode.InsertBefore($groupNode, $cmsisGroup)
        } else {
            [void]$groupsNode.AppendChild($groupNode)
        }
    }

    $filesNode = $groupNode.SelectSingleNode("Files")
    if ($null -eq $filesNode) {
        $filesNode = $Xml.CreateElement("Files")
        [void]$groupNode.AppendChild($filesNode)
    }

    while ($filesNode.HasChildNodes) {
        [void]$filesNode.RemoveChild($filesNode.FirstChild)
    }

    foreach ($file in $Files) {
        $fileName = [IO.Path]::GetFileName($file)
        $ext = [IO.Path]::GetExtension($file).ToLowerInvariant()
        $fileType = if ($ext -eq ".s" -or $ext -eq ".asm") { "2" } else { "1" }
        $relativePath = ".\" + ($file -replace "/", "\\")

        $fileNode = $Xml.CreateElement("File")

        $fileNameNode = $Xml.CreateElement("FileName")
        $fileNameNode.InnerText = $fileName
        [void]$fileNode.AppendChild($fileNameNode)

        $fileTypeNode = $Xml.CreateElement("FileType")
        $fileTypeNode.InnerText = $fileType
        [void]$fileNode.AppendChild($fileTypeNode)

        $filePathNode = $Xml.CreateElement("FilePath")
        $filePathNode.InnerText = $relativePath
        [void]$fileNode.AppendChild($filePathNode)

        [void]$filesNode.AppendChild($fileNode)
    }
}

function Remove-StaleUvprojGroups {
    param(
        [xml]$Xml,
        [string[]]$ValidGroupNames
    )

    $groupsNode = $Xml.SelectSingleNode("/Project/Targets/Target/Groups")
    if ($null -eq $groupsNode) {
        return
    }

    $validLookup = New-Object System.Collections.Generic.HashSet[string] ([System.StringComparer]::Ordinal)
    foreach ($name in $ValidGroupNames) {
        [void]$validLookup.Add($name)
    }

    # Snapshot nodes first to avoid modifying a live collection while iterating.
    $allGroups = @($groupsNode.SelectNodes("Group"))
    foreach ($groupNode in $allGroups) {
        $nameNode = $groupNode.SelectSingleNode("GroupName")
        if ($null -eq $nameNode) {
            continue
        }

        $groupName = $nameNode.InnerText

        # Keep Keil-managed virtual groups such as ::CMSIS / ::Device.
        if ($groupName.StartsWith("::")) {
            continue
        }

        if (-not $validLookup.Contains($groupName)) {
            [void]$groupsNode.RemoveChild($groupNode)
        }
    }
}

if (-not (Test-Path -LiteralPath $UvprojPath)) {
    throw "Keil project file not found: $UvprojPath"
}

$cmsisGroups = Get-CmsisGroups -Path $CprojectPath
$selectedGroups = if ([string]::IsNullOrWhiteSpace($GroupName)) {
    @($cmsisGroups)
} else {
    @($cmsisGroups | Where-Object { $_.Name -eq $GroupName })
}

if ($selectedGroups.Count -eq 0) {
    if ([string]::IsNullOrWhiteSpace($GroupName)) {
        throw "No CMSIS groups available to sync"
    }
    throw "Group '$GroupName' not found in $CprojectPath"
}

$xml = New-Object System.Xml.XmlDocument
$xml.PreserveWhitespace = $true
$xml.Load((Resolve-Path -LiteralPath $UvprojPath))

foreach ($group in $selectedGroups) {
    Sync-UvprojGroup -Xml $xml -TargetGroupName $group.Name -Files $group.Files
}

if ([string]::IsNullOrWhiteSpace($GroupName)) {
    Remove-StaleUvprojGroups -Xml $xml -ValidGroupNames @($selectedGroups | ForEach-Object { $_.Name })
}

$settings = New-Object System.Xml.XmlWriterSettings
$settings.Indent = $true
$settings.IndentChars = "  "
$settings.NewLineChars = "`r`n"
$settings.NewLineHandling = [System.Xml.NewLineHandling]::Replace
$settings.OmitXmlDeclaration = $false
$settings.Encoding = New-Object System.Text.UTF8Encoding($false)

$writer = [System.Xml.XmlWriter]::Create((Resolve-Path -LiteralPath $UvprojPath), $settings)
$xml.Save($writer)
$writer.Dispose()

Write-Host "Synced $(@($selectedGroups).Count) group(s) from CMSIS to Keil:"
foreach ($group in $selectedGroups) {
    Write-Host " - $($group.Name): $($group.Files.Count) file(s)"
}
