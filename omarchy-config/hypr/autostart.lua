-- Extra autostart processes.
-- o.launch_on_start("my-service")

o.launch_on_start("paseo")

-- Renames ##name##rest marker files to name-v#-dd-mm-yyyy-rest (see scripts/hash-renamer.sh).
o.launch_on_start("$HOME/Work/dotfiles/scripts/hash-renamer.sh --watch")
