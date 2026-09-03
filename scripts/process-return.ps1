param([Parameter(Mandatory=$true)][string]$ProjectPath,[Parameter(Mandatory=$true)][string]$ReturnPath,[ValidateSet('interactive','inbox')][string]$Mode='interactive')
$ErrorActionPreference='Stop';$project=[System.IO.Path]::GetFullPath($ProjectPath);$return=[System.IO.Path]::GetFullPath($ReturnPath);$text=Get-Content -Raw -LiteralPath $return
$fields=@('Задача:','Результат:','Принятые решения:','Исходная позиция автора / новые мысли автора:','Как они возникли (вопрос автора, реакция на источник, сопоставление):','Связанные источники и их ID:','Изменение позиции автора после чтения:','Оставшиеся противоречия и сомнения:','Происхождение тезисов (SOURCE / AUTHOR / SYNTHESIS / AI_SUGGESTION / UNVERIFIED):','Текст для сохранения:','Использованные источники и их ID:','Новые фактические утверждения:','Утверждения, требующие проверки:','Нерешённые вопросы:','Предлагаемые изменения файлов:','Автор подтвердил содержание:','Фактическая проверка:','Статус материала:')
if(-not($text.Contains('=== CODEX_RETURN ===') -and $text.Contains('=== END CODEX_RETURN ==='))){throw 'Некорректные границы CODEX_RETURN.'};foreach($field in $fields){if(-not $text.Contains($field)){throw "Отсутствует поле: $field"}}
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss-fff';$history=Join-Path $project "history/returns/$stamp-CODEX_RETURN.md";Copy-Item -LiteralPath $return -Destination $history
$frozen=Select-String -Path (Join-Path $project '06_черновики\*.md') -Pattern 'status:\s*["'']?ЗАМОРОЖЕНО' -ErrorAction SilentlyContinue;$conflict=($text -match 'ЗАМОРОЖЕНО') -or ($frozen -and $text -match 'Предлагаемые изменения файлов:\s*.+')
if($Mode -eq 'inbox'){
    $relativeDestination = if($conflict){"inbox/needs-decision/$stamp-CODEX_RETURN.md"}else{"inbox/processed/$stamp-CODEX_RETURN.md"}
    $destination=Join-Path $project $relativeDestination
    Move-Item -LiteralPath $return -Destination $destination
}
$entry="| $(Get-Date -Format 'yyyy-MM-dd HH:mm') | CODEX_RETURN ($Mode) | История: $([IO.Path]::GetFileName($history)); конфликт: $conflict | $(if($conflict){'ТРЕБУЕТ РЕШЕНИЯ'}else{'ПРИНЯТ К ИНТЕГРАЦИИ'}) |";Add-Content -LiteralPath (Join-Path $project 'журнал_работы.md') -Value $entry;Add-Content -LiteralPath (Join-Path $project 'PROJECT_STATE.md') -Value "`n- Последний CODEX_RETURN: $stamp; конфликт: $conflict"
if($conflict){throw 'Возврат сохранён, но требует решения: материал не изменён.'};Write-Output "Возврат проверен и сохранён: $history. Содержательную интеграцию выполняет Codex после проверки предложенных изменений."
