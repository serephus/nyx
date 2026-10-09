module Main (main) where

import Lib (add)

main :: IO ()
main =
  if add 40 2 == 42
    then putStrLn "All tests passed."
    else error "add is broken"
