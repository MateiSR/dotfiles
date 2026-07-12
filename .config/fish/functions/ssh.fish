function ssh
    if test "$TERM" = xterm-kitty; and command -q kitten
        command kitten ssh $argv
    else
        command ssh $argv
    end
end
