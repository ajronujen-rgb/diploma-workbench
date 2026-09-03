# Зависимые skills

Bootstrap использует единый манифест `scripts/dependencies.psd1`; это единственный источник путей и веток установки.

| Skill | Источник | Назначение |
|---|---|---|
| `chukovsky` | `beaverbeard/chukovsky`, `main`, `.claude/skills/chukovsky` | Смысл, структура и ясность текста. |
| `agranovsky` | `beaverbeard/agranovsky`, `master`, `.claude/skills/agranovsky` | Проверка фактических утверждений. |
| `slopotron` | `beaverbeard/slopotron`, `main`, `.claude/skills/slopotron` | Шаблонные AI-паттерны и канцелярит. |
| `rozental` | `beaverbeard/rozental`, `main`, `.claude/skills/rozental` | Орфография, пунктуация и грамматика. |
| `milchin` | `beaverbeard/milchin`, `master`, `.claude/skills/milchin` | Типографика и техническая чистота. |
| `vinogradov` | `beaverbeard/vinogradov`, `main`, корень | Voice DNA по собственным текстам студента. |

При запуске без `-InstallDependencies` bootstrap только показывает статус. С флагом он устанавливает только отсутствующие навыки, затем обязательно повторяет проверку. Уже установленный навык не заменяется и не обновляется.
