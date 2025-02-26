# To customize history run nvim/code (Get-PSReadlineOption).HistorySavePath in powershell
# Get-InstalledModule: psreadline, z, terminal-icons (not used)

# enable UTF-8 to support unicode for git-bash commands
# e.g., ls, cat ...
$env:LANG="en_US.UTF-8"

# set env variable for use neovim in powershell
$env:XDG_CONFIG_HOME = "$HOME\.config"

# set EDITOR env variable for Ctrl-x Ctrl-e utility
$env:EDITOR = "nvim"
# enable neovim set title in powershell
$env:TERM = "xterm-256color"

# === REPL LOG ===
# disble node repl history log
$env:NODE_REPL_HISTORY=' '
# suppress python repl history file write
$env:PYTHONSTARTUP="$HOME/.config/python/.pythonrc"

# === starship ===
function Invoke-Starship-PreCommand {
    # windows title set to current path
    $title = if ($pwd.Path -ne $HOME) { (Get-Item -Path $pwd).BaseName } else { "~" }
    $prompt = "`e]0;$title`a"
    # enable duplicate pane or tab in wt
    $loc = $executionContext.SessionState.Path.CurrentLocation;
    $prompt += "$([char]27)]9;12$([char]7)"
    if ($loc.Provider.Name -eq "FileSystem")
    {
      $prompt += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
    }
    $host.ui.Write($prompt)
}
# change default location from "$HOME/.config/starship.toml"
$env:STARSHIP_CONFIG = "$HOME\.config\starship\starship.toml"
# warning and error logs
$env:STARSHIP_CACHE  = "$HOME\AppData\Local\Temp\starship"
Invoke-Expression (&starship init powershell)

# npm user config path: prefers lowercase
$env:npm_config_userconfig = "$HOME\.config\npm\.npmrc"

# === set alias ===
Set-Alias touch New-Item
Set-Alias v nvim
Set-Alias vi nvim
Set-Alias vim nvim
Set-Alias g git

# Some powershell builtin and windows provided commands:
# Get-Clipboard, Set-Clipboard or clip.exe
# tar (for archive and compress/uncompress to tar,gz,bz,zip files)
# scp (secure copy)
# sftp (secure file transfer protocal)
# aliases: mv, cp, cat, sort, tree /f, ...

$GIT_BIN_DIR = "$HOME\scoop\apps\git\current\usr\bin"
# === use git-bash provided binaries ===
# common file operations
Set-Alias cat "$GIT_BIN_DIR\cat.exe"
Set-Alias cut "$GIT_BIN_DIR\cut.exe"
# Set-Alias less "$GIT_BIN_DIR\less.exe"
Set-Alias file "$GIT_BIN_DIR\file.exe"
Set-Alias wc "$GIT_BIN_DIR\wc.exe"
# side-by-side diff: diff -y FILE1 FILE2
Set-Alias diff "$GIT_BIN_DIR\diff.exe" -Force
Set-Alias patch "$GIT_BIN_DIR\patch.exe"
Set-Alias tee "$GIT_BIN_DIR\tee.exe" -Force
Set-Alias grep "$GIT_BIN_DIR\grep.exe"
Set-Alias find "$GIT_BIN_DIR\find.exe"
Set-Alias sed "$GIT_BIN_DIR\sed.exe"
Set-Alias awk "$GIT_BIN_DIR\awk.exe"
Set-Alias head "$GIT_BIN_DIR\head.exe"
Set-Alias tail "$GIT_BIN_DIR\tail.exe"
Set-Alias tr "$GIT_BIN_DIR\tr.exe"
Set-Alias tar "$GIT_BIN_DIR\tar.exe"
# use scoop version instead
#Set-Alias zip "$GIT_BIN_DIR\zip.exe"
# Set-Alias unzip "$GIT_BIN_DIR\unzip.exe"
# Set-Alias gzip "$GIT_BIN_DIR\gzip.exe"
Set-Alias scp "$GIT_BIN_DIR\scp.exe"
Set-Alias sftp "$GIT_BIN_DIR\sftp.exe"
Set-Alias chmod "$GIT_BIN_DIR\chmod.exe"
Set-Alias du "$GIT_BIN_DIR\du.exe"
Set-Alias df "$GIT_BIN_DIR\df.exe"
Set-Alias date "$GIT_BIN_DIR\date.exe"
Set-Alias gpg "$GIT_BIN_DIR\gpg.exe"
Set-Alias gpgconf "$GIT_BIN_DIR\gpgconf.exe"
Set-Alias gpg-agent "$GIT_BIN_DIR\gpg-agent.exe"
Set-Alias gpg-connect-agent "$GIT_BIN_DIR\gpg-connect-agent.exe"
Set-Alias tty "$GIT_BIN_DIR\tty.exe"
# Set-Alias pinentry "$GIT_BIN_DIR\pinentry.exe"
# xargs is buggy in powershell
Set-Alias xargs "$GIT_BIN_DIR\xargs.exe"
Set-Alias bash_sort "$GIT_BIN_DIR\sort.exe"
# dos/unix file convertion
Set-Alias d2u "$GIT_BIN_DIR\dos2unix.exe"
Set-Alias u2d "$GIT_BIN_DIR\unix2dos.exe"
# checksum algorithms
Set-Alias md5sum "$GIT_BIN_DIR\md5sum.exe"
Set-Alias b2sum "$GIT_BIN_DIR\b2sum.exe"
Set-Alias sha1sum "$GIT_BIN_DIR\sha1sum.exe"
Set-Alias sha256sum "$GIT_BIN_DIR\sha256sum.exe"
Set-Alias sha512sum "$GIT_BIN_DIR\sha512sum.exe"

# === GPG ===
# enable-ssh-support
$env:SSH_AGENT_PID=''
$env:SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
$env:GPG_TTY=$(tty)
# & sh.exe -c 'gpg-connect-agent updatestartuptty /bye >/dev/null'

# -------------- one line config
Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates -PredictionSource History -PredictionViewStyle ListView -Colors @{Command = "`e[38;2;250;189;47;1m"; ContinuationPrompt = "`e[38;2;251;241;199;1m"; Emphasis = "`e[96;1m"; InlinePrediction = "#928374"; String = "`e[38;2;104;157;106;1m"; Operator = "`e[35m"; Parameter = "`e[38;2;251;73;52;1m"; Type = "`e[31m"}
# -------------- add to history if has trailing `;`
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    return $line.SubString($line.Length - 1) -ne ';'
}

# === utility ===
function which ($command){
    Get-Command -Name $command -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Definition -ErrorAction SilentlyContinue
}

function mkcd ([string] $path){
    New-Item -ItemType Directory -Path $path; Set-Location -Path $path
}

# alias for dotfiles
function config-public {
    & git --git-dir="$HOME\.dotfiles-public\" --work-tree="$HOME" $args
}

function gs {
    & git status $args
}

function git_log{
    & git lo $args
}

Set-Alias -Name gl -Value git_log -Option Private -Force

function t {
    & tree /f $args
}

function todo {
    & nvim "$HOME\dev\TODO.md"
}
Set-Alias -Name tl -Value todo -Option Private

function vv {
    & nvim --cmd "cd ~/.config/nvim"
}

function vd {
    cd "$HOME/AppData/Local/nvim-data/"
}

# ls aliases
$BASH_LS_PATH = "$GIT_BIN_DIR\ls.exe"

function gitbash_ls {
    & "$BASH_LS_PATH" --color=auto --show-control-chars -F $args
}
function gitbash_ll {
    & "$BASH_LS_PATH" --color=auto --show-control-chars -atrhlF $args
}
function gitbash_la {
    & "$BASH_LS_PATH" --color=auto --show-control-chars -AF $args
}
function gitbash_l {
    & "$BASH_LS_PATH" --color=auto --show-control-chars -trhlF $args
}
Set-Alias -Name ls -Value gitbash_ls -Option Private
Set-Alias -Name ll -Value gitbash_ll -Option Private
Set-Alias -Name la -Value gitbash_la -Option Private
Set-Alias -Name l -Value gitbash_l -Option Private

# === FZF ===
Set-Alias f fzf
function vf {
  & nvim $(fzf)
}

function j {
  if ($args.count) {
    z $args[0]
    return
  }
  $dir=cat "$HOME\.cdHistory" | sed 's/\.[0-9]\{20\}/ /' | bash_sort -k '1,1' `
  | fzf --height 40% --reverse --inline-info +s --tac --query "${*##-* }" `
  | sed 's/^[0-9]* *//'

  if ($dir) {
      cd "$dir"
  }
}

function Remove-Item-ToRecycleBin($Path) {
    $item = Get-Item -Path $Path -ErrorAction SilentlyContinue
    if ($null -eq $item)
    {
        Write-Error("'{0}' not found" -f $Path)
    }
    else
    {
        $fullpath=$item.FullName
        Write-Verbose ("Moving '{0}' to the Recycle Bin" -f $fullpath)
        if (Test-Path -Path $fullpath -PathType Container)
        {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($fullpath,'OnlyErrorDialogs','SendToRecycleBin')
        }
        else
        {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($fullpath,'OnlyErrorDialogs','SendToRecycleBin')
        }
    }
}
Set-Alias trash Remove-Item-ToRecycleBin

# CaptureScreen is good for blog posts or email showing a transaction
# of what you did when asking for help or demonstrating a technique.
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+c' -Function CaptureScreen
# Copy selected region to the system clipboard. If no region is selected, copy the whole line.
Set-PSReadLineKeyHandler -Chord 'Ctrl+x,Ctrl+y' -Function Copy
Set-PSReadLineKeyHandler -Chord 'Tab' -Function MenuComplete
Set-PSReadLineKeyHandler -Chord 'Ctrl+i' -Function Complete
Set-PSReadLineKeyHandler -Chord 'Ctrl+m' -Function AcceptLine
