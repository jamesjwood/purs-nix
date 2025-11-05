module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Erl.Data.List (List, nil, cons, reverse, length) as EList
import Erl.Atom (atom)

-- Test Erlang-specific packages
-- erl-lists provides native Erlang list types
-- erl-atom provides Erlang atom handling

program :: Effect Unit
program = do
  -- Create native Erlang list
  let erlList = EList.cons 1 (EList.cons 2 (EList.cons 3 EList.nil))
  let reversed = EList.reverse erlList

  log "Testing Erlang-specific packages:"
  log $ "Original list length: " <> show (EList.length erlList)
  log $ "Reversed list length: " <> show (EList.length reversed)

  -- Test atoms
  let testAtom = atom "test_atom"
  log $ "Created Erlang atom: " <> show testAtom

  log "✓ Erlang native types working"
  log "✓ Dependencies: erl-lists, erl-atom"

main :: Effect Unit
main = program
