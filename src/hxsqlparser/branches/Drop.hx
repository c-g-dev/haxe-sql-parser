package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.SqlCommand;
import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;


class Drop {

    public static function parse(parser: SqlCommandParse): SqlCommand {
         var token = parser.nextToken();
         if (!token.match(Token.Kwd("TABLE"))) {
             throw "Expected TABLE, found: " + Std.string(token);
         }
 
         var table = parser.nextToken();
         if (!(table.match(Token.Ident(_)))) {
             throw "Expected table name";
         }
 
         return SqlCommand.DropTable(parser.extractValue(table));
    }

}