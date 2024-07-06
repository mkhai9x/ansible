#!/usr/bin/env zsh

if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
  eval "$(oh-my-posh init zsh --config ~/.poshthemes/multiverse-neon.omp.json)"
fi
