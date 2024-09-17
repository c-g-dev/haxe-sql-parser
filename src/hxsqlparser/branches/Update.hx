package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.SetField;
import hxsqlparser.SqlCommandParse.SqlCommand;
import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;


class Update {

    public static function parse(parser: SqlCommandParse): SqlCommand {
         var table = parser.nextToken();
         if (!(table.match(Token.Ident(_)))) {
             throw "Expected table name";
         }

         var token = parser.nextToken();
         if (!token.match(Token.Kwd("SET"))) {
             throw "Expected SET, found: " + Std.string(token);
         }
 
         var setFields = new Array<SetField>();
         while (true) {
             var field = parser.nextToken();
             if (!(field.match(Token.Ident(_)))) {
                 throw "Expected field name in SET clause";
             }
 
             token = parser.nextToken();
             if (!token.match(Token.Op(Eq))) {
                 throw "Expected = in SET clause";
             }
 
             var value = parser.nextToken();
             if (!(value.match(Token.Ident(_))) && !(value.match(Token.CString(_))) && !(value.match(Token.CInt(_))) && !(value.match(Token.CFloat(_)))) {
                 throw "Expected value in SET clause";
             }
 
             switch field {
                 case Ident(s): {
                     setFields.push({field: s, value: parser.getSqlValue(value)});
                 }
                 default:
             }
             
 
             token = parser.peekToken();
             if (token != Token.Comma) {
                 break;
             }
             parser.nextToken();
         }
 
         var whereClause = new Array<Condition>();
         token = parser.peekToken();
         if (token.match(Token.Kwd("WHERE"))) {
             whereClause = WhereClause.parse(parser);
         }
 
         switch table {
             case Ident(s): {
                 return SqlCommand.Update(s, setFields, whereClause);
             }
             default: throw "Expected table name";
         }
    }

}