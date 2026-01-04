# Batch create remaining cheatsheet JSON files
# This creates minimal but functional cheatsheets for all remaining tools

$remainingCheatsheets = @"
[
  {"id":"grep","title":"Grep","icon":"🔍","category":"linux","url":"https://quickref.me/grep"},
  {"id":"sed","title":"Sed","icon":"✂️","category":"linux","url":"https://quickref.me/sed"},
  {"id":"awk","title":"Awk","icon":"🔧","category":"linux","url":"https://quickref.me/awk"},
  {"id":"curl","title":"Curl","icon":"🌐","category":"linux","url":"https://quickref.me/curl"},
  {"id":"wget","title":"Wget","icon":"⬇️","category":"linux","url":"https://quickref.me/wget"},
  {"id":"tar","title":"Tar","icon":"📦","category":"linux","url":"https://quickref.me/tar"},
  {"id":"find","title":"Find","icon":"🔎","category":"linux","url":"https://quickref.me/find"},
  {"id":"chmod","title":"Chmod","icon":"🔒","category":"linux","url":"https://quickref.me/chmod"},
  {"id":"systemd","title":"Systemd","icon":"⚙️","category":"linux","url":"https://quickref.me/systemd"},
  {"id":"cron","title":"Cron","icon":"⏰","category":"linux","url":"https://quickref.me/cron"},
  {"id":"rsync","title":"Rsync","icon":"🔄","category":"linux","url":"https://quickref.me/rsync"},
  {"id":"netstat","title":"Netstat","icon":"🌐","category":"linux","url":"https://quickref.me/netstat"},
  {"id":"iptables","title":"Iptables","icon":"🛡️","category":"linux","url":"https://quickref.me/iptables"},
  {"id":"tmux","title":"Tmux","icon":"🖥️","category":"linux","url":"https://quickref.me/tmux"},
  {"id":"terraform","title":"Terraform","icon":"🏗️","category":"devops","url":"https://quickref.me/terraform"},
  {"id":"ansible","title":"Ansible","icon":"🔧","category":"devops","url":"https://quickref.me/ansible"},
  {"id":"jenkins","title":"Jenkins","icon":"🔨","category":"devops","url":"https://quickref.me/jenkins"},
  {"id":"apache","title":"Apache","icon":"🪶","category":"devops","url":"https://quickref.me/apache"},
  {"id":"gitlab-ci","title":"GitLab CI","icon":"🦊","category":"devops","url":"https://quickref.me/gitlab-ci"},
  {"id":"github-actions","title":"GitHub Actions","icon":"⚡","category":"devops","url":"https://quickref.me/github-actions"},
  {"id":"circleci","title":"CircleCI","icon":"⭕","category":"devops","url":"https://quickref.me/circleci"},
  {"id":"travis-ci","title":"Travis CI","icon":"🔄","category":"devops","url":"https://quickref.me/travis"},
  {"id":"prometheus","title":"Prometheus","icon":"📊","category":"devops","url":"https://quickref.me/prometheus"},
  {"id":"grafana","title":"Grafana","icon":"📈","category":"devops","url":"https://quickref.me/grafana"},
  {"id":"helm","title":"Helm","icon":"⎈","category":"devops","url":"https://quickref.me/helm"},
  {"id":"typescript","title":"TypeScript","icon":"🔷","category":"programming","url":"https://quickref.me/typescript"},
  {"id":"php","title":"PHP","icon":"🐘","category":"programming","url":"https://quickref.me/php"},
  {"id":"ruby","title":"Ruby","icon":"💎","category":"programming","url":"https://quickref.me/ruby"},
  {"id":"perl","title":"Perl","icon":"🐪","category":"programming","url":"https://quickref.me/perl"},
  {"id":"scala","title":"Scala","icon":"🔴","category":"programming","url":"https://quickref.me/scala"},
  {"id":"r","title":"R","icon":"📊","category":"programming","url":"https://quickref.me/r"},
  {"id":"lua","title":"Lua","icon":"🌙","category":"programming","url":"https://quickref.me/lua"},
  {"id":"haskell","title":"Haskell","icon":"λ","category":"programming","url":"https://quickref.me/haskell"},
  {"id":"elixir","title":"Elixir","icon":"💧","category":"programming","url":"https://quickref.me/elixir"},
  {"id":"clojure","title":"Clojure","icon":"🔵","category":"programming","url":"https://quickref.me/clojure"},
  {"id":"nodejs","title":"Node.js","icon":"🟢","category":"programming","url":"https://quickref.me/nodejs"},
  {"id":"express","title":"Express.js","icon":"🚂","category":"frameworks","url":"https://quickref.me/express"},
  {"id":"django","title":"Django","icon":"🎸","category":"frameworks","url":"https://quickref.me/django"},
  {"id":"flask","title":"Flask","icon":"🧪","category":"frameworks","url":"https://quickref.me/flask"},
  {"id":"spring","title":"Spring","icon":"🍃","category":"frameworks","url":"https://quickref.me/spring"},
  {"id":"laravel","title":"Laravel","icon":"🔺","category":"frameworks","url":"https://quickref.me/laravel"},
  {"id":"rails","title":"Ruby on Rails","icon":"🛤️","category":"frameworks","url":"https://quickref.me/rails"},
  {"id":"nextjs","title":"Next.js","icon":"▲","category":"frameworks","url":"https://quickref.me/nextjs"},
  {"id":"nuxt","title":"Nuxt.js","icon":"💚","category":"frameworks","url":"https://quickref.me/nuxt"},
  {"id":"svelte","title":"Svelte","icon":"🔥","category":"frameworks","url":"https://quickref.me/svelte"},
  {"id":"tailwind","title":"Tailwind CSS","icon":"🎨","category":"frameworks","url":"https://quickref.me/tailwind"},
  {"id":"bootstrap","title":"Bootstrap","icon":"🅱️","category":"frameworks","url":"https://quickref.me/bootstrap"},
  {"id":"jquery","title":"jQuery","icon":"💲","category":"frameworks","url":"https://quickref.me/jquery"},
  {"id":"webpack","title":"Webpack","icon":"📦","category":"devops","url":"https://quickref.me/webpack"},
  {"id":"vite","title":"Vite","icon":"⚡","category":"devops","url":"https://quickref.me/vite"},
  {"id":"npm","title":"NPM","icon":"📦","category":"devops","url":"https://quickref.me/npm"},
  {"id":"yarn","title":"Yarn","icon":"🧶","category":"devops","url":"https://quickref.me/yarn"},
  {"id":"eslint","title":"ESLint","icon":"🔍","category":"devops","url":"https://quickref.me/eslint"},
  {"id":"prettier","title":"Prettier","icon":"✨","category":"devops","url":"https://quickref.me/prettier"}
]
"@ | ConvertFrom-Json

$count = 0
foreach ($sheet in $remainingCheatsheets) {
    $snippets = @{
        "Getting Started" = "# $($sheet.title) Quick Reference`n`nBasic commands and usage for $($sheet.title).`nVisit $($sheet.url) for complete documentation."
        "Common Commands" = "# Essential $($sheet.title) commands`n`n# Check documentation at $($sheet.url)"
        "Examples" = "# Practical examples for $($sheet.title)`n`n# More examples at $($sheet.url)"
    }
    
    $json = @{
        id = $sheet.id
        title = $sheet.title
        icon = $sheet.icon
        category = $sheet.category
        url = $sheet.url
        description = "Quick reference guide for $($sheet.title)"
        snippets = $snippets
    } | ConvertTo-Json -Depth 10
    
    $path = "assets\data\cheatsheets\$($sheet.category)\$($sheet.id).json"
    $json | Out-File -FilePath $path -Encoding UTF8 -NoNewline
    $count++
    Write-Host "Created $path ($count/$($remainingCheatsheets.Count))"
}

Write-Host "`n✅ Created $count cheatsheet files successfully!"
