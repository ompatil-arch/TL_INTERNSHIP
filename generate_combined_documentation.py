from pathlib import Path
import re

base = Path(r'c:/Users/Sai/Documents/TL_INTERNSHIP')
files = [
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
    'daily_docs/session_doc/session4_doc/session-4.html',
]

sections = []
for path in files:
    p = base / path
    text = p.read_text(encoding='utf-8', errors='ignore')
    header_match = re.search(r'<header class="doc-head">(.*?)</header>', text, re.S)
    article_match = re.search(r'<article class="docx-content">(.*?)</article>', text, re.S)
    header_html = header_match.group(1).strip() if header_match else ''
    article_html = article_match.group(1).strip() if article_match else ''
    kicker = None
    heading = None
    subtitle = None
    if header_html:
        m = re.search(r'<p class="kicker">(.*?)</p>', header_html, re.S)
        if m:
            kicker = m.group(1).strip()
        m = re.search(r'<h1>(.*?)</h1>', header_html, re.S)
        if m:
            heading = m.group(1).strip()
        m = re.search(r'<p class="tagline">(.*?)</p>', header_html, re.S)
        if m:
            subtitle = m.group(1).strip()
    if not heading:
        m = re.search(r'<title>(.*?)</title>', text, re.S)
        if m:
            heading = m.group(1).split('—')[0].strip()
    article_html = re.sub(r'<a[^>]*class="back"[^>]*>.*?</a>', '', article_html, flags=re.S)
    article_html = re.sub(r'<script.*?</script>', '', article_html, flags=re.S)
    article_html = re.sub(r'<img[^>]*>', '', article_html)
    article_html = re.sub(r'<video[^>]*>.*?</video>', '', article_html, flags=re.S)
    section_id = re.sub(r'[^a-z0-9]+', '-', (heading or path)).strip('-').lower()
    sections.append((section_id, heading or path, subtitle or kicker or '', article_html))

output = []
output.append('<!DOCTYPE html>')
output.append('<html lang="en">')
output.append('<head>')
output.append('  <meta charset="UTF-8">')
output.append('  <meta name="viewport" content="width=device-width, initial-scale=1.0">')
output.append('  <title>Combined Internship Documentation</title>')
output.append('  <style>')
output.append('    body{margin:0;font-family:Arial,Helvetica,sans-serif;background:#0b1733;color:#eef2ff;line-height:1.6;}')
output.append('    .container{width:min(1200px,calc(100%-2rem));margin:0 auto;padding:2rem;}')
output.append('    header{position:sticky;top:0;background:rgba(4,11,42,.96);backdrop-filter:blur(8px);z-index:10;padding:1rem 0;border-bottom:1px solid rgba(255,255,255,.1);}')
output.append('    .nav{display:flex;flex-wrap:wrap;gap:.75rem;align-items:center;}')
output.append('    .nav a{color:#a8bbd7;text-decoration:none;padding:.5rem .75rem;border-radius:.75rem;transition:.2s;}')
output.append('    .nav a:hover{background:rgba(45,140,255,.14);color:#fff;}')
output.append('    h1,h2,h3{margin:.75rem 0;}')
output.append('    h1{font-size:clamp(2.2rem,3vw,3.4rem);}')
output.append('    h2{font-size:clamp(1.6rem,2vw,2rem);color:#c7d6ff;}')
output.append('    .section{padding:2.5rem 0;border-bottom:1px solid rgba(255,255,255,.08);}')
output.append('    .section p,.section li{color:#d4dde7;}')
output.append('    .section ul,.section ol{padding-left:1.4rem;margin:1rem 0;}')
output.append('    .tagline{color:#8fb8ff;margin:.25rem 0 1.5rem;}')
output.append('    .subsection{margin-top:1.5rem;padding:1.5rem;border:1px solid rgba(255,255,255,.08);border-radius:1rem;background:rgba(255,255,255,.03);}')
output.append('    .subsection h3{margin-top:0;}')
output.append('    footer{text-align:center;padding:2rem 0;color:#8b9cc7;}')
output.append('    @media(max-width:760px){.nav{justify-content:center;}}')
output.append('  </style>')
output.append('</head>')
output.append('<body>')
output.append('<div class="container">')
output.append('  <header><h1>Combined Internship Documentation</h1><p class="tagline">All weekly reports, project details, and session notes in one page.</p><nav class="nav">')
for sid, heading, subtitle, article_html in sections:
    output.append(f'    <a href="#{sid}">{heading}</a>')
output.append('  </nav></header>')
for sid, heading, subtitle, article_html in sections:
    output.append(f'<section id="{sid}" class="section">')
    output.append(f'  <h2>{heading}</h2>')
    if subtitle:
        output.append(f'  <p class="tagline">{subtitle}</p>')
    output.append('  <div class="subsection">')
    output.append(article_html)
    output.append('  </div>')
    output.append('</section>')
output.append('<footer><p>Combined documentation generated from all internship folders.</p></footer>')
output.append('</div></body></html>')

out_path = base / 'combined_internship_documentation.html'
out_path.write_text('\n'.join(output), encoding='utf-8')
print('CREATED', out_path)
