{-# LANGUAGE OverloadedStrings #-}

module Lib
    ( someFunc
    , Hash
    ) where

import qualified Crypto.Hash.SHA256 as SHA256
import qualified Data.ByteString as B
import Text.Printf (printf)
import Data.DateTime (DateTime, getCurrentTime, toSqlString)

data Hash = Hash { index :: Int
                 , timestamp :: DateTime
                 , content :: String -- "data" in Snakecoin
                 , previousHash :: String
                 , hash :: String
                 } deriving (Show)

makeHash :: Int -> String -> String -> String -> IO Hash
makeHash n c p h = do
  now <- getCurrentTime
  return Hash { index=n
              , timestamp=now
              , content=c
              , previousHash=p
              , hash=h          -- FIXME gdmcbain 20170801
              }

genesisHash :: IO Hash
genesisHash = makeHash 0 "Genesis Block" "0" "0"

nextHash :: String -> Hash -> IO Hash
nextHash cntnt hsh = do
  now <- getCurrentTime
  let newIndex = 1 + index hsh
  return Hash { index=newIndex
              , timestamp=now
              , content=(if (length cntnt) > 0 then cntnt else
                         "Hey! I'm block " ++ show newIndex)
              , previousHash=previousHash hsh
              , hash=hash hsh   -- FIXME gdmcbain 20170801
              }

hash1 :: IO Hash
hash1 = (nextHash "") =<< genesisHash

hashTest = h1 where h = SHA256.init
                    h1 = SHA256.update h "someFunc"

hexHash :: SHA256.Ctx -> String
hexHash = concatMap (printf "%02x") . B.unpack . SHA256.finalize

someFunc0 :: IO ()
someFunc0 = putStrLn $ hexHash hashTest

someFunc :: IO ()
someFunc = (show <$> hash1) >>= putStrLn
