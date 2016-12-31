import XCTest
import Fluent
import FluentMySQL

@testable import Sugar

class CreatorMySQLTests: XCTestCase {
   
    // MARK: DATE
    func testDate() {
        let builder = Schema.Creator("table")
        builder.date("column")
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATE NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testDateOptional() {
        let builder = Schema.Creator("table")
        builder.date("column", optional: true)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATE)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testDateUnique() {
        let builder = Schema.Creator("table")
        builder.date("column", optional: true, unique: true)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATE UNIQUE)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testDateDefaultValue() {
        let builder = Schema.Creator("table")
        builder.date("column", optional: true, defaultValue: "2000-01-01")
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATE DEFAULT 2000-01-01)") // Waiting for PR to add '2000-01-01 00:00:00'
        XCTAssertEqual(values.count, 0)
    }
    
    // MARK: DATETIME
    func testDateTime() {
        let builder = Schema.Creator("table")
        builder.datetime("column")
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATETIME NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testDateTimeOptional() {
        let builder = Schema.Creator("table")
        builder.datetime("column", optional: true)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATETIME)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testDateTimeUnique() {
        let builder = Schema.Creator("table")
        builder.datetime("column", optional: true, unique: true)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATETIME UNIQUE)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testDateTimeDefaultValue() {
        let builder = Schema.Creator("table")
        builder.datetime("column", optional: true, defaultValue: "2000-01-01 00:00:00")
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` DATETIME DEFAULT 2000-01-01 00:00:00)") // Waiting for PR to add '2000-01-01 00:00:00'
        XCTAssertEqual(values.count, 0)
    }
    
    // MARK: Timestamps
    func testTimestamps() {
        let builder = Schema.Creator("table")
        builder.timestamps()
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`created_at` DATETIME, `updated_at` DATETIME)")
        XCTAssertEqual(values.count, 0)
    }
    
    // MARK: INT
    func testInteger() {
        let builder = Schema.Creator("table")
        builder.integer("column")
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` INTEGER(11) NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testIntegerSigned() {
        let builder = Schema.Creator("table")
        builder.integer("column", signed: false)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` INTEGER(10) UNSIGNED NOT NULL)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testIntegerOptional() {
        let builder = Schema.Creator("table")
        builder.integer("column", optional: true)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` INTEGER(11))")
        XCTAssertEqual(values.count, 0)
    }
    
    func testIntegerUnique() {
        let builder = Schema.Creator("table")
        builder.integer("column", optional: true, unique: true)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` INTEGER(11) UNIQUE)")
        XCTAssertEqual(values.count, 0)
    }
    
    func testIntegerDefault() {
        let builder = Schema.Creator("table")
        builder.integer("column", optional: true, defaultValue: 0)
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` INTEGER(11) DEFAULT 0)") // Waiting for PR to add '0'
        XCTAssertEqual(values.count, 0)
    }
    
    // MARK: TEMP TEST
    func test() {
        let builder = Schema.Creator("table")
        builder.string("column", default: "test")
        
        let sql = builder.schema.sql
        let serializer = MySQLSerializer(sql: sql)
        
        let (statement, values) = serializer.serialize()
        
        XCTAssertEqual(statement, "CREATE TABLE `table` (`column` VARCHAR(255) NOT NULL DEFAULT test)") // Waiting for PR to add 'test'
        XCTAssertEqual(values.count, 0)
    }
    
    static var allTests : [(String, (CreatorMySQLTests) -> () throws -> Void)] {
        return [
            // DATE
            ("testDate", testDate),
            ("testDateOptional", testDateOptional),
            ("testDateDefaultValue", testDateDefaultValue),
            ("testDateUnique", testDateUnique),
            
            // DATETIME
            ("testDateTime", testDateTime),
            ("testDateTimeOptional", testDateTimeOptional),
            ("testDateTimeDefaultValue", testDateTimeDefaultValue),
            ("testDateTimeUnique", testDateTimeUnique),
            
            // TIMESTAMPS
            ("testTimestamps", testTimestamps),
            
            //INT
            ("testInteger", testInteger),
            ("testIntegerSigned", testIntegerSigned),
            ("testIntegerOptional", testIntegerOptional),
            ("testIntegerUnique", testIntegerUnique),
            ("testIntegerDefault", testIntegerDefault),
            
            //
            ("test", test),
        ]
    }
}
