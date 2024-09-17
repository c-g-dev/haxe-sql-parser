package hxsqlparser;

import hxsqlparser.SqlCommandParse.SqlCommand;

class SqlParser {
    public function new() {
        
    }

    public function parse(sql: String): Array<SqlCommand> {
        var lexer = new SqlLexer();
        var parser = new SqlCommandParse();
        return parser.parse(lexer.lex(sql));
    }
}