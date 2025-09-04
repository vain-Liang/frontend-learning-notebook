# 保存为 generate-mkdocs-nav.ps1
param (
    [string]$DocsDir = "Web",              # Markdown 文档根目录
    [string]$OutputFile = "nav_output.txt" # 输出的导航配置文件
)

function Get-NavTree {
    param (
        [string]$Path,
        [int]$Indent = 2
    )

    # 获取文件夹下所有条目，按名字排序
    $items = Get-ChildItem -Path $Path | Sort-Object Name

    foreach ($item in $items) {
        $prefix = " " * $Indent
        if ($item.PSIsContainer) {
            # 目录
            $dirName = $item.Name
            "$prefix- ${dirName}:" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
            Get-NavTree -Path $item.FullName -Indent ($Indent + 2)
        }
        else {
            # 文件
            if ($item.Extension -eq ".md") {
                $fileName = $item.BaseName
                $relPath = $item.FullName.Substring((Resolve-Path $DocsDir).Path.Length + 1)
                # 路径里 \ 需要转义
                $relPath = $relPath -replace "\\", "\\"
                "$prefix- ${fileName}: '${relPath}'" | Out-File -FilePath $OutputFile -Append -Encoding UTF8
            }
        }
    }
}

# 清空输出文件
"" | Out-File -FilePath $OutputFile -Encoding UTF8

# 写入 nav 根节点
"nav:" | Out-File -FilePath $OutputFile -Append -Encoding UTF8

# 生成目录树
Get-NavTree -Path $DocsDir -Indent 2

Write-Host "导航结构已生成到 $OutputFile"
