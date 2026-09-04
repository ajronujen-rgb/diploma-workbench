param([string]$SkillPath = (Split-Path -Parent $PSScriptRoot))
$ErrorActionPreference='Stop'
$required=@(
  'references/internal-editorial-qc.md',
  'tests/editorial-pipeline-regression.md',
  'templates/редакторский_qc.md'
)
foreach($relative in $required){if(-not(Test-Path -LiteralPath (Join-Path $SkillPath $relative))){throw "Отсутствует: $relative"}}
$workflow=Get-Content -Raw -LiteralPath (Join-Path $SkillPath 'references/workflow.md')
$handoff=Get-Content -Raw -LiteralPath (Join-Path $SkillPath 'references/handoff-protocol.md')
if($workflow -notmatch 'внутренний редакционно-контрольный pipeline'){throw 'Нет правила self-execute в workflow.'}
if($handoff -notmatch 'Не используй этот handoff для смысловой редактуры готового текста'){throw 'Handoff не запрещает внешний запуск внутреннего QC.'}
Write-Output 'Editorial pipeline regression guard passed.'
