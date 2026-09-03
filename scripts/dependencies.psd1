@{
    Dependencies = @{
        chukovsky  = @{ Repo = 'beaverbeard/chukovsky';  Ref = 'main';   Path = '.claude/skills/chukovsky';  Purpose = 'Смысл, структура и ясность текста' }
        agranovsky = @{ Repo = 'beaverbeard/agranovsky'; Ref = 'master'; Path = '.claude/skills/agranovsky'; Purpose = 'Проверка фактических утверждений' }
        slopotron  = @{ Repo = 'beaverbeard/slopotron';  Ref = 'main';   Path = '.claude/skills/slopotron';  Purpose = 'Шаблонные AI-паттерны и канцелярит' }
        rozental   = @{ Repo = 'beaverbeard/rozental';   Ref = 'main';   Path = '.claude/skills/rozental';   Purpose = 'Орфография, пунктуация и грамматика' }
        milchin    = @{ Repo = 'beaverbeard/milchin';    Ref = 'master'; Path = '.claude/skills/milchin';    Purpose = 'Типографика и техническая чистота' }
        vinogradov = @{ Repo = 'beaverbeard/vinogradov'; Ref = 'main';   Path = '.';                         Purpose = 'Voice DNA по собственным текстам студента' }
    }
}
