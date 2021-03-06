{-# LANGUAGE OverloadedStrings #-}

module HaskAnything.Internal.Content where

import           Hakyll
import qualified Data.List                      as L

matchContent :: String -> Context String -> Rules ()
matchContent name ctx = do
    let path = fromGlob ("content/" ++ name ++ "/*")
    match path $ do
        route $ setExtension "html"
        let template = fromFilePath ("templates/content/" ++ name ++ ".html")
        compile $ pandocCompiler
            >>= loadAndApplyTemplate template ctx
            >>= loadAndApplyTemplate "templates/content.html" ctx
            >>= loadAndApplyTemplate "templates/default.html" ctx
            >>= relativizeUrls
            
-- Given a list of Items, a function that uses an Item's identifier to get something else of type b, and a comparison function to deduplicate said list of Items, gives you the deduplicated list.
deduplicateContentBy :: (Eq c) => (Identifier -> Compiler b) -> (b -> c) -> [Item a] -> Compiler [Item a]
deduplicateContentBy identFunc compareFunc is = do
 let idents = map itemIdentifier is
 allValues <- sequence (map identFunc idents)
 let dedup = L.nubBy (\r1 r2 -> let cmp = compareFunc . fst in cmp r1 == cmp r2) (zip allValues is)
 return $ map snd dedup