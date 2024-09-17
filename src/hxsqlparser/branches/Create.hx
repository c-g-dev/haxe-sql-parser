package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.FieldDesc;
import hxsqlparser.SqlCommandParse.SqlCommand;
import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;


class Create {

    public static function parse(parser: SqlCommandParse): SqlCommand {
          var token = parser.nextToken();
          if (!token.match(Token.Kwd("TABLE"))) {
              throw "Expected TABLE, found: " + Std.string(token);
          }
  
          var table = parser.nextToken();
          if (!(table.match(Token.Ident(_)))) {
              throw "Expected table name";
          }
  
          var fields = new Array<FieldDesc>();
          if (parser.nextToken() != Token.POpen) {
              throw "Expected ( after table name";
          }
          while (true) {
              var fieldName = parser.nextToken();
              if (!(fieldName.match(Token.Ident(_)))) {
                  throw "Expected field name";
              }
  
              var fieldType = parser.nextToken();
              if (!(fieldType.match(Token.Ident(_)))) {
                  throw "Expected field type";
              }
  
              fields.push(
                  {
                      name: parser.extractValue(fieldName),
                      type: parser.parseSqlType(parser.extractValue(fieldType))
                  }
              );
  
              token = parser.nextToken();
              if (token == Token.PClose) {
                  break;
              }
              if (token != Token.Comma) {
                  throw "Expected , or ) in field list";
              }
          }
  
          return SqlCommand.CreateTable(parser.extractValue(table), fields);
    }

}