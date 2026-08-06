export PATH=$HOME/bin/:$HOME/.cargo/bin/:$HOME/.local/bin/:$HOME/.local/share/nvim/mason/bin/:$HOME/go/bin/:$PATH
export ZSH="$HOME/.oh-my-zsh"

export VIRTUAL_ENV_DISABLE_PROMPT=1
export DOCKER_BUILDKIT=0

export DISABLE_AUTO_UPDATE="true" # Disable OMZ update check
export DISABLE_UPDATE_PROMPT="true" # Disable OMZ update prompt

export EDITOR="nvim"
export GIT_EDITOR="nvim"

ZSH_THEME="ritz"

plugins=(git copypath copyfile)

source $ZSH/oh-my-zsh.sh
source $HOME/python/bin/activate
source /usr/share/doc/pkgfile/command-not-found.zsh

alias so="source $HOME/.zshrc"
alias getcode="bash $HOME/scripts/getcode.sh"
alias getcode2="bash $HOME/scripts/getcode2.sh"
alias countline="bash $HOME/scripts/countline.sh"

alias "c=xclip -selection clipboard"
alias "v=xclip -selection clipboard -o"

export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock

# export TMPDIR=/mnt/nvme/tmp

# Example to add a cli completion
# mytool completion zsh > ~/.oh-my-zsh/custom/completions/_mytool
fpath=(~/.oh-my-zsh/custom/completions $fpath)

# Ollama functions
ai-commit() {
    # local model="llama3.1:8b"
    # local model="deepseek-coder:6.7b"
    # local model="gemma4:12b"
    local model="qwen2.5-coder:14b"
    # local model="qwen2.5-coder:7b"

    local prompt=$(cat ~/scripts/prompt/git-commit.prompt)

    local git_output=$(git --no-pager diff --cached)

    ollama run "${model}" "
    $prompt
    $git_output
    " | sed '/^```/d'
}

ai-documentation() {
    local input="$1"
    echo "Input: ${input}"

    # local model="llama3.1:8b"
    # local model="deepseek-coder:6.7b"
    # local model="gemma4:12b"
    local model="qwen2.5-coder:14b"
    # local model="qwen2.5-coder:7b"

        local prompt
    prompt=$(<~/scripts/prompt/rust-documentation.prompt)


    ollama run "${model}" "
$prompt
Here is the code:
$input
"
}
