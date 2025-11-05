module Main where

import Prelude
import Effect (Effect)
import Effect.Console (log)

main :: Effect Unit
main = do
  log "Hello from PureScript compiled to Erlang!"
  log "This example uses purs-nix with backend support."
  log "✓ Pure evaluation (no --impure flag needed)"
  log "✓ Locked package set for reproducibility"
  log "✓ Per-package caching"
