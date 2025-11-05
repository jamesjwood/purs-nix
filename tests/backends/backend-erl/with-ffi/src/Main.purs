module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)

-- Foreign import from Erlang
foreign import erlGreet :: String -> String
foreign import erlMultiply :: Int -> Int -> Int

main :: Effect Unit
main = do
  log "Testing Erlang FFI:"
  log $ erlGreet "Erlang"
  log $ "5 * 7 = " <> show (erlMultiply 5 7)
  log "✓ Erlang FFI working"
