package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;


class WhereClause {
    
    public static function parse(parser: SqlCommandParse): Array<Condition> {
         parser.nextToken();
          var conditions = new Array<Condition>();
          while (true) {
              var field = parser.nextToken();
              if (!(field.match(Token.Ident(_)))) {
                  throw "Expected field name in WHERE clause";
              }
              var binop = parser.nextToken();
              if (!(binop.match(Token.Op(_)))) {
                  throw "Expected binary operator in WHERE clause";
              }
              var value = parser.nextToken();
              if (!(value.match(Token.Ident(_))) && !(value.match(Token.CInt(_))) && !(value.match(Token.CFloat(_)))) {
                  throw "Expected value in WHERE clause";
              }
              conditions.push(Condition.Relational(parser.extractValue(field), parser.extractValue(binop), parser.getSqlValue(value)));
              var cont = parser.peekToken();
              if (cont == null || !cont.match(Token.Kwd("AND"))) {
                  break;
              }
             parser.nextToken();
          }
          return conditions;
    }

}