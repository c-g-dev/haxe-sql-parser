package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.FromClause;
import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;

class Select {

    public static function parse(parser: SqlCommandParse): SqlCommand {
        var fields = new Array<Field>();
        var token = parser.nextToken();
        if (token == Token.Star) {
            fields.push({table: "", field: "", all: true});
            token = parser.nextToken();
        } else {
            while (!token.match(Token.Kwd("FROM"))) {
                switch token {
                    case Ident(s): {
                        var field = { table: "", field: s, all: false };
                        fields.push(field);
                        token = parser.nextToken();
                        if (token == Token.Comma) {
                            token = parser.nextToken();
                        }
                    }
                    default: throw "Unexpected token in SELECT fields: " + Std.string(token);
                }
            }
        }

        if (!token.match(Token.Kwd("FROM"))) {
            throw "Expected FROM, found: " + Std.string(token);
        }
        var fromClause = fromClause(parser);

        var whereClause = new Array<Condition>();
        token = parser.peekToken();
        if (token != null && token.match(Token.Kwd("WHERE"))) {
            whereClause = WhereClause.parse(parser);
        }
        
        return SqlCommand.Select(fields, fromClause, whereClause);
    }

    public static function fromClause(parser: SqlCommandParse): FromClause {
        var next = parser.nextToken();
        if (!(next.match(Token.Ident(_)))) {
            throw "Expected table name in FROM clause";
        }
        return FromClause.Table(parser.extractValue(next));
    }

}