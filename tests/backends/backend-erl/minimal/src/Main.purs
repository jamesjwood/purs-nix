module Main where

identity :: forall a. a -> a
identity x = x

main :: Int
main = identity 42
