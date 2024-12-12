#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的信息函数
print_message() {
    echo -e "${GREEN}=== $1 ===${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

print_error() {
    echo -e "${RED}ERROR: $1${NC}"
}

# 检查命令是否执行成功
check_success() {
    if [ $? -eq 0 ]; then
        print_message "$1 成功"
    else
        print_error "$1 失败"
        exit 1
    fi
}

# 1. 安装 Xcode Command Line Tools
print_message "检查并安装 Xcode Command Line Tools"
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    check_success "安装 Xcode Command Line Tools"
fi

# 2. 安装 Homebrew
print_message "检查并安装 Homebrew"
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    check_success "安装 Homebrew"
    
    # 对于 M1/M2 Mac，需要添加 Homebrew 到 PATH
    if [[ $(uname -m) == 'arm64' ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# 3. 安装 iTerm2
print_message "安装 iTerm2"
brew install --cask iterm2
check_success "安装 iTerm2"

# 4. 安装并配置 Oh My Zsh
print_message "安装 Oh My Zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    check_success "安装 Oh My Zsh"
fi

# 5. 安装 Zsh 插件
print_message "安装 Zsh 插件"
# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# 6. 安装 Node.js 版本管理器 (nvm)
print_message "安装 nvm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 7. 安装 Golang 版本管理器 (gvm)
print_message "安装 gvm"
bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)

# 8. 安装 Java 版本管理器 (jEnv)
print_message "安装 jEnv"
brew install jenv

# 9. 安装 Java (采用 Temurin JDK)
print_message "安装 Java"
brew install --cask temurin17 # JDK 17 LTS
brew install --cask temurin11 # JDK 11 LTS
brew install --cask temurin8  # JDK 8 LTS

# 10. 安装构建工具
print_message "安装构建工具"
brew install maven
brew install gradle

# 11. 配置 Zsh
print_message "配置 Zsh"
# 备份现有的 .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup"
fi

# 创建新的 .zshrc
cat > "$HOME/.zshrc" << 'EOL'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    kubectl
    macos
    node
    npm
    golang
    mvn
    gradle
)

source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8

# nvm configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# gvm configuration
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# jEnv configuration
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# Go configuration
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Aliases
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# Node.js aliases
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'

# Go aliases
alias gr='go run'
alias gt='go test'
alias gmt='go mod tidy'

# Java aliases
alias mvnc='mvn clean'
alias mvni='mvn install'
alias mvnp='mvn package'
alias mvnt='mvn test'
alias gw='./gradlew'
alias gwb='./gradlew build'
alias gwc='./gradlew clean'

EOL

# 12. 配置 Git
print_message "配置 Git"
read -p "请输入你的 Git 用户名: " git_username
read -p "请输入你的 Git 邮箱: " git_email

git config --global user.name "$git_username"
git config --global user.email "$git_email"
git config --global core.editor "vim"
git config --global init.defaultBranch main
git config --global pull.rebase false

# 13. 生成 SSH Key
print_message "生成 SSH Key"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519" -N ""
    check_success "生成 SSH Key"
    
    eval "$(ssh-agent -s)"
    
    if [ ! -f "$HOME/.ssh/config" ]; then
        cat > "$HOME/.ssh/config" << EOL
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOL
    fi
    
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519
    
    print_message "你的 SSH 公钥如下，请添加到 GitHub:"
    cat "$HOME/.ssh/id_ed25519.pub"
fi

# 14. 安装其他常用工具
print_message "安装常用工具"
brew install \
    wget \
    tree \
    jq \
    htop \
    tldr \
    ripgrep \
    fd

# 15. 初始化开发环境
print_message "初始化开发环境"

# 安装 Node.js LTS 版本
print_message "安装 Node.js LTS 版本"
source ~/.nvm/nvm.sh
nvm install --lts
nvm use --lts
npm install -g yarn pnpm typescript ts-node

# 安装 Go
print_message "安装 Go"
source ~/.gvm/scripts/gvm
gvm install go1.21
gvm use go1.21 --default

# 配置 Java 环境
print_message "配置 Java 环境"
jenv add /Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/temurin-11.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/temurin-8.jdk/Contents/Home
jenv global 17

print_message "完成安装！"
print_warning "请执行以下操作完成配置："
echo "1. 重启 iTerm2"
echo "2. 执行 'source ~/.zshrc' 来加载新的配置"
echo "3. 检查各个开发环境："
echo "   - Node.js: node --version"
echo "   - Go: go version"
echo "   - Java: java -version"
echo "4. 将显示的 SSH 公钥添加到你的 GitHub 账号中"

# 16. 配置 npm registry (可选，取消注释即可使用)
# print_message "配置 npm registry 为淘宝镜像"
# npm config set registry https://registry
