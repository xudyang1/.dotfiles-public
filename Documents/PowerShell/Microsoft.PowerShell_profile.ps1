# History file: `nvim (Get-PSReadlineOption).HistorySavePath`
# PSReadLine: Get-Module PSReadLine -ListAvailable
# z: Install-Module -Name z`

$_prompt_symbol= if (
([Security.Principal.WindowsPrincipal] `
  [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( `
  [Security.Principal.WindowsBuiltInRole]::Administrator)
){ '#' } else { '$' }

function __gp_read([string]$path) {
    if ([IO.File]::Exists($path)) {
        try { return [IO.File]::ReadAllText($path).Trim() } catch { }
    }
    return $null
}

function Get-GitPromptString {
  $savedExitCode = $global:LASTEXITCODE
    try{
      # ---- 1. locate repo (one subprocess) --------------------------------
      $rp = git rev-parse --absolute-git-dir --is-bare-repository --is-inside-work-tree 2>$null
        if ($LASTEXITCODE -ne 0 -or -not $rp) { return "" }
      $info = @($rp | Where-Object { $_ -ne '' })
        if ($info.Count -lt 3) { return "" }
      $gitDir     = $info[0]
        $isBare     = ($info[1] -eq 'true')
        $inWorkTree = ($info[2] -eq 'true')

        # ---- 2. state detection (zero subprocesses) ------------------------
        $state         = ''
        $branchInState = $null

        $rebaseMerge = Join-Path $gitDir 'rebase-merge'
        $rebaseApply = Join-Path $gitDir 'rebase-apply'
        $sequencer   = Join-Path $gitDir 'sequencer'

        if ([IO.Directory]::Exists($rebaseMerge)) {
          $step   = __gp_read (Join-Path $rebaseMerge 'msgnum')
            $total  = __gp_read (Join-Path $rebaseMerge 'end')
            $branchInState = __gp_read (Join-Path $rebaseMerge 'head-name')
            if ($branchInState) { $branchInState = $branchInState -replace '^refs/heads/','' }
          $state = if ($step -and $total) { "|REBASE $step/$total" } else { '|REBASE' }
        }
      elseif ([IO.Directory]::Exists($rebaseApply)) {
        $step  = __gp_read (Join-Path $rebaseApply 'next')
          $total = __gp_read (Join-Path $rebaseApply 'last')
          if ([IO.File]::Exists((Join-Path $rebaseApply 'rebasing'))) {
            $branchInState = __gp_read (Join-Path $rebaseApply 'head-name')
              if ($branchInState) { $branchInState = $branchInState -replace '^refs/heads/','' }
            $state = if ($step -and $total) { "|REBASE $step/$total" } else { '|REBASE' }
          }
        elseif ([IO.File]::Exists((Join-Path $rebaseApply 'applying'))) {
          $state = if ($step -and $total) { "|AM $step/$total" } else { '|AM' }
        }
          else { $state = '|AM/REBASE' }
      }
      elseif ([IO.File]::Exists((Join-Path $gitDir 'MERGE_HEAD'))) {
        $state = '|MERGING'
      }
      elseif ([IO.File]::Exists((Join-Path $gitDir 'CHERRY_PICK_HEAD'))) {
        $state = '|CHERRY-PICKING'
      }
      elseif ([IO.File]::Exists((Join-Path $gitDir 'REVERT_HEAD'))) {
        $state = '|REVERTING'
      }
      elseif ([IO.Directory]::Exists($sequencer)) {
        $todo = __gp_read (Join-Path $sequencer 'todo')
          if ($todo) {
            $first = ($todo -split "`n")[0]
              if     ($first -match '^pick\b')   { $state = '|CHERRY-PICKING' }
            elseif ($first -match '^revert\b') { $state = '|REVERTING' }
          }
      }
      elseif ([IO.File]::Exists((Join-Path $gitDir 'BISECT_LOG'))) {
        $state = '|BISECTING'
      }

      # ---- 3. bare / inside-.git shortcut ---------------------------------
      if ($isBare -or -not $inWorkTree) {
        $prefix = if ($isBare) { 'BARE:' } else { 'GIT_DIR!' }
        $branch = $branchInState
          if (-not $branch) {
            $sym = git symbolic-ref --short HEAD 2>$null
              if ($sym) { $branch = $sym.Trim() }
          }
        if (-not $branch) {
          $sha = git rev-parse --short HEAD 2>$null
            if ($sha) { $branch = "($($sha.Trim()))" }
        }
        return "($prefix$branch$state)"
      }

      # ---- 4. one status call gives branch + dirty + upstream + stash ----
      $statusOut = git status --porcelain=v2 --branch --show-stash 2>$null
        if ($LASTEXITCODE -ne 0) { return "" }

      $headVal = $null
        $ahead = 0; $behind = 0; $hasUpstream = $false
        $stashCount = 0
        $hasStaged = $false; $hasUnstaged = $false; $hasUntracked = $false; $hasConflict = $false

        foreach ($line in $statusOut) {
          if (-not $line) { continue }
          $c = $line[0]
            if ($c -eq '#') {
              if     ($line -match '^# branch\.head (.+)$')            { $headVal = $Matches[1] }
              elseif ($line -match '^# branch\.ab \+(\d+) -(\d+)$')    { $ahead=[int]$Matches[1]; $behind=[int]$Matches[2]; $hasUpstream=$true }
              elseif ($line -match '^# stash (\d+)$')                  { $stashCount = [int]$Matches[1] }
            }
          elseif ($c -eq 'u') {           # unmerged entry
            $hasConflict = $true; $hasStaged = $true; $hasUnstaged = $true
          }
          elseif ($c -eq '1' -or $c -eq '2') {
            if ($line.Length -ge 4) {
              if ($line[2] -ne '.') { $hasStaged   = $true }
              if ($line[3] -ne '.') { $hasUnstaged = $true }
            }
          }
          elseif ($c -eq '?') { $hasUntracked = $true }
        }

      # ---- 5. branch / detached-head resolution --------------------------
      $branch = $branchInState
        if (-not $branch -and $headVal -and $headVal -ne '(detached)') {
          $branch = $headVal
        }
      if (-not $branch) {
        # detached HEAD: describe with --contains --all (matches GIT_PS1_DESCRIBE_STYLE=branch)
        $desc = git describe --contains --all HEAD 2>$null
          if (-not $desc) { $desc = git describe --tags --exact-match HEAD 2>$null }
        if (-not $desc) { $desc = git rev-parse --short HEAD 2>$null }
        if (-not $desc) { return "" }
        $branch = "($($desc.Trim()))"
      }

      # ---- 6. assemble ----------------------------------------------------
      $conflict = if ($hasConflict) { '|CONFLICT' } else { '' }

      # order matches git-sh-prompt:  * (unstaged) + (staged) $ (stash) % (untracked)
      $dirty = ''
        if ($hasUnstaged)      { $dirty += "`e[31m*`e[0m" }
      if ($hasStaged)        { $dirty += "`e[32m+`e[0m" }
      if ($stashCount -gt 0) { $dirty += "`e[1;36m$`e[0m" }
      if ($hasUntracked)     { $dirty += "`e[31m%`e[0m" }

      $upstream = ''
        if ($hasUpstream) {
          if     ($ahead -gt 0 -and $behind -gt 0) { $upstream = '<>' }
          elseif ($ahead -gt 0)                    { $upstream = '>' }
          elseif ($behind -gt 0)                   { $upstream = '<' }
          else                                     { $upstream = '=' }
        }

      $inner = "`e[32m$branch`e[0m$state$conflict"
        if ($dirty -or $upstream) { $inner += " $dirty$upstream" }
      return "($inner)"
    }finally{
      $global:LASTEXITCODE = $savedExitCode
    }
}
# disable cursor blink
Write-Host -n "`e[2 q"
function prompt {
  $prevOk=$global:?
  $prevCode=$global:LASTEXITCODE
  $err = 0
  if (-not $prevOk) {
    $err = if ($null -ne $prevCode -and $prevCode -ne 0) { $prevCode } else { 1 }
  }
  $time="`e[37m" + [DateTime]::Now.ToString("HH:mm") + "`e[0m" # white
  $currentPath=$ExecutionContext.SessionState.Path.CurrentLocation.Path
  if ($currentPath.StartsWith($HOME, [System.StringComparison]::OrdinalIgnoreCase)) {
    $dir="~" + $currentPath.Substring($HOME.Length).Replace('\', '/')
  } else {
    $dir=$currentPath.Replace('\', '/')
  }
  # sets terminal tab title
  $osc0="`e]0;$dir`e`\"
  # sets path for window/pane duplicate split
  $osc99="`e]9;9;$currentPath`e`\"
  # sets start of each prompt
  $osc133A="`e]133;A`e`\"
  $icon="`e[38;2;0;164;239m󰍲`e[0m"
  $dir="`e[1;32m$dir`e[0m" # bold green
  $git= Get-GitPromptString
  $code=""
  if ($err -ne 0) {
    $code="`e[31m($err)`e[0m" # red
  }
  return "$osc0$osc99$osc133A$icon $time $dir $git$_prompt_symbol$code "
}

if ([System.IO.Directory]::Exists([System.IO.Path]::Combine("$HOME", '.local', 'bin'))) {
  $env:PATH = "$localBin$([IO.Path]::PathSeparator)$env:PATH"
}

# support unicode for git-bash commands
$env:LANG='C.UTF-8'
# linux like config dir, set by system
$env:XDG_CONFIG_HOME="$HOME/.config"
# edit command in neovim: Ctrl-x Ctrl-e
$env:EDITOR='nvim'
# neovim: 'title', 'titlestring'
$env:TERM='xterm-256color'
$env:LESSHISTFILE="-" # disable ~/.lesshst
# disble node repl history log
$env:NODE_REPL_HISTORY=''
# suppress distro python repl history file write
$env:PYTHONSTARTUP="$HOME/.config/python/.pythonrc" # < 3.13
# $env:PYTHON_HISTORY='' # >= 3.13
$env:NPM_CONFIG_USERCONFIG="$HOME/.config/npm/.npmrc"

# === PSReadLine ===
Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates -PredictionSource `
History -PredictionViewStyle ListView `
-Colors @{
  Command="`e[1;32m";
  Emphasis="`e[1;33m";
  String="green";
  Operator="white";
  Parameter="`e[38;2;251;73;52;1m";
  Type="red"
}
# do not add to history if command starts with a space
Set-PSReadLineOption -AddToHistoryHandler {
param([string]$line)
  if ([string]::IsNullOrEmpty($line) -or $line[0] -eq ' ') {
    return $false
  }
  return $true
}
# copy lines to system clipboard, shift-j/up, shift-k/down to change selection
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+l' -Function CaptureScreen
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+y' -Function Copy
Set-PSReadLineKeyHandler -Chord 'Tab' -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+i' -Function Complete
Set-PSReadLineKeyHandler -Chord 'Ctrl+m' -Function AcceptLine

# === aliases ===
Set-Alias touch New-Item
Set-Alias n nvim
Set-Alias v nvim
Set-Alias g git

# === git-bash ===
# use windows/pwsh native:
# pwsh: gcb, scb, mv, cp
$GIT_BASE="$HOME/scoop/apps/git/current"
if(-not (Test-Path $GIT_BASE)){
  Write-Warning "pwsh `$PROFILE: Git not installed via scoop."
  return
}
$GIT_BIN="$GIT_BASE/bin"
$GIT_USR_BIN="$GIT_BASE/usr/bin"
$GIT_MINGW64_bin="$GIT_BASE/mingw64/bin"
$GitUsrCommands = @(
  'rm'    # -Force
  'rmdir' # -Force
  'tee'   # -Force
  'sort'  # -Force
  'cat'
  'cut'
  'less'
  'pwd'
  'file'
  'wc'
  'patch'
  'find'
  'sed'
  'awk'
  'head'
  'tail'
  'tr'
  #'xargs' # xargs is buggy in powershell
  #'unzip' # use scoop zip/unzip/zstd, git does not come with zip
  'gzip'
  'gunzip'
  'chmod'
  'du'
  'df'
  'date'
  'gpg'
  'gpg-connect-agent'
  'tty'
  'dos2unix'
  'unix2dos'
  #'md5sum'
  #'b2sum'
  'sha256sum'
  'sha512sum'
  'tar'
  # use Windows OpenSSH
  #'scp'
  #'sftp'
  #'ssh'
  #'ssh-add'
  #'ssh-keygen'
    )
foreach ($command in $GitUsrCommands) {
  Set-Alias -Name $command -Value "$GIT_USR_BIN/$command.exe" -Force
}
$GitMingwCommands = @(
  'xz'
  'unxz'
  #'bzip2'
  #'bunzip2'
)
foreach ($command in $GitMingwCommands) {
  Set-Alias -Name $command -Value "$GIT_MINGW64_BIN/$command.exe" -Force
}

# In Windows, 'tty' isn't used the same way;
# however, setting it via 'gpg-connect-agent' is the standard fix.
$env:GPG_TTY=$(tty).Trim()
# gpg-connect-agent updatestartuptty /bye | Out-Null

function config {
param(
  [Parameter(ValueFromRemainingArguments=$true)]
  [string[]]$Args
)
  & git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" @Args
}

function vv {
  & nvim --cmd "cd $HOME/.config/nvim"
}

# === fzf ===
Set-Alias f fzf
function t {
  if ($args.count) {
    z $args[0]
    return
  }
  $dir=cat "$HOME/.cdHistory" | sed 's/\.[0-9]\{20\}/ /' |
  & "$GIT_USR_BIN/sort.exe" -k '1,1' | fzf +s --tac --accept-nth='2'
  if ($dir) {
    cd "$dir"
  }
}
function fv {
  & fzf --multi --bind 'enter:become(nvim {+})'
}
function fkill {
  $id=Get-Process | fzf --header-lines='3' --accept-nth='-3'
  if($id){
    Stop-Process -Id $id
  }
}
# fzf keybindings
function fd-options{
  return @(
    '--hidden', '--color', 'never',
    '-E', '.git', '-E', 'node_modules', '-E', '.dotfiles',
    '-E', '.cache', '-E', '.local', '-E', 'AppData', '-E','scoop'
  )
}
function fzf-default-command {
  return "fd --type file $((fd-options) -join ' ')"
}
function fzf-default-opts {
  return @(
    "--with-shell='pwsh -NonInteractive -NoProfile -Command'",
    '--multi', '--reverse', '--cycle', "--height='40%'",
    "--info='inline'", '--no-separator', "--tiebreak='length,index'",
    "--preview='echo {}'", "--preview-window='right:100:wrap:cycle:hidden'",
    "--bind='alt-p:toggle-preview'",
    "--bind='alt-j:preview-half-page-down'",
    "--bind='alt-k:preview-half-page-up'",
    "--bind='alt-l:kill-line'",
    "--bind='alt-g:first'",
    "--bind='alt-G:last'",
    "--bind='alt-a:toggle-all'",
    "--bind='alt-s:toggle-sort'",
    "--bind='ctrl-y:execute-silent( `
    echo {} | Set-Clipboard)+change-header(Copied to clipboard!)'"
  )
}
$env:FZF_DEFAULT_COMMAND=fzf-default-command
$env:FZF_DEFAULT_OPTS=(fzf-default-opts) -join ' '
Set-PSReadLineKeyHandler -Chord 'Ctrl+t' -ScriptBlock {
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
  $FZF_CTRL_T_OPTS=@(
    '--preview', 'Get-Content {} -TotalCount 499',
    # '--bind', 'ctrl-v:become(nvim {})',
    '--bind', "ctrl-g:reload($(fzf-default-command) --no-ignore)"
  )
  $file = fzf @FZF_CTRL_T_OPTS
  if ($file) {
    # Use -join if multiple files are selected, or just insert
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert(($file -join " "))
  }
  Write-Host -n "`e[2 q"
}
Set-PSReadLineKeyHandler -Chord 'Alt+c' -ScriptBlock {
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
  $fdOptions = fd-options
  $dir = ''
  if (Get-Command fd) {
    $dir=fd --type directory @fdOptions | fzf
  }else{
    Write-Error "Error: fd not installed."
    return 1
  }
  if ($dir) {
    cd "$dir"
    [Microsoft.PowerShell.PSConsoleReadLine]::InvokePrompt()
  }
  Write-Host -n "`e[2 q"
}
Set-PSReadLineKeyHandler -Chord 'Alt+r' -Function ReverseSearchHistory
Set-PSReadLineKeyHandler -Chord 'Ctrl+r' -ScriptBlock {
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
  $FZF_CTRL_R_OPTS=(
    '--tac', '--no-sort',
    '--preview-window', 'up:3:hidden:wrap'
  )
  $target=(
  [Microsoft.PowerShell.PSConsoleReadLine]::GetHistoryItems()
  ).CommandLine | fzf @FZF_CTRL_R_OPTS
  if ($target) {
    [Microsoft.PowerShell.PSConsoleReadLine]::DeleteLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert($target)
  }
  Write-Host -n "`e[2 q"
}

# === git ===
function gs {
  & git status --short --branch $args
}

function git-log{
  & git log --oneline --graph $args
}
Set-Alias -Name gl -Value git-log -Force

function ga {
  if ($args.Count -gt 0) {
    git add $args
    return
  }
  $files = @(git ls-files -m | fzf --multi `
      --preview='git diff --color=always -- {}')
  if ($files.Count -gt 0) {
    git add $files
  }
}

# === colors ===
$BASH_LS="$GIT_USR_BIN/ls.exe"
function bash_ls {
  & "$BASH_LS" --color=auto --show-control-chars -F $args
}
function bash_ll {
  & "$BASH_LS" --color=auto --show-control-chars -atrhlF $args
}
function bash_la {
  & "$BASH_LS" --color=auto --show-control-chars -AF $args
}
function bash_l {
  & "$BASH_LS" --color=auto --show-control-chars -trhlF $args
}
Set-Alias -Name ls -Value bash_ls
Set-Alias -Name ll -Value bash_ll
Set-Alias -Name la -Value bash_la
Set-Alias -Name l -Value bash_l
function grep {
  $input | & "$GIT_USR_BIN/grep.exe" --color=auto $args
}
# side-by-side diff: diff -y FILE1 FILE2
function bash_diff {
  $input | & "$GIT_USR_BIN/diff.exe" --color=auto $args
}
Set-Alias -Name diff -Value bash_diff -Force

function which {
param(
  [Parameter(Mandatory=$true, Position=0)]
  [string]$Command
)
  $cmdInfo=Get-Command -Name $Command -ErrorAction SilentlyContinue
  if ($null -eq $cmdInfo) {
    return
  }
  switch ($cmdInfo.CommandType) {
    'Alias' {
      return "$($cmdInfo.Name) -> $($cmdInfo.Definition)"
    }
    'Function' {
      return $cmdInfo.Definition
    }
    'Filter' {
      return $cmdInfo.Definition
    }
    'Application' {
      return $cmdInfo.Source
    }
    'ExternalScript' {
      return $cmdInfo.Path
    }
    'Cmdlet' {
      return "Cmdlet: $($cmdInfo.Name) (Module: $($cmdInfo.ModuleName))"
    }
    Default {
      return $cmdInfo.Definition
    }
  }
}

function mkcd {
param(
  [Parameter(Mandatory=$true)]
  [string]$dir
)
  try {
    New-Item -ItemType Directory -Path $dir -ErrorAction Stop | Out-Null
    cd "$dir"
  }
  catch {
    Write-Error "Failed to create directory '$dir': $_"
  }
}

function tree {
param (
  [Parameter(ValueFromRemainingArguments=$true)]
  [string[]]$Paths
)
  if (-not $Paths) {
    $Paths=@(".")  # Default to current directory if no path is provided
  }
  foreach ($Path in $Paths) {
    & tree.com /f $Path
  }
}

function connect-wifi {
param(
  [Parameter(Position=0, ValueFromRemainingArguments=$true)]
  [string]$Ip
)
  $bash="$GIT_BIN/bash.exe"
  if (-not (Test-Path $bash)) {
    throw "Could not find Git Bash. Please ensure Git is installed."
  }
  $SCRIPT_PATH='~/.config/utils/connect-wifi.sh';
  if (-not $(Test-Path $SCRIPT_PATH)) {
    throw "Script not found: $SCRIPT_PATH"
  }
  $argString=if ($Ip) { "`"$Ip`"" } else { '' }
  Write-Verbose "Running: `"$bash`" -c `"$SCRIPT_PATH $argString`""
  & "$bash" -c "$SCRIPT_PATH $argString"
}

# delete: trash file-to-be-delected
# open: Start-Process shell:RecycleBinFolder
# cleanup: Clear-RecycleBin
function trash {
  <#
    .SYNOPSIS
        Moves files or directories to the Recycle Bin.
    .EXAMPLE
        trash "C:/Temp/old.txt" "C:/Logs/old_folder"
    #>
param(
  [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
  [string[]]$Paths
)
  # Load the assembly that provides access to the Recycle Bin API
  Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction SilentlyContinue
  foreach ($Path in $Paths) {
    # Expand relative paths to full paths for consistency
    $FullPath=Resolve-Path -LiteralPath $Path -ErrorAction SilentlyContinue
    if (-not $FullPath) {
      Write-Warning "Path not found: $Path"
      continue
    }
    $FullPath=$FullPath.Path
    if (Test-Path $FullPath -PathType Container) {
      Write-Host "Removing directory: $FullPath"
      try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
        $FullPath, 'OnlyErrorDialogs', 'SendToRecycleBin'
        )
      }
      catch {
        Write-Error "Failed to remove directory: $FullPath"
      }
    } elseif (Test-Path $FullPath -PathType Leaf) {
      Write-Host "Removing file: $FullPath"
      try {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
        $FullPath, 'OnlyErrorDialogs', 'SendToRecycleBin'
        )
      }
      catch {
        Write-Error "Failed to remove file: $FullPath"
      }
    } else {
      Write-Warning "Unknown path type: $FullPath"
    }
  }
}
# volta
# (& volta completions powershell) | Out-String | Invoke-Expression

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
# => If (Test-Path "$HOME/scoop/apps/miniconda3/current/Scripts/conda.exe") {
# =>   (& "$HOME/scoop/apps/miniconda3/current/Scripts/conda.exe" `
#        "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
# => }
#endregion
