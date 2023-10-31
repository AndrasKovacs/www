{-# LANGUAGE CPP #-}
#if __GLASGOW_HASKELL__ <= 708
{-# LANGUAGE OverlappingInstances #-}
#endif
{-# LANGUAGE FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-incomplete-patterns #-}

-- | Pretty-printer for Code.
--   Generated by the BNF converter.

module Code.Print where

import qualified Code.Abs
import Data.Char

-- | The top-level printing method.

printTree :: Print a => a -> String
printTree = render . prt 0

type Doc = [ShowS] -> [ShowS]

doc :: ShowS -> Doc
doc = (:)

render :: Doc -> String
render d = rend 0 (map ($ "") $ d []) "" where
  rend i ss = case ss of
    "["      :ts -> showChar '[' . rend i ts
    "("      :ts -> showChar '(' . rend i ts
    "{"      :ts -> showChar '{' . new (i+1) . rend (i+1) ts
    "}" : ";":ts -> new (i-1) . space "}" . showChar ';' . new (i-1) . rend (i-1) ts
    "}"      :ts -> new (i-1) . showChar '}' . new (i-1) . rend (i-1) ts
    [";"]        -> showChar ';'
    ";"      :ts -> showChar ';' . new i . rend i ts
    t  : ts@(p:_) | closingOrPunctuation p -> showString t . rend i ts
    t        :ts -> space t . rend i ts
    _            -> id
  new i   = showChar '\n' . replicateS (2*i) (showChar ' ') . dropWhile isSpace
  space t = showString t . (\s -> if null s then "" else ' ':s)

  closingOrPunctuation :: String -> Bool
  closingOrPunctuation [c] = c `elem` closerOrPunct
  closingOrPunctuation _   = False

  closerOrPunct :: String
  closerOrPunct = ")],;"

parenth :: Doc -> Doc
parenth ss = doc (showChar '(') . ss . doc (showChar ')')

concatS :: [ShowS] -> ShowS
concatS = foldr (.) id

concatD :: [Doc] -> Doc
concatD = foldr (.) id

replicateS :: Int -> ShowS -> ShowS
replicateS n f = concatS (replicate n f)

-- | The printer class does the job.

class Print a where
  prt :: Int -> a -> Doc
  prtList :: Int -> [a] -> Doc
  prtList i = concatD . map (prt i)

instance {-# OVERLAPPABLE #-} Print a => Print [a] where
  prt = prtList

instance Print Char where
  prt _ s = doc (showChar '\'' . mkEsc '\'' s . showChar '\'')
  prtList _ s = doc (showChar '"' . concatS (map (mkEsc '"') s) . showChar '"')

mkEsc :: Char -> Char -> ShowS
mkEsc q s = case s of
  _ | s == q -> showChar '\\' . showChar s
  '\\'-> showString "\\\\"
  '\n' -> showString "\\n"
  '\t' -> showString "\\t"
  _ -> showChar s

prPrec :: Int -> Int -> Doc -> Doc
prPrec i j = if j < i then parenth else id

instance Print Integer where
  prt _ x = doc (shows x)

instance Print Double where
  prt _ x = doc (shows x)

instance Print Code.Abs.Ins where
  prt i e = case e of
    Code.Abs.ILoad n -> prPrec i 0 (concatD [doc (showString "iload"), prt 0 n])
    Code.Abs.IStore n -> prPrec i 0 (concatD [doc (showString "istore"), prt 0 n])
    Code.Abs.IAdd -> prPrec i 0 (concatD [doc (showString "iadd")])
    Code.Abs.ISub -> prPrec i 0 (concatD [doc (showString "isub")])
    Code.Abs.IMul -> prPrec i 0 (concatD [doc (showString "imul")])
    Code.Abs.IDiv -> prPrec i 0 (concatD [doc (showString "idiv")])
    Code.Abs.ILit n -> prPrec i 0 (concatD [doc (showString "ldc"), prt 0 n])
    Code.Abs.DLoad n -> prPrec i 0 (concatD [doc (showString "dload"), prt 0 n])
    Code.Abs.DStore n -> prPrec i 0 (concatD [doc (showString "dstore"), prt 0 n])
    Code.Abs.DAdd -> prPrec i 0 (concatD [doc (showString "dadd")])
    Code.Abs.DSub -> prPrec i 0 (concatD [doc (showString "dsub")])
    Code.Abs.DMul -> prPrec i 0 (concatD [doc (showString "dmul")])
    Code.Abs.DDiv -> prPrec i 0 (concatD [doc (showString "ddiv")])
    Code.Abs.DLit d -> prPrec i 0 (concatD [doc (showString "ldc2_w"), prt 0 d])
    Code.Abs.I2D -> prPrec i 0 (concatD [doc (showString "i2d")])
    Code.Abs.IPrint -> prPrec i 0 (concatD [doc (showString "invokestatic"), doc (showString "Runtime/print(I)V")])
    Code.Abs.DPrint -> prPrec i 0 (concatD [doc (showString "invokestatic"), doc (showString "Runtime/print(D)V")])
