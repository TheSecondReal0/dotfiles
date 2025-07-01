# FreeAgent puts the powerline style in zsh !

if [ "$POWERLINE_DATE_FORMAT" = "" ]; then
  POWERLINE_DATE_FORMAT=%D{%Y-%m-%d}
fi

if [ "$POWERLINE_RIGHT_B" = "" ]; then
  POWERLINE_RIGHT_B=%D{%H:%M:%S}
elif [ "$POWERLINE_RIGHT_B" = "none" ]; then
  POWERLINE_RIGHT_B=""
fi

POWERLINE_EXIT_STATUS_ON_FAIL=%(?..%F{red}✘ %?)

if [ "$POWERLINE_RIGHT_A" = "mixed" ]; then
  POWERLINE_RIGHT_A=%(?."$POWERLINE_DATE_FORMAT".%F{red}✘ %?)
elif [ "$POWERLINE_RIGHT_A" = "exit-status" ]; then
  POWERLINE_RIGHT_A=%(?.%F{green}✔ %?.%F{red}✘ %?)
elif [ "$POWERLINE_RIGHT_A" = "exit-status-on-fail" ]; then
  POWERLINE_RIGHT_A=$POWERLINE_EXIT_STATUS_ON_FAIL
elif [ "$POWERLINE_RIGHT_A" = "date" ]; then
  POWERLINE_RIGHT_A="$POWERLINE_DATE_FORMAT"
fi

if [ "$POWERLINE_SHORT_HOST_NAME" = "" ]; then
    POWERLINE_HOST_NAME="%M"
else
    POWERLINE_HOST_NAME="%m"
fi

if [ "$POWERLINE_HIDE_USER_NAME" = "" ] && [ "$POWERLINE_HIDE_HOST_NAME" = "" ]; then
    POWERLINE_USER_NAME="%n@$POWERLINE_HOST_NAME"
elif [ "$POWERLINE_HIDE_USER_NAME" != "" ] && [ "$POWERLINE_HIDE_HOST_NAME" = "" ]; then
    POWERLINE_USER_NAME="@$POWERLINE_HOST_NAME"
elif [ "$POWERLINE_HIDE_USER_NAME" = "" ] && [ "$POWERLINE_HIDE_HOST_NAME" != "" ]; then
    POWERLINE_USER_NAME="%n"
else
    POWERLINE_USER_NAME=""
fi


truncate_dirs() {
  local path=$PWD
  local prefix=""
  local IFS="/"

  # Color definitions
  local TRUNC_COLOR="%F{black}"
  local RESET_COLOR="%F{black}"

  # Special case: exactly in home directory
  if [[ $path == "$HOME" ]]; then
    echo "~"
    return
  elif [[ $path == $HOME/* ]]; then
    prefix="~"
    path="${path#$HOME}"
  fi

  local parts=(${(s:/:)path})
  local n=${#parts[@]}
  local out=""

  for ((i = 1; i < n; i++)); do
    [[ -n ${parts[i]} ]] && out+="${parts[i]:0:1}/"
  done

  out="${TRUNC_COLOR}${prefix}/${out}${RESET_COLOR}${parts[-1]}"  # leave last part uncolored (or customize)
  # echo "${prefix}/${out}"
  echo "${out}"
}

# necessary to call truncate_dirs at prompt time
setopt PROMPT_SUBST

if [ "$SCROLLBACK_TIME_COLOR" = "" ]; then
	SCROLLBACK_TIME_COLOR="white"
fi
SCROLLBACK_TIME_TEXT="%D{%H:%M:%S}"
if [ "$SCROLLBACK_TIME_BRACKETS" != "" ]; then
	SCROLLBACK_TIME_TEXT="[$SCROLLBACK_TIME_TEXT]"
fi
SCROLLBACK_PROMPT="%F{$SCROLLBACK_TIME_COLOR}$SCROLLBACK_TIME_TEXT%F %(?..%F{red}✘ %? )%F{blue}%B> %F%b"

# trying to get prompt rewriting working on ctrl C, nothing worked
function reset-scrollback-prompt() {
    PROMPT="$SCROLLBACK_PROMPT" \
        RPROMPT="" \
        zle reset-prompt
    zle redisplay
    zle -R
    print -n '\E[0m\E[K'
    print -n '\r'
    zle redisplay
}

function del-prompt-accept-line() {
    reset-scrollback-prompt
    zle .accept-line
}
zle -N accept-line del-prompt-accept-line

function del-prompt-send-break() {
    reset-scrollback-prompt
    zle .send-break
}
zle -N send-break del-prompt-send-break

function del-prompt-eof() {
    reset-scrollback-prompt
    zle .send-eof
}
zle -N send-eof del-prompt-eof

function del-prompt-clear-screen() {
    reset-scrollback-prompt
    zle .clear-screen
}
zle -N clear-screen del-prompt-clear-screen

function preexec() {
    print -n '\E[0m\E[K'
}

if [ "$POWERLINE_PATH" = "full" ]; then
  POWERLINE_PATH="%1~"
elif [ "$POWERLINE_PATH" = "short" ]; then
  POWERLINE_PATH="%~"
elif [ "$POWERLINE_PATH" = "truncate_dirs" ]; then
  POWERLINE_PATH='$(truncate_dirs)'
else
  POWERLINE_PATH="%d"
fi

if [ "$POWERLINE_CUSTOM_CURRENT_PATH" != "" ]; then
  POWERLINE_PATH="$POWERLINE_CUSTOM_CURRENT_PATH"
fi

# if [ "$POWERLINE_GIT_CLEAN" = "" ]; then
#   POWERLINE_GIT_CLEAN="✔"
# fi
#
# if [ "$POWERLINE_GIT_DIRTY" = "" ]; then
#   POWERLINE_GIT_DIRTY="✘"
# fi

if [ "$POWERLINE_GIT_ADDED" = "" ]; then
  POWERLINE_GIT_ADDED="%F{green}✚%F{black}"
fi

if [ "$POWERLINE_GIT_MODIFIED" = "" ]; then
  POWERLINE_GIT_MODIFIED="%F{blue}✹%F{black}"
fi

if [ "$POWERLINE_GIT_UNSTAGED" = "" ]; then
  POWERLINE_GIT_UNSTAGED="%F{red}✹%F{black}"
fi

if [ "$POWERLINE_GIT_DELETED" = "" ]; then
  POWERLINE_GIT_DELETED="%F{red}✖%F{black}"
fi

if [ "$POWERLINE_GIT_UNTRACKED" = "" ]; then
  POWERLINE_GIT_UNTRACKED="%F{yellow}✭%F{black}"
fi

if [ "$POWERLINE_GIT_RENAMED" = "" ]; then
  POWERLINE_GIT_RENAMED="➜"
fi

if [ "$POWERLINE_GIT_UNMERGED" = "" ]; then
  POWERLINE_GIT_UNMERGED="═"
fi

if [ "$POWERLINE_RIGHT_A_COLOR_FRONT" = "" ]; then
  POWERLINE_RIGHT_A_COLOR_FRONT="white"
fi

if [ "$POWERLINE_RIGHT_A_COLOR_BACK" = "" ]; then
  POWERLINE_RIGHT_A_COLOR_BACK="black"
fi

function git_prompt_status() {
  [[ "$(__git_prompt_git config --get oh-my-zsh.hide-status 2>/dev/null)" = 1 ]] && return

  # Maps a git status prefix to an internal constant
  # This cannot use the prompt constants, as they may be empty
  local -A prefix_constant_map
  prefix_constant_map=(
    '\?\? '     'UNTRACKED'
    'A. '       'ADDED'
    'M( |M) '   'MODIFIED'
    '( |M)M '   'UNSTAGED'
    ' T '       'MODIFIED'
    'R  '       'RENAMED'
    ' D '       'DELETED'
    'D  '       'DELETED'
    'UU '       'UNMERGED'
    'ahead'     'AHEAD'
    'behind'    'BEHIND'
    'diverged'  'DIVERGED'
    'stashed'   'STASHED'
  )

  # Maps the internal constant to the prompt theme
  local -A constant_prompt_map
  constant_prompt_map=(
    'UNTRACKED' "$ZSH_THEME_GIT_PROMPT_UNTRACKED"
    'ADDED'     "$ZSH_THEME_GIT_PROMPT_ADDED"
    'MODIFIED'  "$ZSH_THEME_GIT_PROMPT_MODIFIED"
    'UNSTAGED'  "$ZSH_THEME_GIT_PROMPT_UNSTAGED"
    'RENAMED'   "$ZSH_THEME_GIT_PROMPT_RENAMED"
    'DELETED'   "$ZSH_THEME_GIT_PROMPT_DELETED"
    'UNMERGED'  "$ZSH_THEME_GIT_PROMPT_UNMERGED"
    'AHEAD'     "$ZSH_THEME_GIT_PROMPT_AHEAD"
    'BEHIND'    "$ZSH_THEME_GIT_PROMPT_BEHIND"
    'DIVERGED'  "$ZSH_THEME_GIT_PROMPT_DIVERGED"
    'STASHED'   "$ZSH_THEME_GIT_PROMPT_STASHED"
  )

  # The order that the prompt displays should be added to the prompt
  local status_constants
  status_constants=(
    UNTRACKED UNSTAGED ADDED MODIFIED RENAMED DELETED
    STASHED UNMERGED AHEAD BEHIND DIVERGED
  )

  local status_text
  status_text="$(__git_prompt_git status --porcelain -b 2> /dev/null)"

  # Don't continue on a catastrophic failure
  if [[ $? -eq 128 ]]; then
    return 1
  fi

  # A lookup table of each git status encountered
  local -A statuses_seen

  if __git_prompt_git rev-parse --verify refs/stash &>/dev/null; then
    statuses_seen[STASHED]=1
  fi

  local status_lines
  status_lines=("${(@f)${status_text}}")

  # If the tracking line exists, get and parse it
  if [[ "$status_lines[1]" =~ "^## [^ ]+ \[(.*)\]" ]]; then
    local branch_statuses
    branch_statuses=("${(@s/,/)match}")
    for branch_status in $branch_statuses; do
      if [[ ! $branch_status =~ "(behind|diverged|ahead) ([0-9]+)?" ]]; then
        continue
      fi
      local last_parsed_status=$prefix_constant_map[$match[1]]
      statuses_seen[$last_parsed_status]=$match[2]
    done
  fi

  # For each status prefix, do a regex comparison
  for status_prefix in ${(k)prefix_constant_map}; do
    local status_constant="${prefix_constant_map[$status_prefix]}"
    local status_regex=$'(^|\n)'"$status_prefix"

    if [[ "$status_text" =~ $status_regex ]]; then
      statuses_seen[$status_constant]=1
    fi
  done

  # Display the seen statuses in the order specified
  local status_prompt
  for status_constant in $status_constants; do
    if (( ${+statuses_seen[$status_constant]} )); then
      local next_display=$constant_prompt_map[$status_constant]
      status_prompt="$next_display$status_prompt"
    fi
  done

  echo $status_prompt
}

ZSH_THEME_GIT_PROMPT_PREFIX=" \ue0a0 "
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN=" $POWERLINE_GIT_CLEAN"
ZSH_THEME_GIT_PROMPT_CLEAN=" $POWERLINE_GIT_CLEAN"

ZSH_THEME_GIT_PROMPT_ADDED=" $POWERLINE_GIT_ADDED"
ZSH_THEME_GIT_PROMPT_MODIFIED=" $POWERLINE_GIT_MODIFIED"
ZSH_THEME_GIT_PROMPT_UNSTAGED=" $POWERLINE_GIT_UNSTAGED"
ZSH_THEME_GIT_PROMPT_DELETED=" $POWERLINE_GIT_DELETED"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" $POWERLINE_GIT_UNTRACKED"
ZSH_THEME_GIT_PROMPT_RENAMED=" $POWERLINE_GIT_RENAMED"
ZSH_THEME_GIT_PROMPT_UNMERGED=" $POWERLINE_GIT_UNMERGED"
ZSH_THEME_GIT_PROMPT_AHEAD=" ⬆"
ZSH_THEME_GIT_PROMPT_BEHIND=" ⬇"
ZSH_THEME_GIT_PROMPT_DIVERGED=" ⬍"

# if [ "$(git_prompt_info)" = "" ]; then
   # POWERLINE_GIT_INFO_LEFT=""
   # POWERLINE_GIT_INFO_RIGHT=""
# else
    if [ ! "$POWERLINE_SHOW_GIT_ON_LEFT" = "" ]; then
        if [ "$POWERLINE_HIDE_GIT_PROMPT_STATUS" = "" ]; then
            POWERLINE_GIT_INFO_LEFT=" %F{blue}%K{white}"$'\ue0b0'"%F{white}%F{black}%K{white}"$'$(git_prompt_info)$(git_prompt_status)%F{white}%u'
        else
            POWERLINE_GIT_INFO_LEFT=" %F{blue}%K{white}"$'\ue0b0'"%F{white}%F{black}%K{white}"$'$(git_prompt_info)%F{white}'
        fi
        POWERLINE_GIT_INFO_RIGHT=""
    fi
    if [ ! "$POWERLINE_SHOW_GIT_ON_RIGHT" = "" ]; then
        POWERLINE_GIT_INFO_LEFT=""
        if [ "$POWERLINE_HIDE_GIT_PROMPT_STATUS" = "" ]; then
            POWERLINE_GIT_INFO_RIGHT="%F{white}"$'\ue0b2'"%F{black}%K{white}"$'$(git_prompt_info)$(git_prompt_status)'" %K{white}"
        else
            POWERLINE_GIT_INFO_RIGHT="%F{white}"$'\ue0b2'"%F{black}%K{white}"$'$(git_prompt_info)'" %K{white}"
        fi
    fi
# fi

if [ $(id -u) -eq 0 ]; then
    POWERLINE_SEC1_BG=%K{red}
    POWERLINE_SEC1_FG=%F{red}
else
    POWERLINE_SEC1_BG=%K{green}
    POWERLINE_SEC1_FG=%F{green}
fi
POWERLINE_SEC1_TXT=%F{black}
if [ "$POWERLINE_DETECT_SSH" != "" ]; then
  if [ -n "$SSH_CLIENT" ]; then
    POWERLINE_SEC1_BG=%K{red}
    POWERLINE_SEC1_FG=%F{red}
    POWERLINE_SEC1_TXT=%F{white}
  fi
fi

if [ "$VIRTUAL_ENV" != "" ] && [ "$POWERLINE_HIDE_VIRTUAL_ENV" = "" ]; then
    VENV_NAME=$(basename "$VIRTUAL_ENV")
    VENV_STATUS="($POWERLINE_SEC1_TXT$VENV_NAME)"
else
    VENV_STATUS=""
fi

POWERLINE_SEC1="$POWERLINE_SEC1_BG$POWERLINE_SEC1_TXT $POWERLINE_USER_NAME $VENV_STATUS%k%f$POWERLINE_SEC1_FG%K{blue}"$'\ue0b0'""

if [ "$VENV_STATUS" = "" ] && [ "$POWERLINE_USER_NAME" = "" ]; then
    POWERLINE_SEC1=""
fi

PROMPT="$POWERLINE_SEC1_BG$POWERLINE_SEC1_TXT $POWERLINE_USER_NAME $VENV_STATUS%k%f$POWERLINE_SEC1_FG%K{blue}"$'\ue0b0'"%k%f%F{black}%K{blue} "$POWERLINE_PATH"%F{blue}"$POWERLINE_GIT_INFO_LEFT" %k"$'\ue0b0'"%f "
PROMPT="%K{blue}""%k%f%F{black}%K{blue} "$POWERLINE_PATH"%F{blue}"$POWERLINE_GIT_INFO_LEFT" %k"$'\ue0b0'"%f "
PROMPT="$POWERLINE_SEC1""$PROMPT"

if [ "$POWERLINE_NO_BLANK_LINE" = "" ]; then
    PROMPT="
"$PROMPT
fi

if [ "$POWERLINE_DISABLE_RPROMPT" = "" ]; then
    if [ "$POWERLINE_RIGHT_A" = "" ]; then
        RPROMPT="$POWERLINE_GIT_INFO_RIGHT%F{white}"$'\ue0b2'"%k%F{black}%K{white} $POWERLINE_RIGHT_B %f%k"
    elif [ "$POWERLINE_RIGHT_B" = "" ]; then
        RPROMPT="$POWERLINE_GIT_INFO_RIGHT%F{white}"$'\ue0b2'"%k%F{$POWERLINE_RIGHT_A_COLOR_FRONT}%K{$POWERLINE_RIGHT_A_COLOR_BACK} $POWERLINE_RIGHT_A %f%k"
    else
        RPROMPT="$POWERLINE_GIT_INFO_RIGHT%F{white}"$'\ue0b2'"%k%F{black}%K{white} $POWERLINE_RIGHT_B %f%F{$POWERLINE_RIGHT_A_COLOR_BACK}"$'\ue0b2'"%f%k%K{$POWERLINE_RIGHT_A_COLOR_BACK}%F{$POWERLINE_RIGHT_A_COLOR_FRONT} $POWERLINE_RIGHT_A %f%k"
    fi
fi

