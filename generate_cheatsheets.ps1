# Script to generate remaining cheatsheet JSON files efficiently
# This creates placeholder cheatsheets that can be filled with real content later

$cheatsheets = @(
    # Frameworks (4 more needed - already have React, Vue, Angular, Flutter in index)
    @{id="react"; title="React"; icon="⚛️"; category="frameworks"; url="https://quickref.me/react"},
    @{id="vue"; title="Vue.js"; icon="💚"; category="frameworks"; url="https://quickref.me/vue"},
    @{id="angular"; title="Angular"; icon="🅰️"; category="frameworks"; url="https://quickref.me/angular"},
    @{id="flutter"; title="Flutter"; icon="🦋"; category="frameworks"; url="https://quickref.me/flutter"},
    
    # DevOps (13 more - already have Docker, Git)
    @{id="kubernetes"; title="Kubernetes"; icon="☸️"; category="devops"; url="https://quickref.me/kubernetes"},
    @{id="terraform"; title="Terraform"; icon="🏗️"; category="devops"; url="https://quickref.me/terraform"},
    @{id="ansible"; title="Ansible"; icon="🔧"; category="devops"; url="https://quickref.me/ansible"},
    @{id="jenkins"; title="Jenkins"; icon="🔨"; category="devops"; url="https://quickref.me/jenkins"},
    @{id="nginx"; title="Nginx"; icon="🌐"; category="devops"; url="https://quickref.me/nginx"},
    @{id="apache"; title="Apache"; icon="🪶"; category="devops"; url="https://quickref.me/apache"},
    @{id="gitlab-ci"; title="GitLab CI"; icon="🦊"; category="devops"; url="https://quickref.me/gitlab-ci"},
    @{id="github-actions"; title="GitHub Actions"; icon="⚡"; category="devops"; url="https://quickref.me/github-actions"},
    @{id="circleci"; title="CircleCI"; icon="⭕"; category="devops"; url="https://quickref.me/circleci"},
    @{id="travis-ci"; title="Travis CI"; icon="🔄"; category="devops"; url="https://quickref.me/travis"},
    @{id="prometheus"; title="Prometheus"; icon="📊"; category="devops"; url="https://quickref.me/prometheus"},
    @{id="grafana"; title="Grafana"; icon="📈"; category="devops"; url="https://quickref.me/grafana"},
    @{id="helm"; title="Helm"; icon="⎈"; category="devops"; url="https://quickref.me/helm"},
    
    # Linux (16 more - already have Bash)
    @{id="ssh"; title="SSH"; icon="🔐"; category="linux"; url="https://quickref.me/ssh"},
    @{id="vim"; title="Vim"; icon="📝"; category="linux"; url="https://quickref.me/vim"},
    @{id="tmux"; title="Tmux"; icon="🖥️"; category="linux"; url="https://quickref.me/tmux"},
    @{id="grep"; title="Grep"; icon="🔍"; category="linux"; url="https://quickref.me/grep"},
    @{id="sed"; title="Sed"; icon="✂️"; category="linux"; url="https://quickref.me/sed"},
    @{id="awk"; title="Awk"; icon="🔧"; category="linux"; url="https://quickref.me/awk"},
    @{id="curl"; title="Curl"; icon="🌐"; category="linux"; url="https://quickref.me/curl"},
    @{id="wget"; title="Wget"; icon="⬇️"; category="linux"; url="https://quickref.me/wget"},
    @{id="tar"; title="Tar"; icon="📦"; category="linux"; url="https://quickref.me/tar"},
    @{id="find"; title="Find"; icon="🔎"; category="linux"; url="https://quickref.me/find"},
    @{id="chmod"; title="Chmod"; icon="🔒"; category="linux"; url="https://quickref.me/chmod"},
    @{id="systemd"; title="Systemd"; icon="⚙️"; category="linux"; url="https://quickref.me/systemd"},
    @{id="cron"; title="Cron"; icon="⏰"; category="linux"; url="https://quickref.me/cron"},
    @{id="rsync"; title="Rsync"; icon="🔄"; category="linux"; url="https://quickref.me/rsync"},
    @{id="netstat"; title="Netstat"; icon="🌐"; category="linux"; url="https://quickref.me/netstat"},
    @{id="iptables"; title="Iptables"; icon="🛡️"; category="linux"; url="https://quickref.me/iptables"},
    
    # Databases (2 more - already have MySQL)
    @{id="postgresql"; title="PostgreSQL"; icon="🐘"; category="databases"; url="https://quickref.me/postgres"},
    @{id="mongodb"; title="MongoDB"; icon="🍃"; category="databases"; url="https://quickref.me/mongodb"}
)

foreach ($sheet in $cheatsheets) {
    $json = @{
        id = $sheet.id
        title = $sheet.title
        icon = $sheet.icon
        category = $sheet.category
        url = $sheet.url
        description = "Quick reference guide for $($sheet.title)"
        snippets = @{
            "Getting Started" = "# $($sheet.title) Quick Reference`n`nVisit $($sheet.url) for complete documentation."
            "Basic Commands" = "# Coming soon`n# Check $($sheet.url) for details"
            "Common Patterns" = "# Examples will be added`n# Visit $($sheet.url)"
        }
    } | ConvertTo-Json -Depth 10
    
    $path = "assets\data\cheatsheets\$($sheet.category)\$($sheet.id).json"
    $json | Out-File -FilePath $path -Encoding UTF8
    Write-Host "Created $path"
}

Write-Host "`nCreated $($cheatsheets.Count) cheatsheet files"
