# Haxe SQL Parser

Parses basic SQL queries into a Haxe enum structure.

## Install

```
haxelib install heaps-svg-lite
```

## Usage

```haxe

        switch new SqlParser().parse("SELECT * FROM my_table")[0] {
            case Select(fields, fromClause, whereClause):
            case Update(table, setFields, whereClause):
            case Insert(table, fieldNames, insertValue):
            case Delete(table, whereClause):
            case CreateTable(table, fields):
            case AlterTable(table, alters):
            case DropTable(table):
        }

```

This does not implement the entire SQL featureset, as there are many esoteric SQL commands and many implementation dialects. The structure of this repo is pretty simple, so if you need to parse out more advanced SQL queries it should be trivial to add those cases as you need them.
