package hxsqlparser.branches;

import hxsqlparser.SqlCommandParse.SqlValue;
import hxsqlparser.SqlCommandParse.InsertValue;
import hxsqlparser.SqlCommandParse.SqlCommand;
import hxsqlparser.SqlCommandParse.Condition;
import hxsqlparser.SqlLexer.Token;
import hxsqlparser.SqlCommandParse.Field;
import hxsqlparser.SqlCommandParse.SqlCommand;


class Insert {

    public static function parse(parser: SqlCommandParse): SqlCommand {
        var token = parser.nextToken();
        if (!token.match(Token.Kwd("INTO"))) {
            throw "Expected INTO, found: " + Std.string(token);
        }

        var table = parser.nextToken();
        if (!(table.match(Token.Ident(_)))) {
            throw "Expected table name";
        }

        var fields: Array<Field> = [];

        token = parser.peekToken();
        if (token.match(Token.POpen)) {
            while(!token.match(Token.PClose)) {
                token = parser.nextToken();
                switch token {
                    case Ident(s):{
                        fields.push({table: "", field: s, all: false});
                    }
                    default:
                }
            }
    
        }

        var insertValue = parseInsertValue(parser);

        return SqlCommand.Insert(parser.extractValue(table), fields, insertValue);
    }

    private static function parseInsertValue(parser: SqlCommandParse): InsertValue {
        var token = parser.nextToken();
        switch token {
            case Kwd("VALUES"): {
                if (parser.nextToken() != Token.POpen) {
                    throw "Expected ( to start INSERT values";
                }
        
                var fields = new Array<SqlValue>();
                while (true) {
                    var field = parser.nextToken();
                    switch field {
                        case CInt(v):{}
                        case CFloat(v):{}
                        case CString(v): {}
                        case Ident(s): {}
                        case Comma: {
                            continue;
                        }
                        default: throw "Unexpected token in INSERT values: " + Std.string(field);
                    }
        
                    fields.push(parser.getSqlValue(field));
                    
                    if (parser.peekToken() == Token.PClose) {
                        parser.nextToken();
                        break;
                    }
                }
                return InsertValue.Row(fields);
            }
            case Kwd("SELECT"): {
                return InsertValue.Query(hxsqlparser.branches.Select.parse(parser));
            }
            default: throw "Expected VALUES or SELECT, found: " + Std.string(token);
        }

      
    }

}