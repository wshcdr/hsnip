import Prelude hiding (div,id,span,(-) )
import Data.List hiding (span)

newtype State s a = State { runState :: s -> (a,s) }

instance Monad (State s) where
    return x = State $ \s -> (x,s)
    (State h) >>= f = State $ \s -> let (a, newState) = h s
					(State g) = f a
				    in g newState

evalState st st0 = snd $ runState st st0

data Html = Htag String | Hetag String | Hattr String | Hstr String
    deriving Show

newtype Stack = Stack [Html] deriving Show

rend ::Html -> ([String],String) -> ([String],String)
rend (Htag x) (tags, attrs) = (t1:tags, []) where
    t1 = "<" ++ x ++ if (not.null) attrs then attrs else "" ++ ">"
rend (Hetag x) (tags, attrs) = (("</" ++ x ++ ">\n") : tags, [])
rend (Hstr x) (tags, attrs) = (x : tags, [])

render st = concat $ reverse s where
    Stack ts = evalState st (Stack [])
    (s,_) = foldr rend ([],[]) ts

infixr 0 -
(-) f x = f x

str :: String -> State Stack ()
str x = State $ \(Stack xs) -> ((), Stack ( Hstr x : xs))

tag :: String -> State Stack ()
tag x = State $ \(Stack xs) -> ((), Stack ( Htag x : xs))

etag :: String -> State Stack ()
etag x = State $ \(Stack xs) -> ((), Stack ( Hetag x : xs))

p :: State Stack () -> State Stack ()
p x = tag "p" >> x >> etag "p"

q x = tag "q" >> x >> etag "q"
r x = tag "r" >> x >> etag "r"

xxx :: State Stack ()
xxx = do
    tag "p" >> str "xxx" >> etag "p"

yyy = do
    p - do
	tag "p" >> str "xxx" >> etag "p"
	q - do
	    str "qqq1"
	    str "qqq2"
	    str "qqq3"
    q $ str "hey"

main = do
    --print $ runState xxx (Stack [])
    putStrLn $ render yyy
    print $ runState yyy (Stack [])
    --print $ runState (push "xxx") (Stack [])
