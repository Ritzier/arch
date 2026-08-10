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
    # Check if there are staged changes
    if ! git diff --cached --quiet 2>/dev/null; then
        echo "❌ No staged changes found. Use 'git add' to stage files first."
        return 1
    fi
    
    # local model="llama3.1:8b"
    # local model="deepseek-coder:6.7b"
    # local model="gemma4:12b"
    local model="qwen2.5-coder:14b"
    # local model="qwen2.5-coder:7b"

    local prompt=$(cat ~/scripts/prompt/git-commit.prompt)
    if [[ -n "$1" ]]; then
        prompt="${prompt}

Additional instruction: $*"
    fi

    local git_output=$(git --no-pager diff --cached)

    ollama run "${model}" "
    $prompt
    $git_output
    " | sed '/^```/d'
}

# ==============================================================================
# AI Code Refactoring Helper (`ai-prompt`)
#
# Description:
#   Pipes standard input (e.g., source code) through Ollama using a custom prompt 
#   template based on the specified language/extension.
#
# Prerequisites:
#   1. Store prompt templates under: ~/.config/scripts/prompt/language/ (or ~/scripts/prompt/language/)
#      Supported naming: <lang>, <lang>.txt, <lang>.md, or <lang>.prompt (e.g., bash.md, python.txt)
#   2. Ensure Ollama is installed and running locally.
#
# Usage:
#   cat code.sh | ai-prompt bash
#   git diff main | ai-prompt python
# ==============================================================================
ai-prompt() {
    # ----------------
    # Input validation
    # ----------------
    # Require piped standard input (fail if running interactively in terminal)
    if [[ -t 0 ]]; then
        echo "Error: No standard input detected. Usage: cat file | ai-prompt <language>" >&2
        return 1
    fi

    # Require target language / extension argument
    local lang="${1:-}"
    if [[ -z "$lang" ]]; then
        echo "Error: Please specify a prompt language (e.g., ai-prompt bash)" >&2
        return 1
    fi

    # ----------------
    # Configuration
    # ----------------
    local model="qwen2.5-coder:14b"
    local prompt_dir="${HOME}/scripts/prompt/language"
    local input
    input=$(cat)

    # ----------------
    # Resolve prompt file
    # ----------------
    # Search for matching template with supported extensions
    local prompt_file=""
    for ext in "" ".txt" ".md" ".prompt"; do
        if [[ -f "${prompt_dir}/${lang}${ext}" ]]; then
            prompt_file="${prompt_dir}/${lang}${ext}"
            break
        fi
    done

    # Abort if no matching prompt template exists
    if [[ -z "$prompt_file" ]]; then
        echo "Error: Prompt file for '${lang}' not found under ${prompt_dir}" >&2
        return 1
    fi

    local prompt
    prompt=$(cat "$prompt_file")

    # ----------------
    # Execute LLM inference
    # ----------------
    ollama run "${model}" "
${prompt}

Here is the code:
${input}
"
}
