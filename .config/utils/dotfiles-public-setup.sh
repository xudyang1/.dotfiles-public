#!/usr/bin/bash -e

BOLD='\033[1m'
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
CYAN='\033[36m'
NC='\033[0m' # No Color

WARNING_MSG=$(
  cat <<-EOF
${BOLD}${YELLOW}WARNING:${NC}
${BOLD}${CYAN}=== Windows PUBLIC Dotfiles ===${NC}
This script is intended to set up a new ${BOLD}${CYAN}Windows system${NC}.
You should run this script only ${BOLD}${YELLOW}once${NC} for the new Windows.
Do you still want to run this script?
Type ${BOLD}${RED}YES${NC} to continue: 
EOF
)
echo -e -n "$WARNING_MSG"
read -r -p '' CONFIRM

if [[ ${CONFIRM} != 'YES' ]]; then
  echo -e "${BOLD}${GREEN}Safely stop and exit.${NC}"
  exit 0
fi

if [[ -z $HOME ]]; then
  echo -e "${BOLD}${RED}\$HOME environment variable not set. Abort!"
  exit 1
fi

REMOTE_REPO_URL="https://github.com/xudyang1/.dotfiles-public.git"
LOCAL_REPO_DIR="$HOME/.dotfiles-public"
CHECKOUT_BRANCH="main"
BACKUP_DIR="$HOME/.dotfiles-public-backup"

if [[ -d $LOCAL_REPO_DIR ]]; then
  echo -e "${BOLD}${YELLOW}Directory $LOCAL_REPO_DIR already exist. Skip git clone dotfiles repo $REMOTE_REPO_URL.${NC}"
else
  echo -e "${BOLD}${CYAN}Cloning bare repo $REMOTE_REPO_URL to $LOCAL_REPO_DIR...${NC}"
  git clone --bare "$REMOTE_REPO_URL" "$LOCAL_REPO_DIR"
fi

config="git --git-dir=$LOCAL_REPO_DIR --work-tree=$HOME"

if $config checkout "$CHECKOUT_BRANCH"; then
  echo -e "${BOLD}${GREEN}COMMAND SUCCESS:${NC} config checkout $CHECKOUT_BRANCH"
else
  COMMAND_MSG=$(
    cat <<-EOF

${BOLD}${RED}COMMAND FAILED:${NC} config checkout $CHECKOUT_BRANCH
Git prevents overwritting files \$(${BOLD}config checkout 2>&1 | head -n -2 | tail -n +2 | awk '{print \$1}'${NC}):
${BOLD}${YELLOW}$($config checkout 2>&1 | head -n -2 | tail -n +2 | awk '{print $1}')${NC}
${BOLD}${RED}COMMAND:${NC}
config checkout 2>&1 | head -n -2 | tail -n +2 | awk '{print \$1}' | xargs -I{} bash -c "mkdir -p $BACKUP_DIR/\$(dirname {}) && mv -nv {} $BACKUP_DIR/{}"
${BOLD}${CYAN}will move those files into${NC} $BACKUP_DIR.
Type ${BOLD}${YELLOW}YES${NC} to run the command: 
EOF
  )
  echo -e -n "$COMMAND_MSG"
  read -r -p '' CONFIRM_MOVE
  if [[ $CONFIRM_MOVE == 'YES' ]]; then
    if $config checkout 2>&1 | head -n -2 | tail -n +2 | awk '{print $1}' | xargs -I{} bash -c "mkdir -p $BACKUP_DIR/\$(dirname {}) && mv -nv {} $BACKUP_DIR/{}"; then
      echo -e "${BOLD}${GREEN}SUCCESS:${NC} old dotfiles are moved to $BACKUP_DIR"
      echo -e "${BOLD}${CYAN}Try checkout $CHECKOUT_BRANCH again...${NC}"
      if $config checkout $CHECKOUT_BRANCH; then
        echo -e "${BOLD}${GREEN}SUCCESS:${NC} config checkout $CHECKOUT_BRANCH"
      else
        echo -e "${BOLD}${RED}FAILED:${NC} config checkout $CHECKOUT_BRANCH. ${BOLD}${RED}ABORT!${NC}"
        exit 1
      fi
    else
      echo -e "${BOLD}${RED}FAILED:${NC} error occured when moving old dotfiles to $BACKUP_DIR. ${BOLD}${RED}ABORT!${NC}"
      exit 1
    fi
  else
    echo -e "${BOLD}${CYAN}Continue without \$(config checkout $CHECKOUT_BRANCH)...${NC}"
  fi
fi
echo -e "${BOLD}${CYAN}Try recursively clone submodules in dotfiles...${NC}"
$config submodule update --init --recursive

FONTS="FiraCode"
# FONTS=("FiraCode" "ComicShannsMono")
for FONT in "${FONTS[@]}"; do
  FONT_FILE="$FONT.tar.xz"
  FONT_DIR="$HOME/fonts/$FONT"
  echo -e "${BOLD}${CYAN}Downloading nerd font: $FONT_FILE${NC}"
  curl --create-dirs --output-dir "$FONT_DIR" -LO "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$FONT_FILE"
  tar -xvJf "$FONT_DIR/$FONT_FILE" -C "$FONT_DIR"
  echo -e "Nerd font $FONT_FILE is downloaded to ${BOLD}${GREEN}$FONT_DIR${NC}. Please install the fonts manually."
done

echo -e "${BOLD}${GREEN}Setup finished. Please check the log output for details.${NC}"

echo -e "${BOLD}${CYAN}Post Installation: run the following commands if needed.${NC}"
echo -e "${BOLD}Downloading tools by scoop${NC}: scoop import \$HOME/.config/scoop/scoopfile.json"
echo -e "${BOLD}Update Windows Terminal's settings.json${NC}: cp \$HOME/.config/wt/settings.json \$HOME/scoop/apps/windows-terminal-preview/settings/settings.json"
echo -e "${BOLD}Install pwsh modules${NC}: pwsh -NoProfile -Command 'Install-Module -Name z -Force'"
