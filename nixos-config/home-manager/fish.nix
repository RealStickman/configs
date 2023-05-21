{ config, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit =
      (builtins.readFile ./config/fish/conf.d/interactive.fish);
    shellAliases = {
      # open emacs in terminal
      emacs = "emacs --no-window-system";
      # colored wget output
      wget = "wget -c";
      # copy terminfo to remote server with kitty
      sshkp = "kitty +kitten ssh use-python";
      sshk = "kitty +kitten ssh";
      # colored ls output
      ls = "ls --color=auto";
      # kill all wine processes
      killwine =
        "ls -l /proc/*/exe 2>/dev/null | grep -E 'wine(64)?-preloader|wineserver' | perl -pe 's;^.*/proc/(d+)/exe.*$;$1;g;' | xargs -n 1 kill";
      # colored grep output
      grep = "grep --color=auto";
      # yt-dlp aliases
      # best audio
      yta-best = "yt-dlp -f bestaudio --extract-audio ";
      # best video
      ytv-best = "yt-dlp -f bestvideo+bestaudio ";
      # download video including metadata from youtube
      ytv-metadata = ''
        yt-dlp -f bestvideo+bestaudio --add-metadata --parse-metadata "%(title)s:%(meta_title)s" --parse-metadata "%(uploader)s:%(meta_artist)s" --write-info-json --write-thumbnail --embed-thumbnail --embed-subs --sub-langs "en.*" --merge-output-format mkv '';
      # activate venv called "venv" in the local directory
      activate = "source venv/bin/activate.fish";
      # lsblk including file system type
      lsblkf =
        "lsblk -o NAME,LABEL,RM,SIZE,RO,TYPE,FSTYPE,MOUNTPOINTS,MODEL,UUID";
      # color ip command
      ip = "ip -c";
    };
    functions = {
      fish_prompt =
        (builtins.readFile ./config/fish/functions/fish_prompt.fish);
    };
  };
}
