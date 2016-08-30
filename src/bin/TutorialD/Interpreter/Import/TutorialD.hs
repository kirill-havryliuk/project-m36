module TutorialD.Interpreter.Import.TutorialD where
import ProjectM36.Base
import TutorialD.Interpreter.Import.Base
import TutorialD.Interpreter.Base
import TutorialD.Interpreter.DatabaseContextExpr
import Text.Megaparsec.Text
import Text.Megaparsec hiding (try)
import ProjectM36.Error
import qualified ProjectM36.Error as PM36E
import Data.Either
import qualified Data.Text as T
import Control.Exception
import qualified Data.Text.IO as TIO
--import a file containing TutorialD database context expressions

importTutorialD :: FilePath -> IO (Either RelationalError DatabaseContextExpr)
importTutorialD pathIn = do
  tutdData <- try (TIO.readFile pathIn) :: IO (Either IOError T.Text)
  case tutdData of 
    Left err -> return $ Left (ImportError $ T.pack (show err))
    Right tutdData' -> do 
      let dbexprsErr = map (parse databaseExprP "import") (T.lines tutdData')
          errs = lefts dbexprsErr
      case errs of
        err2:_ -> return $ Left (PM36E.ParseError (T.pack (show err2)))
        [] -> return $ Right (MultipleExpr (rights dbexprsErr))

tutdImportP :: Parser DatabaseContextDataImportOperator
tutdImportP = do
  reserved ":importtutd" 
  path <- quotedString
  spaceConsumer
  return $ DatabaseContextDataImportOperator (T.unpack path) importTutorialD