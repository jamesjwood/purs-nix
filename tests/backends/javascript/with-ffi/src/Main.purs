module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)

-- Foreign import from JavaScript
foreign import greet :: String -> String
foreign import addNumbers :: Int -> Int -> Int

main :: Effect Unit
main = do
  log "Testing JavaScript FFI:"
  log $ greet "World"
  log $ "2 + 3 = " <> show (addNumbers 2 3)
  log "✓ JavaScript FFI working"
