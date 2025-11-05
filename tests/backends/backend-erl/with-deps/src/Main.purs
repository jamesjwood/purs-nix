module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Data.Array (length, replicate, filter)

-- Test multiple dependencies working together
program :: Effect Unit
program = do
  let numbers = replicate 5 42
  let evens = filter (\n -> n `mod` 2 == 0) numbers
  log $ "Created " <> show (length numbers) <> " numbers"
  log $ "Found " <> show (length evens) <> " even numbers"
  log "Backend-erl with dependencies: prelude, effect, console, arrays"

main :: Effect Unit
main = program
