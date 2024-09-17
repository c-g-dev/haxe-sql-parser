package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.AlterCommand;
import hxsqlparser.SqlCommandParse.SqlCommand;
import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;

class Alter {

    public static function parse(parser: SqlCommandParse): SqlCommand {
          var token = parser.nextToken();
          if (!token.match(Token.Kwd("TABLE"))) {
              throw "Expected TABLE, found: " + Std.string(token);
          }
  
          var table = parser.nextToken();
          if (!(table.match(Token.Ident(_)))) {
              throw "Expected table name";
          }
  
          var alters = new Array<AlterCommand>();
          while (parser.pos < parser.tokens.length) {
              token = parser.nextToken();
              switch (token) {
                  case Token.Kwd("RENAME"): {
                      var to = parser.nextToken();
                      if (!to.match(Token.Kwd("TO"))) {
                          throw "Expected TO after RENAME";
                      }
                      var newName = parser.nextToken();
                      if (!(newName.match(Token.Ident(_)))) {
                          throw "Expected new table name";
                      }
                      alters.push(AlterCommand.RenameTo(parser.extractValue(newName)));
                  }
                  case Token.Kwd("ADD"): {
                      var column = parser.nextToken();
                      if (!column.match(Token.Kwd("COLUMN"))) {
                          throw "Expected COLUMN after ADD";
                      }
                      var columnName = parser.nextToken();
                      if (!(columnName.match(Token.Ident(_)))) {
                          throw "Expected column name";
                      }
                      var columnType = parser.nextToken();
                      if (!(columnType.match(Token.Ident(_)))) {
                          throw "Expected column type";
                      }
                      alters.push(AlterCommand.AddColumn(parser.extractValue(columnName), parser.parseSqlType(parser.extractValue(columnType))));
                  }
                  case Token.Kwd("DROP"): {
                      var column = parser.nextToken();
                      if (!column.match(Token.Kwd("COLUMN"))) {
                          throw "Expected COLUMN after DROP";
                      }
                      var columnName = parser.nextToken();
                      if (!(columnName.match(Token.Ident(_)))) {
                          throw "Expected column name";
                      }
                      alters.push(AlterCommand.DropColumn(parser.extractValue(columnName)));
                  }
                  case Token.Kwd("MODIFY"): {
                      var column = parser.nextToken();
                      if (!column.match(Token.Kwd("COLUMN"))) {
                          throw "Expected COLUMN after MODIFY";
                      }
                      var columnName = parser.nextToken();
                      if (!(columnName.match(Token.Ident(_)))) {
                          throw "Expected column name";
                      }
                      var columnType = parser.nextToken();
                      if (!(columnType.match(Token.Ident(_)))) {
                          throw "Expected column type";
                      }
                      alters.push(AlterCommand.ModifyColumn(parser.extractValue(columnName), parser.parseSqlType(parser.extractValue(columnType))));
                  }
                  default: {
                      throw "Unexpected token in ALTER TABLE command: " + Std.string(token);
                  }
              }
  
              token = parser.peekToken();
              if (token == null || token == Token.Eof || !(token.match(Token.Kwd(_)))) {
                  break;
              }
          }
  
          return SqlCommand.AlterTable(parser.extractValue(table), alters);
    }

}