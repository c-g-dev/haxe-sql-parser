package hxsqlparser;

import hxsqlparser.branches.Drop;
import hxsqlparser.branches.Create;
import hxsqlparser.SqlLexer.Token;


enum SqlCommand {
    Select( fields: Array<Field>, fromClause: FromClause, whereClause: Array<Condition> );
    Update( table: String, setFields: Array<SetField>, whereClause: Array<Condition> );
    Insert( table: String, fieldNames: Array<Field>, insertValue: InsertValue );
    Delete( table: String, whereClause: Array<Condition> );
    CreateTable( table: String, fields: Array<FieldDesc>);
    AlterTable( table: String, alters: Array<AlterCommand> );
    DropTable( table: String );
}

enum FromClause {
    Table(table: String);
    Query(command: SqlCommand);
    InnerJoin(left: FromClause, right: FromClause, on: Array<Condition>);
    OuterJoin(left: FromClause, right: FromClause, on: Array<Condition>);
}

enum SqlValue {
    Value<T>(kind: SqlType<T>, value: T);
    Query(command: SqlCommand);
}

typedef Field = {
    ?table: String,
    ?field: String,
    ?all: Bool,
}

typedef SetField = {
    field: String,
    value: SqlValue
}


enum InsertValue {
    Row(fields: Array<SqlValue>);
    Multiple(rows: Array<InsertValue>);
    Query(command: SqlCommand);
}

typedef FieldDesc = {
    name: String,
    type: SqlType<Dynamic>
}

typedef WhereClause = Array<Condition>;

enum Condition {
    Relational(field: String, binop: Binop, value: SqlValue);
    IsNull(field: String);
    IsNotNull(field: String);
    And(left: Condition, right: Condition);
    Or(left: Condition, right: Condition);
}

enum Binop {
    Eq;
    Neq;
    Gt;
    GtEq;
    Lt;
    LtEq;
    Like;
    NotLike;
    In;
    NotIn;
}

enum SqlType<T> {
    INT: SqlType<Int>;
    STRING: SqlType<String>;
    DATE: SqlType<Date>;
    BOOLEAN: SqlType<Bool>;
    FLOAT: SqlType<Float>;
    OTHER( name: String ): SqlType<Dynamic>;
    UNKNOWN: SqlType<Dynamic>;
}

enum AlterCommand {
    RenameTo( name: String );
    AddColumn( name: String, type: SqlType<Dynamic> );
    DropColumn( name: String );
    ModifyColumn( name: String, type: SqlType<Dynamic> );
    RenameColumn( oldName: String, newName: String );
}


class SqlCommandParse {

    public var tokens: Array<Token>;
    public var pos: Int;

    public function new() {
        
    }

    public function parse(args: Array<Token>): Array<SqlCommand> {
        tokens = args;
        pos = 0;
        var commands = new Array<SqlCommand>();
        while (pos < tokens.length) {
            commands.push(parseCommand());
        }
        return commands;
    }

    private function parseCommand(): SqlCommand {
        var token = nextToken();
        switch(token) {
            case Token.Kwd("SELECT"): {
                return hxsqlparser.branches.Select.parse(this);
            }
            case Token.Kwd("UPDATE"): {
                return hxsqlparser.branches.Update.parse(this);
            }
            case Token.Kwd("INSERT"): {
                return hxsqlparser.branches.Insert.parse(this);
            }
            case Token.Kwd("DELETE"): {
                return hxsqlparser.branches.Delete.parse(this);
            }
            case Token.Kwd("CREATE"): {
                return hxsqlparser.branches.Create.parse(this);
            }
            case Token.Kwd("ALTER"): {
                return hxsqlparser.branches.Alter.parse(this);
            }
            case Token.Kwd("DROP"): {
                return hxsqlparser.branches.Drop.parse(this);
            }
            case Token.Eof: {
                throw "Unexpected end of input";
            }
            default: {
                throw "Unexpected token: " + Std.string(token);
            }
        }
    }
    

    public function getSqlValue(field:Token): SqlValue{
        switch field {
            case CInt(v): return SqlValue.Value(SqlType.INT, v);
            case CFloat(v): return SqlValue.Value(SqlType.FLOAT, v);
            case CString(v): return SqlValue.Value(SqlType.STRING, v);
            default:
        }
        return SqlValue.Value(SqlType.UNKNOWN, Std.string(field));
    }
    

    public function extractValue(t: Token): Dynamic {
        switch t {
            case CInt(v): {
                return v;
            }
            case CFloat(v): {
                return v;
            }
            case Kwd(s): {
                return s;
            }
            case Ident(s): {
                return s;
            }
            case Op(op): {
                switch op {
                    case Eq: return Binop.Eq;
                    case Lt: return Binop.Lt;
                    case Gt: return Binop.Gt;
                    case LtEq: return Binop.LtEq;
                    case GtEq: return Binop.GtEq;
                    case Neq: return Binop.Neq;
                }
                return op;
            }
            default: return t;
        }
    }

    public function peekToken(): Token {
        return tokens[pos];
    }

    public function nextToken(): Token {
        return tokens[pos++];
    }

    public function parseSqlType(type: String): SqlType<Dynamic> {
        switch(type) {
            case "INT": return SqlType.INT;
            case "STRING": return SqlType.STRING;
            case "DATE": return SqlType.DATE;
            case "BOOLEAN": return SqlType.BOOLEAN;
            case "FLOAT": return SqlType.FLOAT;
            default: return SqlType.OTHER(type);
        }
    }

}