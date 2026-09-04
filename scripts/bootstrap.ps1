param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,
    [switch]$InstallDependencies,
    [string]$CodexHome
)

$ErrorActionPreference = 'Stop'
$project = [System.IO.Path]::GetFullPath($ProjectPath)
$skillRoot = Split-Path -Parent $PSScriptRoot
$templates = Join-Path $skillRoot 'templates'
if (-not (Test-Path -LiteralPath $project)) { New-Item -ItemType Directory -Path $project | Out-Null }

$folders = @('inbox/pending','inbox/processed','inbox/needs-decision','history/returns','metadata','00_требования/оригиналы','00_требования/извлечения','01_понимание_задачи','02_источники/карточки','02_источники/оригиналы','03_конспекты','04_данные/исходные','04_данные/обработанные','04_данные/методы_обработки','04_данные/результаты','05_план','06_черновики','07_проверки','08_иллюстрации','09_финал','10_руководитель')
foreach ($folder in $folders) { $target = Join-Path $project $folder; if (-not (Test-Path -LiteralPath $target)) { New-Item -ItemType Directory -Path $target | Out-Null } }

$files = @{
    'AGENTS.md' = 'AGENTS.md'; 'PROJECT_STATE.md' = 'PROJECT_STATE.md'; 'CHATGPT_START.md' = 'CHATGPT_START.md'; 'журнал_работы.md' = 'журнал_работы.md'; 'журнал_решений.md' = 'журнал_решений.md';
    '01_понимание_задачи/паспорт_исследования.md' = 'паспорт_исследования.md'; '01_понимание_задачи/AUTHOR_POSITION.md' = 'AUTHOR_POSITION.md'; '02_источники/реестр_источников.md' = 'реестр_источников.md'; '09_финал/чеклист_оформления.md' = 'чеклист_оформления.md'; '10_руководитель/шаблон_замечания.md' = 'замечание_руководителя.md'
}
foreach ($relative in $files.Keys) {
    $target = Join-Path $project $relative
    if (-not (Test-Path -LiteralPath $target)) { Copy-Item -LiteralPath (Join-Path $templates $files[$relative]) -Destination $target }
    else { Write-Output "Сохранён существующий файл: $relative" }
}

$codexHome = if ($CodexHome) { [System.IO.Path]::GetFullPath($CodexHome) } elseif ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$skills = Join-Path $codexHome 'skills'
$manifest = Import-PowerShellDataFile -LiteralPath (Join-Path $PSScriptRoot 'dependencies.psd1')
$names = @($manifest.Dependencies.Keys | Sort-Object)
function Get-DependencyState([string]$Name) {
    if (Test-Path -LiteralPath (Join-Path $skills "$Name\SKILL.md") -PathType Leaf) { 'УСТАНОВЛЕН' } else { 'ОТСУТСТВУЕТ' }
}
Write-Output 'Зависимые skills до установки:'
foreach ($name in $names) { Write-Output "${name}: $(Get-DependencyState $name)" }
$missing = @($names | Where-Object { (Get-DependencyState $_) -eq 'ОТСУТСТВУЕТ' })
if ($InstallDependencies -and $missing.Count -gt 0) {
    $installer = Join-Path $skills '.system\skill-installer\scripts\install-skill-from-github.py'
    if (-not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw "Не найден системный установщик навыков: $installer" }
    $priorCodexHome = $env:CODEX_HOME
    $env:CODEX_HOME = $codexHome
    $failures = @()
    try {
        foreach ($name in $missing) {
            $spec = $manifest.Dependencies[$name]
            Write-Output "Устанавливается: $name из $($spec.Repo)@$($spec.Ref)"
            $args = @($installer,'--repo',$spec.Repo,'--ref',$spec.Ref,'--path',$spec.Path,'--method','download')
            if ($spec.Path -eq '.') { $args += @('--name',$name) }
            & python @args
            if ($LASTEXITCODE -ne 0) { $failures += $name; Write-Warning "Не удалось установить: $name" }
        }
    } finally { $env:CODEX_HOME = $priorCodexHome }
    if ($failures.Count -gt 0) { Write-Warning "Ошибки установки: $($failures -join ', ')" }
}
Write-Output 'Зависимые skills после проверки:'
$stillMissing = @()
foreach ($name in $names) { $state = Get-DependencyState $name; Write-Output "${name}: $state"; if ($state -eq 'ОТСУТСТВУЕТ') { $stillMissing += $name } }
if ($stillMissing.Count -gt 0) {
    if ($InstallDependencies) { throw "Не установлены: $($stillMissing -join ', '). Проверьте сеть, Python и доступ к репозиториям." }
    Write-Warning "Отсутствуют: $($stillMissing -join ', '). Повторите команду с -InstallDependencies."
}
Write-Output "Проект подготовлен: $project"
