# History file: `nvim (Get-PSReadlineOption).HistorySavePath`
# PSReadLine: Get-Module PSReadLine -ListAvailable
# z: Install-Module -Name z`

$localBin=Join-Path $HOME ".local/bin"
if (Test-Path $localBin) {
  $pathEntries = $env:PATH -split [IO.Path]::PathSeparator

  if ($localBin -notin $pathEntries) {
    $env:PATH = "$localBin$([IO.Path]::PathSeparator)$env:PATH"
  }
}

# === ENV ===
# support unicode for git-bash commands: ls, cat, etc.
$env:LANG='C.UTF-8'
# linux like config dir, set by system
$env:XDG_CONFIG_HOME="$HOME/.config"
# edit command in neovim: Ctrl-x Ctrl-e
$env:EDITOR='nvim'
# neovim: @see :help 'title', 'titlestring'
$env:TERM='xterm-256color'
$env:LESSHISTFILE="-" # disable ~/.lesshst
# disble node repl history log
$env:NODE_REPL_HISTORY=''
# suppress distro python repl history file write
$env:PYTHONSTARTUP="$HOME/.config/python/.pythonrc" # < 3.13
# $env:PYTHON_HISTORY='' # >= 3.13
$env:NPM_CONFIG_USERCONFIG="$HOME/.config/npm/.npmrc"

$GitPromptCache = @{
  Root       = $null
  IndexStamp = $null
  HeadStamp  = $null
  Branch     = $null
  State      = ''
}
function Get-GitPrompt {
  $root = git rev-parse --show-toplevel 2>$null
  if (-not $root) {
    $GitPromptCache.Root = $null
    return ''
  }

  $gitDir = git rev-parse --git-dir 2>$null
  $index  = Join-Path $gitDir 'index'
  $head   = Join-Path $gitDir 'HEAD'

  $indexStamp = if (Test-Path $index) {
    (Get-Item $index).LastWriteTimeUtc.Ticks
  } else {
    0
  }

  $headStamp = if (Test-Path $head) {
    (Get-Item $head).LastWriteTimeUtc.Ticks
  } else {
    0
  }

  $cache = $GitPromptCache
  if (
    $cache.Root -ne $root -or
    $cache.IndexStamp -ne $indexStamp -or
    $cache.HeadStamp -ne $headStamp
  ) {
    $branch = git branch --show-current 2>$null
    $status = git status --porcelain 2>$null
    $state = ''
    if ($status | Where-Object { $_[0] -ne ' ' }) {
      $state += '+'
    }
    if ($status | Where-Object { $_[1] -ne ' ' }) {
      $state += '*'
    }

    $cache.Root       = $root
    $cache.IndexStamp = $indexStamp
    $cache.HeadStamp  = $headStamp
    $cache.Branch     = $branch
    $cache.State      = $state
  }

  if ($cache.Branch) {
    return "${cYellow}($($cache.Branch)$($cache.State))"
  }
  return ''
}
# disable standard venv prompt hijacking
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1
# turn off cursor blink
Write-Host "`e[?12l" -NoNewline
function prompt {
  $origDollarQuestion=$global:?
  $origLastExitCode=$global:LASTEXITCODE

  $cReset="`e[0m"
  $cWhite="`e[37m"
  $cGreen="`e[32m"
  $cYellow="`e[33m"
  $cBlue="`e[38;2;0;164;239m"
  $cRed="`e[31m"

  $time=[DateTime]::Now.ToString("HH:mm")

  $admin=""
  if ($null -eq $global:IsAdmin) {
    $global:IsAdmin=([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  }
  if ($global:IsAdmin) {
    $admin="${cRed}Administrator:"
  }

  $ssh=""
  $isSsh=$null -ne $env:SSH_CONNECTION
  if ($isSsh) {
    $ssh="${cGreen}$($env:USERNAME)@$($env:computername):"
  }

  $currentPath=$ExecutionContext.SessionState.Path.CurrentLocation.Path
  if ($currentPath.StartsWith($HOME,
  [System.StringComparison]::OrdinalIgnoreCase)) {
    $dir="~" + $currentPath.Substring($HOME.Length).Replace('\', '/')
  } else {
    $dir=$currentPath.Replace('\', '/')
  }

  # OSC9;9: tell terminal CWD for duplicate pane
  # also sets terminal tab title
  $title="`e]0;$dir`a`e]9;12`a`e]9;9;$currentPath`e\"


  $git=Get-GitPrompt

  $venv = ""
  if ($env:VIRTUAL_ENV) {
    $venvName = [System.IO.Path]::GetFileName($env:VIRTUAL_ENV)
    if ($venvName -match '^(\.venv|venv|\.env|env)$') {
      $parentPath = [System.IO.Path]::GetDirectoryName($env:VIRTUAL_ENV)
        $venvName = [System.IO.Path]::GetFileName($parentPath)
    }
    $venv = "${cBlue}($venvName)${cReset}"
  }

  $lastExitCodeForPrompt=0
  if ($lastCmd=Get-History -Count 1) {
    # In case we have a False on the Dollar hook, we know there's an error.
    if (-not $origDollarQuestion) {
      # We retrieve the InvocationInfo from the most recent error using
      # $global:error[0]
      $lastCmdletError=try {
        $global:error[0] |  Where-Object { $_ -ne $null } |
        Select-Object -ExpandProperty InvocationInfo } catch { $null }
      # We check if the last command executed matches the line that caused the
      # last error, in which case we know it was an internal Powershell
      # command, otherwise, there MUST be an error code.
      $lastExitCodeForPrompt=if ($null -ne $lastCmdletError -and
      $lastCmd.CommandLine -eq $lastCmdletError.Line)
      { 1 } else { $origLastExitCode }
    }
  }
  if ($lastExitCodeForPrompt -ne 0) {
    $symbol="${cRed}${cReset}"
  }else {
    $symbol="${cWhite}`$${cReset}"
  }
  # Propagate the original $LASTEXITCODE from before the prompt function was
  # invoked.
  $global:LASTEXITCODE=$origLastExitCode

  # Propagate the original $? automatic variable value from before the prompt
  # function was invoked.
  #
  # $? is a read-only or constant variable so we can't directly override it. In
  # order to propagate up its original boolean value we will take an action
  # which will produce the desired value.
  #
  # This has to be the very last thing that happens in the prompt function
  # since every PowerShell command sets the $? variable.
  if ($global:? -ne $origDollarQuestion) { if ($origDollarQuestion) {
    # Simple command which will execute successfully and set $?=True without
    # any other side affects.
    1+1 } else {
      # Write-Error will set $? to False. ErrorAction Ignore will prevent the
      # error from being added to the $Error collection.
      Write-Error '' -ErrorAction 'Ignore'
    }
  }

  return "$title${cBlue}󰍲 ${cWhite}$time $admin$ssh${cGreen}$dir $git$venv$symbol "
}

# === aliases ===
Set-Alias touch New-Item
Set-Alias n nvim
Set-Alias v nvim
Set-Alias vi nvim
Set-Alias vim nvim
Set-Alias g git

# === GIT BASH ===
# use windows/pwsh native:
# pwsh: gcb, scb, mv, cp
# aliases: mv, cp
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

# === PSReadLine ===
# Import-Module PSReadLine
# Set-PSReadLineOption -EditMode Emacs # Windows, Vi
Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates -PredictionSource `
History -PredictionViewStyle ListView `
-Colors @{
  Command="`e[38;2;250;189;47;1m";
  ContinuationPrompt="`e[38;2;251;241;199;1m";
  Emphasis="`e[96;1m";
  InlinePrediction="#928374";
  String="`e[38;2;104;157;106;1m";
  Operator="`e[35m";
  Parameter="`e[38;2;251;73;52;1m";
  Type="`e[31m"
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
# Copy selected region to the system clipboard.
# If no region is selected, copy the whole line.
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+y' -Function Copy
Set-PSReadLineKeyHandler -Chord 'Tab' -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+i' -Function Complete
Set-PSReadLineKeyHandler -Chord 'Ctrl+m' -Function AcceptLine

# === FZF ===
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
  # Fix cursor blinking
  Write-Host "`e[?12l" -NoNewline
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
  # Fix cursor blinking
  Write-Host "`e[?12l" -NoNewline
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
  # Fix cursor blinking
  Write-Host "`e[?12l" -NoNewline
}

# === Utilities ===
# git alias for dotfiles
function config {
param(
    [Parameter(ValueFromRemainingArguments=$true)]
    [string[]]$Args
  )
  & git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" @Args
}

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
      # Example: v -> nvim
      return "$($cmdInfo.Name) -> $($cmdInfo.Definition)"
    }
    'Function' {
      # Returns the actual script block code
      return $cmdInfo.Definition
    }
    'Filter' {
      # Special type of function
      return $cmdInfo.Definition
    }
    'Application' {
      # Returns the full path to the .exe
      return $cmdInfo.Source
    }
    'ExternalScript' {
      # Returns the path to the .ps1 file
      return $cmdInfo.Path
    }
    'Cmdlet' {
      # Prints name and the module it came from
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
    # Try to create the directory
    New-Item -ItemType Directory -Path $dir -ErrorAction Stop | Out-Null
    # If successful, change into it
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

function todo {
  & nvim "$HOME/dev/TODO.md"
}

function vv {
  & nvim --cmd "cd $HOME/.config/nvim"
}
function vd {
  cd "$HOME/AppData/Local/nvim-data/"
}

# === Git ===
function gs {
  & git status --short --branch $args
}
function git-log{
  & git l $args
}
Set-Alias -Name gl -Value git-log -Force

function ga {
  if ($args.Count -gt 0) {
    git add $args
  }
  else {
    $files = @(git ls-files -m | fzf --multi `
      --preview='git diff --color=always -- {}')

    if ($files.Count -gt 0) {
      git add $files
      Write-Host ($files -join "`n")
    }
  }
}

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

# === FZF Aliases ===
Set-Alias f fzf

function vf {
  $files=fzf --multi

  if ($files) {
    # Open multiple files in Neovim tabs (-p)
    nvim -p $files
  }
}

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

function fkill {
  $id=Get-Process | fzf --header-lines='3' --accept-nth='-3'
  if($id){
    Stop-Process -Id $id
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

  # Build argument string safely
  $argString=if ($Ip) { "`"$Ip`"" } else { '' }
  Write-Verbose "Running: `"$bash`" -c `"$SCRIPT_PATH $argString`""

  # Run the shell script
  & "$bash" -c "$SCRIPT_PATH $argString"
}

# trash file-to-be-delected
# Start-Process shell:RecycleBinFolder
# Clear-RecycleBin
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
