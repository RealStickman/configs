set -l last_pipestatus $pipestatus
set -lx __fish_last_status $status # Export for __fish_print_pipestatus.
set -l normal (set_color normal)

# Color the prompt differently when we're root
set -l color_cwd $fish_color_cwd
set -l suffix '>'
#if functions -q fish_is_root_user; and fish_is_root_user
#    if set -q fish_color_cwd_root
#        set color_cwd $fish_color_cwd_root
#    end
#    set suffix '#'
#end

# If we're running via SSH, change the host color.
set -l color_host $fish_color_host
#if set -q SSH_TTY
#    set color_host $fish_color_host_remote
#end

# Write pipestatus
# If the status was carried over (e.g. after `set`), don't bold it.
set -l bold_flag --bold
set -q __fish_prompt_status_generation; or set -g __fish_prompt_status_generation $status_generation
if test $__fish_prompt_status_generation = $status_generation
    set bold_flag
end
set __fish_prompt_status_generation $status_generation
set -l prompt_status (__fish_print_pipestatus "[" "]" "|" (set_color $fish_color_status) (set_color $bold_flag $fish_color_status) $last_pipestatus)

echo -n -s (set_color $fish_color_user) "$USER" $normal (set_color $fish_color_separator) @ $normal (set_color $color_host) (prompt_hostname) $normal ' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
#echo -n -s (set_color --bold red) "$USER" $normal (set_color --bold yellow) @ $normal (set_color cyan) (prompt_hostname) $normal ' ' (set_color yellow) (prompt_pwd) $normal (fish_vcs_prompt) $normal " "$prompt_status $suffix " "
