-- Toposort
import Data.List
--Get uniques
uni :: Eq a => [a] -> [a]
uni [] = []
uni (x:xs)  | x `elem` xs   = uni xs
            | otherwise     = x:uni xs
--Every-other
eo :: [a] -> [a]
eo [] = []
eo (x:xs) = x : eo(drop 1 xs)

solve :: Eq a => [a] -> [(a,a)] -> [a] -> [a]
solve set pairs ans
    | null set = ans
    | null (set \\ concat [[b] | (b,_) <- pairs]) = []
    | otherwise,
    let tooken = head (set \\ concat [[b] | (b,_) <- pairs])
    = solve (tooken `delete` set) ([(a,b) | (a,b) <- pairs, b /= tooken]) (ans ++ [tooken])

main = do
    line <- getContents
    let x = words line
    let s = sort (uni x)
    let p = zip (eo x) (eo (tail x))
    let soln = solve s p []
    if null soln
        then putStrLn("cycle")
        else mapM_ putStrLn soln 
