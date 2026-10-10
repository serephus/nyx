module Main (main) where

import Lib (add)

main :: IO ()
main = putStrLn ("2 + 2 = " ++ show (add 2 2))
