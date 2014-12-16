# fontforge as a script interpreter.
#
# Exists because
# * It is desirable to launch fontforge scripts as executables.
# * The usual #! interpreter-calling mechanism needs an explicit path,
#   but custom-installed fontforge should be in a non-distro location.
# * Linux /usr/bin/env won't allow arguments such as -script.

/usr/bin/fontforge -script $@
