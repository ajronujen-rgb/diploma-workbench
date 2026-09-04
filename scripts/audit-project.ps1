param([Parameter(Mandatory=$true)][string]$ProjectPath)
$ErrorActionPreference='Stop'; $project=[System.IO.Path]::GetFullPath($ProjectPath)
$required=@('AGENTS.md','PROJECT_STATE.md','CHATGPT_START.md','журнал_работы.md','журнал_решений.md','01_понимание_задачи/AUTHOR_POSITION.md','01_понимание_задачи/чекпоинт_отбора.md','02_источники/реестр_источников.md','02_источники/карта_области.md','09_финал/чеклист_оформления.md','inbox/pending','inbox/processed','inbox/needs-decision')
$issues=@(); foreach($item in $required){if(-not(Test-Path -LiteralPath (Join-Path $project $item))){$issues+="Отсутствует: $item"}}
$cards=Get-ChildItem -LiteralPath (Join-Path $project '02_источники/карточки') -Filter '*.md' -ErrorAction SilentlyContinue; $ids=@($cards|ForEach-Object{if($_.BaseName -match '^SRC-\d+$'){$_.BaseName}})
if(($ids|Group-Object|Where-Object Count -gt 1).Count){$issues+='Есть дубли ID карточек источников.'}
$pending=@(Get-ChildItem -LiteralPath (Join-Path $project 'inbox/pending') -File -ErrorAction SilentlyContinue).Count; if($pending -gt 0){$issues+="Необработанные возвраты: $pending"}
if($issues.Count){$issues|ForEach-Object{Write-Warning $_};exit 1};Write-Output 'Проверка проекта пройдена.'
