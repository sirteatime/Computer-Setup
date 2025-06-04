# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load Plugins
# https://github.com/mattmc3/zsh_unplugged - Build your own zsh plugin manager


# _pluginload_: Function which loads a specified plugin into my zsh environment
_pluginload_() {
    local giturl="$1"
    local plugin_name=${${1##*/}%.git}
    local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}/${plugin_name}"

    # Clone repository for the plugin if isn't there already
    if [[ ! -d ${plugindir} ]]; then
        command git clone --depth 1 --recursive --shallow-submodules ${giturl} ${plugindir}
        [[ $? -eq 0 ]] || { >&2 echo "plugin-load: git clone failed; $1" && return 1 }
    fi

    # Symlink an init.zsh if there isn't one so the plugin is easy to source
    if [[ ! -f ${plugindir}/init.zsh ]]; then
        local initfiles=(
          # look for specific files first
          ${plugindir}/${plugin_name}.plugin.zsh(N)
          ${plugindir}/${plugin_name}.zsh(N)
          ${plugindir}/${plugin_name}(N)
          ${plugindir}/${plugin_name}.zsh-theme(N)
          # then do more aggressive globbing
          ${plugindir}/*.plugin.zsh(N)
          ${plugindir}/*.zsh(N)
          ${plugindir}/*.zsh-theme(N)
          ${plugindir}/*.sh(N)
        )
        [[ ${#initfiles[@]} -gt 0 ]] || { >&2 echo "plugin-load: no plugin init file found" && return 1 }
        command ln -s ${initfiles[1]} ${plugindir}/init.zsh
    fi

    # source the plugin to make it active in the current environment
    source ${plugindir}/init.zsh

    # Modify the path to include the plugin directory
    fpath+=${plugindir}
    [[ -d ${plugindir}/functions ]] && fpath+=${plugindir}/functions
}

# Set where we should store Zsh plugins
ZPLUGINDIR=${HOME}/.zsh/plugins

# Add your plugins to this array. Anything added here will be installed.
plugins=(
    # core plugins
    # ######################
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-completions

    # # user plugins
    # ######################
    peterhurford/up.zsh                 # Cd to parent directories (ie. up 3)
    marlonrichert/zsh-hist              # Run hist -h for help
    reegnz/jq-zsh-plugin                # Write interactive jq queries (Requires jq and fzf)
    MichaelAquilina/zsh-you-should-use  # Recommends aliases when typed
    rupa/z                              # Tracks your most used directories, based on 'frequency'

    # Additional completions
    # ######################
    sudosubin/zsh-github-cli
    zpm-zsh/ssh

    # Prompts
    # ######################
    # denysdovhan/spaceship-prompt
    romkatv/powerlevel10k

    # load these last
    # ######################
    # zsh-users/zsh-syntax-highlighting
    zdharma-continuum/fast-syntax-highlighting
    zsh-users/zsh-history-substring-search
)

# Add plugins to this array that should only be installed on a computer running MacOS.
mac_plugins=(
      ellie/atuin  # Replace history search with a sqlite database
)

# Load your plugins (clone, source, and add to fpath)
for repo in ${plugins[@]}; do
  _pluginload_ https://github.com/${repo}.git
done
unset repo

# Load Mac specific plugins (clone, source, and add to fpath)
if [[ ${OSTYPE} == "darwin"* ]]; then
  for mac_repo in ${mac_plugins[@]}; do
    _pluginload_ https://github.com/${mac_repo}.git
  done
  unset mac_repo
fi

# Run this function from time-to-time to update the plugins installed on a computer
function zshup () {
  local plugindir="${ZPLUGINDIR:-$HOME/.zsh/plugins}"
  for d in $plugindir/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

# Load Completions
#############################################
autoload -Uz compinit
compinit -i

# CONFIGURE PLUGINS
#############################################
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=242' # Use a lighter gray for the suggested text
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE="20"
FAST_HIGHLIGHT[use_brackets]=1

# Set Options
#############################################
setopt always_to_end          # When completing a word, move the cursor to the end of the word
setopt append_history         # this is default, but set for share_history
setopt auto_cd                # cd by typing directory name if it's not a command
setopt auto_list              # automatically list choices on ambiguous completion
setopt auto_menu              # automatically use menu completion
setopt auto_pushd             # Make cd push each old directory onto the stack
setopt completeinword         # If unset, the cursor is set to the end of the word
setopt correct_all            # autocorrect commands
setopt extended_glob          # treat #, ~, and ^ as part of patterns for filename generation
setopt extended_history       # save each command's beginning timestamp and duration to the history file
setopt glob_dots              # dot files included in regular globs
setopt hash_list_all          # when command completion is attempted, ensure the entire  path is hashed
setopt hist_expire_dups_first # # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_find_no_dups      # When searching history don't show results already cycled through twice
setopt hist_ignore_dups       # Do not write events to history that are duplicates of previous events
setopt hist_ignore_space      # remove command line from history list when first character is a space
setopt hist_reduce_blanks     # remove superfluous blanks from history items
setopt hist_verify            # show command with history expansion to user before running it
setopt histignorespace        # remove commands from the history when the first character is a space
setopt inc_append_history     # save history entries as soon as they are entered
setopt interactivecomments    # allow use of comments in interactive code (bash-style comments)
setopt longlistjobs           # display PID when suspending processes as well
setopt no_beep                # silence all bells and beeps
setopt nocaseglob             # global substitution is case insensitive
setopt nonomatch              ## try to avoid the 'zsh: no matches found...'
setopt noshwordsplit          # use zsh style word splitting
setopt notify                 # report the status of backgrounds jobs immediately
setopt numeric_glob_sort      # globs sorted numerically
setopt prompt_subst           # allow expansion in prompts
setopt pushd_ignore_dups      # Don't push duplicates onto the stack
setopt share_history          # share history between different instances of the shell
HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000
SAVEHIST=${HISTSIZE}

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
