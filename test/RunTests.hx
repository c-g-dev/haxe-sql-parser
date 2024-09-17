package test;

import hxsqlparser.SqlParser;
import haxe.EnumTools;
import hxsqlparser.SqlLexer;
import hxsqlparser.SqlCommandParse;
import hxsqlparser.SqlCommandParse.SqlCommand;

class RunTests {

    public static function main() {
        testSelect();
        testInsert();
        testUpdate();
        testDelete();
        testCreateTable();
        testAlterTable();
        testDropTable();

        switch new SqlParser().parse("SELECT * FROM my_table")[0] {
            case Select(fields, fromClause, whereClause):
            case Update(table, setFields, whereClause):
            case Insert(table, fieldNames, insertValue):
            case Delete(table, whereClause):
            case CreateTable(table, fields):
            case AlterTable(table, alters):
            case DropTable(table):
        }

        trace("All tests passed successfully.");
    }

    public static function test(sql: String, expected: SqlCommand) {
        var lexer = new SqlLexer();
        var parser = new SqlCommandParse();

        var command = parser.parse(lexer.lex(sql));
        if(!(Std.string(command[0]) == Std.string(expected))){
            throw "Expected: " + Std.string(expected) + " Actual: " + Std.string(command[0]);
        }
        trace("Test passed");
    }

    public static function testSelect() {
        test("SELECT * FROM my_table", 
            SqlCommand.Select(
                [{table: "", field: "", all: true}], 
                FromClause.Table("my_table"), 
                []
            )
        );

        test("SELECT field1, field2 FROM my_table",
            SqlCommand.Select(
                [
                    {table: "", field: "field1", all: false}, 
                    {table: "", field: "field2", all: false}
                ],
                FromClause.Table("my_table"),
                []
            )
        );
    }

    public static function testInsert() {
        test("INSERT INTO my_table (col1, col2) VALUES ('value1', 123)",
            SqlCommand.Insert(
                "my_table",
                [
                    {field: "col1", all: false, table: ""}, 
                    {field: "col2", all: false, table: ""}
                ],
                InsertValue.Row([
                    SqlValue.Value(SqlType.STRING, "value1"),
                    SqlValue.Value(SqlType.INT, 123)
                ])
            )
        );

        test("INSERT INTO my_table (col1, col2) SELECT col1, col2 FROM my_table2",
        SqlCommand.Insert(
            "my_table",
            [
                {field: "col1", all: false, table: ""}, 
                {field: "col2", all: false, table: ""}
            ],
            InsertValue.Query(
                SqlCommand.Select([
                    {field: "col1", all: false, table: ""}, 
                    {field: "col2", all: false, table: ""}
                ], 
                FromClause.Table("my_table2"), 
                []),
            )
        )
    );
    }

    public static function testUpdate() {
        test("UPDATE my_table SET field1 = 'value1' WHERE id = 123",
            SqlCommand.Update(
                "my_table",
                [{ field: "field1", value:  SqlValue.Value(SqlType.STRING, "value1") }],
                [Condition.Relational("id", Binop.Eq, SqlValue.Value(SqlType.INT, 123))]
            )
        );
    }

    public static function testDelete() {
        test("DELETE FROM my_table WHERE id = 123",
            SqlCommand.Delete(
                "my_table",
                [Condition.Relational("id", Binop.Eq, SqlValue.Value(SqlType.INT, 123))]
            )
        );
    }

    public static function testCreateTable() {
        test("CREATE TABLE my_table (id INT, name STRING)",
            SqlCommand.CreateTable(
                "my_table",
                [
                    {name: "id", type: SqlType.INT},
                    {name: "name", type: SqlType.STRING}
                ]
            )
        );
    }

    public static function testAlterTable() {
        test("ALTER TABLE my_table ADD COLUMN age INT",
            SqlCommand.AlterTable(
                "my_table",
                [AlterCommand.AddColumn("age", SqlType.INT)]
            )
        );

        test("ALTER TABLE my_table RENAME TO new_table",
            SqlCommand.AlterTable(
                "my_table",
                [AlterCommand.RenameTo("new_table")]
            )
        );
    }

    public static function testDropTable() {
        test("DROP TABLE my_table",
            SqlCommand.DropTable("my_table")
        );
    }

}