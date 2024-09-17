package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.SqlCommand;
import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;


class Delete {

    public static function parse(parser: SqlCommandParse): SqlCommand {
            var token = parser.nextToken();
            if (!token.match(Token.Kwd("FROM"))) {
                throw "Expected FROM, found: " + Std.string(token);
            }
    
            var table = parser.nextToken();
            if (!(table.match(Token.Ident(_)))) {
                throw "Expected table name";
            }
    
            var whereClause = new Array<Condition>();
            token = parser.peekToken();
            if (token.match(Token.Kwd("WHERE"))) {
                whereClause = WhereClause.parse(parser);
            }
    
            return SqlCommand.Delete(parser.extractValue(table), whereClause);
    }

}