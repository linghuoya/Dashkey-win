# DashKey Windows 构建脚本
#
#   .\build.ps1                     # 依赖已装的 .NET 8 桌面运行时，单文件
#   .\build.ps1 -SelfContained      # 自带运行时，体积大但目标机器无需装 .NET
#   .\build.ps1 -Runtime win-arm64  # 指定架构
#
# 需要 .NET 8 SDK。

param(
    [string]$Runtime = "win-x64",
    [switch]$SelfContained
)

$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot

try {
    $out = Join-Path $PSScriptRoot "Build\DashKey-$Runtime"

    Write-Host "==> 发布 $Runtime (SelfContained=$SelfContained)"

    $publishArgs = @(
        ".\DashKey.Windows.csproj",
        "-c", "Release",
        "-r", $Runtime,
        "--self-contained", $SelfContained.IsPresent,
        "-p:PublishSingleFile=true",
        "-o", $out
    )

    # WPF 自包含单文件必须显式要求把原生库解压到磁盘，否则启动时加载不到
    # coreclr.dll / wpfgfx_cor3.dll 等原生依赖，表现为双击毫无反应、
    # 连一行日志都不产生（WinExe 没有控制台，错误也看不见）。
    if ($SelfContained) {
        $publishArgs += "-p:IncludeNativeLibrariesForSelfExtract=true"
    }

    dotnet publish @publishArgs

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet publish 失败（exit $LASTEXITCODE）"
    }

    Write-Host "==> 完成: $out\DashKey.exe"
}
finally {
    Pop-Location
}
