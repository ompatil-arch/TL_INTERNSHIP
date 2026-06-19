$base = Split-Path -Parent $MyInvocation.MyCommand.Path
$files = @(
    'daily_docs/week1/day1_doc/day1.html',
    'daily_docs/week1/day2_doc/day2.html',
    'daily_docs/week1/day3_doc/day3.html',
    'daily_docs/week1/day4_doc/day4.html',
    'daily_docs/week1/day5_doc/day5.html',
    'daily_docs/week2/day1_doc/week2-day1.html',
    'daily_docs/week2/day2_doc/week2-day2.html',
    'daily_docs/week2/day3_doc/week2-day3.html',
    'daily_docs/week2/day4_doc/week2-day4.html',
    'daily_docs/week3/day1_doc/week3-day1.html',
    'daily_docs/week3/day2_doc/week3-day2.html',
    'daily_docs/week3/day3_doc/week3-day3.html',
    'daily_docs/project_documentation/project_doc/project-documentation.html',
    'daily_docs/session_doc/session1_doc/session-1.html',
    'daily_docs/session_doc/session2_doc/session-2.html',
    'daily_docs/session_doc/session3_doc/session-3.html',
    'daily_docs/session_doc/session4_doc/session-4.html'
)

$sections = @()
foreach ($file in $files) {
    $path = Join-Path $base $file
    if (-Not (Test-Path $path)) {
        Write-Host "Missing file: $path"
        continue
    }
    $content = Get-Content -Path $path -Raw -ErrorAction Stop
    $headerMatch = [regex]::Match($content, '<header class="doc-head">(.*?)</header>', 'Singleline')
    $articleMatch = [regex]::Match($content, '<article class="docx-content">(.*?)</article>', 'Singleline')
    $headerHtml = if ($headerMatch.Success) { $headerMatch.Groups[1].Value.Trim() } else { '' }
    $articleHtml = if ($articleMatch.Success) { $articleMatch.Groups[1].Value.Trim() } else { '' }
    $kickerMatch = [regex]::Match($headerHtml, '<p class="kicker">(.*?)</p>', 'Singleline')
    $headingMatch = [regex]::Match($headerHtml, '<h1>(.*?)</h1>', 'Singleline')
    $taglineMatch = [regex]::Match($headerHtml, '<p class="tagline">(.*?)</p>', 'Singleline')
    $kicker = if ($kickerMatch.Success) { $kickerMatch.Groups[1].Value.Trim() } else { '' }
    $heading = if ($headingMatch.Success) { $headingMatch.Groups[1].Value.Trim() } else { '' }
    $tagline = if ($taglineMatch.Success) { $taglineMatch.Groups[1].Value.Trim() } else { '' }
    if (-not $heading) {
        $titleMatch = [regex]::Match($content, '<title>(.*?)</title>', 'Singleline')
        if ($titleMatch.Success) {
            $heading = $titleMatch.Groups[1].Value.Split('—')[0].Trim()
        }
    }
    $articleHtml = [regex]::Replace($articleHtml, '<a[^>]*class="back"[^>]*>.*?</a>', '', 'Singleline')
    $articleHtml = [regex]::Replace($articleHtml, '<script.*?</script>', '', 'Singleline')
    $articleHtml = [regex]::Replace($articleHtml, '<img[^>]*>', '', 'Singleline')
    $articleHtml = [regex]::Replace($articleHtml, '<video[^>]*>.*?</video>', '', 'Singleline')
    $articleHtml = [regex]::Replace($articleHtml, 'src="[^"]+"', '', 'Singleline')
    $sectionId = [regex]::Replace($heading, '[^a-zA-Z0-9]+', '-').ToLower().Trim('-')
    if (-not $sectionId) { $sectionId = ([regex]::Replace($file, '[^a-zA-Z0-9]+', '-')).ToLower().Trim('-') }
    $sections += [pscustomobject]@{
        Id = $sectionId
        Heading = if ($heading) { $heading } else { $file }
        Tagline = if ($tagline) { $tagline } elseif ($kicker) { $kicker } else { '' }
        Body = $articleHtml
    }
}

$output = @()
$output += '<!DOCTYPE html>'
$output += '<html lang="en">'
$output += '<head>'
$output += '  <meta charset="UTF-8">'
$output += '  <meta name="viewport" content="width=device-width, initial-scale=1.0">'
$output += '  <title>Combined Internship Documentation</title>'
$output += '  <style>'
$output += '    body { margin: 0; font-family: Arial, Helvetica, sans-serif; background: #0b1733; color: #eef2ff; line-height: 1.6; }'
$output += '    .container { width: min(1180px, calc(100% - 2rem)); margin: 0 auto; padding: 2rem; }'
$output += '    header { position: sticky; top: 0; background: rgba(4,11,42,.96); backdrop-filter: blur(8px); z-index: 10; padding: 1rem 0; border-bottom: 1px solid rgba(255,255,255,.1); }'
$output += '    .nav { display: flex; flex-wrap: wrap; gap: .75rem; align-items: center; }'
$output += '    .nav a { color: #a8bbd7; text-decoration: none; padding: .5rem .75rem; border-radius: .75rem; transition: .2s; }'
$output += '    .nav a:hover { background: rgba(45,140,255,.14); color: #fff; }'
$output += '    h1, h2, h3 { margin: .75rem 0; }'
$output += '    h1 { font-size: clamp(2rem, 4vw, 3rem); }'
$output += '    h2 { font-size: clamp(1.6rem, 2.5vw, 2.2rem); color: #c7d6ff; }'
$output += '    .section { padding: 2rem 0; border-bottom: 1px solid rgba(255,255,255,.08); }'
$output += '    .section p, .section li { color: #d4dde7; }'
$output += '    .section ul, .section ol { padding-left: 1.4rem; margin: 1rem 0; }'
$output += '    .tagline { color: #8fb8ff; margin: .25rem 0 1rem; }'
$output += '    .subsection { margin-top: 1rem; padding: 1.2rem; border: 1px solid rgba(255,255,255,.08); border-radius: 1rem; background: rgba(255,255,255,.03); }'
$output += '    footer { text-align: center; padding: 2rem 0; color: #8b9cc7; }'
$output += '    @media (max-width: 760px) { .nav { justify-content: center; } }'
$output += '  </style>'
$output += '</head>'
$output += '<body>'
$output += '  <div class="container">'
$output += '    <header>'
$output += '      <h1>Combined Internship Documentation</h1>'
$output += '      <p class="tagline">Weekly reports, project documentation, and session notes in a single page.</p>'
$output += '      <nav class="nav">'
foreach ($section in $sections) {
    $output += '        <a href="#' + $section.Id + '">' + $section.Heading + '</a>'
}
$output += '      </nav>'
$output += '    </header>'
foreach ($section in $sections) {
    $output += '    <section id="' + $section.Id + '" class="section">'
    $output += '      <h2>' + $section.Heading + '</h2>'
    if ($section.Tagline) { $output += '      <p class="tagline">' + $section.Tagline + '</p>' }
    $output += '      <div class="subsection">'
    $output += $section.Body
    $output += '      </div>'
    $output += '    </section>'
}
$output += '    <footer><p>Combined documentation page generated from all internship folders.</p></footer>'
$output += '  </div>'
$output += '</body>'
$output += '</html>'

Set-Content -Path (Join-Path $base 'combined_internship_documentation.html') -Value ($output -join "`n") -Encoding UTF8
Write-Host "Combined file created: $base\combined_internship_documentation.html"