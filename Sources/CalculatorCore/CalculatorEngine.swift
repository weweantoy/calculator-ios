//
//  CalculatorEngine.swift
//  CalculatorCore
//
//  表达式解析与求值引擎：
//  - Tokenizer：词法分析，将字符串分解为 Token
//  - Parser：Recursive Descent，构建 AST
//  - Evaluator：遍历 AST，使用 Decimal 精度求值
//
//  支持：+ - × ÷ % 括号 一元负号 科学函数（sin/cos/tan/log/ln/sqrt/x²）常量（π/e）
//

import Foundation

// MARK: - 错误类型

public enum CalculatorError: Error, Equatable, Sendable {
    case invalidToken(position: Int)
    case unexpectedEndOfInput
    case unexpectedToken(Token, expected: String)
    case divisionByZero
    case invalidFunctionArgument(function: String)
    case numberOutOfRange

    public var localizedDescription: String {
        switch self {
        case .invalidToken(let pos):          return "无效字符 (位置 \(pos))"
        case .unexpectedEndOfInput:           return "表达式未结束"
        case .unexpectedToken(_, let exp):    return "期望 \(exp)"
        case .divisionByZero:                 return "除数不能为零"
        case .invalidFunctionArgument(let f): return "\(f) 参数无效"
        case .numberOutOfRange:               return "数值超出范围"
        }
    }
}

// MARK: - AST 节点

indirect enum CalcNode: Equatable {
    case number(Decimal)
    case unary(op: CalcUnaryOp, operand: CalcNode)
    case binary(op: CalcBinaryOp, left: CalcNode, right: CalcNode)
    case function(name: String, argument: CalcNode)
    case constant(name: String)
    case percent(operand: CalcNode)
}

enum CalcUnaryOp: Equatable { case negate }

enum CalcBinaryOp: Equatable { case plus, minus, multiply, divide }

// MARK: - Engine

public final class CalculatorEngine: @unchecked Sendable {

    /// 当前角度单位
    public var angleUnit: AngleUnit

    public init(angleUnit: AngleUnit = .degree) {
        self.angleUnit = angleUnit
    }

    // MARK: Public API

    /// 求值入口
    /// - Parameter input: 表达式字符串（支持 + - × ÷ * / π e sin cos tan log ln sqrt 等）
    /// - Returns: Decimal 精度结果
    public func evaluate(_ input: String) throws -> Decimal {
        let trimmed = input.replacingOccurrences(of: " ", with: "")
        guard !trimmed.isEmpty else {
            throw CalculatorError.unexpectedEndOfInput
        }

        let tokens = try Self.tokenize(trimmed)
        var parser = Parser(tokens: tokens)
        let ast = try parser.parseExpression()
        if !parser.isAtEnd {
            throw CalculatorError.unexpectedToken(parser.peek(), expected: "end of expression")
        }
        return try evaluate(ast)
    }

    // MARK: - Tokenizer

    private static func tokenize(_ input: String) throws -> [Token] {
        var tokens: [Token] = []
        var idx = input.startIndex
        let startIndex = input.startIndex

        while idx < input.endIndex {
            let ch = input[idx]

            // 跳过空白
            if ch.isWhitespace {
                idx = input.index(after: idx)
                continue
            }

            // 数字 / 小数点
            if ch.isNumber || ch == "." {
                let pos = input.distance(from: startIndex, to: idx)
                let (tok, nextIdx) = try readNumber(input: input, from: idx, position: pos)
                tokens.append(tok)
                idx = nextIdx
                continue
            }

            // 标识符（函数名 / 常量）
            if ch.isLetter {
                let pos = input.distance(from: startIndex, to: idx)
                let (tok, nextIdx) = try readIdentifier(input: input, from: idx, position: pos)
                tokens.append(tok)
                idx = nextIdx
                continue
            }

            // 单字符符号
            let pos = input.distance(from: startIndex, to: idx)
            switch ch {
            case "+":
                tokens.append(Token(type: .plus, position: pos))
            case "-":
                tokens.append(Token(type: .minus, position: pos))
            case "*", "×", "·":
                tokens.append(Token(type: .multiply, position: pos))
            case "/", "÷":
                tokens.append(Token(type: .divide, position: pos))
            case "%":
                tokens.append(Token(type: .percent, position: pos))
            case "(":
                tokens.append(Token(type: .leftParen, position: pos))
            case ")":
                tokens.append(Token(type: .rightParen, position: pos))
            case ",":
                tokens.append(Token(type: .comma, position: pos))
            default:
                throw CalculatorError.invalidToken(position: pos)
            }
            idx = input.index(after: idx)
        }

        return tokens
    }

    /// 读取连续数字（含小数点）
    private static func readNumber(input: String, from start: String.Index, position: Int)
        throws -> (Token, String.Index)
    {
        var idx = start
        var raw = ""
        var seenDot = false
        while idx < input.endIndex {
            let ch = input[idx]
            if ch.isNumber {
                raw.append(ch)
                idx = input.index(after: idx)
            } else if ch == "." && !seenDot {
                seenDot = true
                raw.append(ch)
                idx = input.index(after: idx)
            } else {
                break
            }
        }
        guard let value = Decimal(string: raw, locale: Locale(identifier: "en_US_POSIX")) else {
            throw CalculatorError.invalidToken(position: position)
        }
        return (Token(type: .number(value), position: position), idx)
    }

    /// 读取标识符（函数 / 常量）
    private static func readIdentifier(input: String, from start: String.Index, position: Int)
        throws -> (Token, String.Index)
    {
        var idx = start
        var raw = ""
        while idx < input.endIndex && input[idx].isLetter {
            raw.append(input[idx])
            idx = input.index(after: idx)
        }
        let lower = raw.lowercased()
        switch lower {
        case "sin", "cos", "tan", "log", "ln", "sqrt":
            return (Token(type: .function(lower), position: position), idx)
        case "pi":
            return (Token(type: .constant("pi"), position: position), idx)
        case "e":
            return (Token(type: .constant("e"), position: position), idx)
        default:
            throw CalculatorError.invalidToken(position: position)
        }
    }

    // MARK: - Parser (Recursive Descent)
    //
    // 语法：
    //   expression = term (('+' | '-') term)*
    //   term       = factor (('*' | '/') factor)*
    //   factor     = ('+' | '-') factor | unary
    //   unary      = primary ('%')?
    //   primary    = number | '(' expression ')' | function | constant

    private struct Parser {
        let tokens: [Token]
        var index: Int = 0

        var isAtEnd: Bool { index >= tokens.count }
        func peek() -> Token { tokens[index] }

        @discardableResult
        mutating func advance() -> Token {
            defer { index += 1 }
            return tokens[index]
        }

        mutating func consume(_ type: TokenType) throws -> Token {
            if peek().type == type {
                return advance()
            }
            throw CalculatorError.unexpectedToken(peek(), expected: "\(type)")
        }

        mutating func parseExpression() throws -> CalcNode {
            var left = try parseTerm()
            while !isAtEnd {
                switch peek().type {
                case .plus:
                    _ = advance()
                    let right = try parseTerm()
                    left = .binary(op: .plus, left: left, right: right)
                case .minus:
                    _ = advance()
                    let right = try parseTerm()
                    left = .binary(op: .minus, left: left, right: right)
                default:
                    return left
                }
            }
            return left
        }

        mutating func parseTerm() throws -> CalcNode {
            var left = try parseFactor()
            while !isAtEnd {
                switch peek().type {
                case .multiply:
                    _ = advance()
                    let right = try parseFactor()
                    left = .binary(op: .multiply, left: left, right: right)
                case .divide:
                    _ = advance()
                    let right = try parseFactor()
                    left = .binary(op: .divide, left: left, right: right)
                default:
                    return left
                }
            }
            return left
        }

        mutating func parseFactor() throws -> CalcNode {
            guard !isAtEnd else {
                throw CalculatorError.unexpectedEndOfInput
            }
            switch peek().type {
            case .minus:
                _ = advance()
                let operand = try parseFactor()
                return .unary(op: .negate, operand: operand)
            case .plus:
                _ = advance()
                return try parseFactor()
            default:
                return try parseUnary()
            }
        }

        mutating func parseUnary() throws -> CalcNode {
            var node = try parsePrimary()
            if !isAtEnd, case .percent = peek().type {
                _ = advance()
                node = .percent(operand: node)
            }
            return node
        }

        mutating func parsePrimary() throws -> CalcNode {
            guard !isAtEnd else {
                throw CalculatorError.unexpectedEndOfInput
            }
            let tok = advance()
            switch tok.type {
            case .number(let v):
                return .number(v)
            case .leftParen:
                let expr = try parseExpression()
                _ = try consume(.rightParen)
                return expr
            case .function(let name):
                _ = try consume(.leftParen)
                let arg = try parseExpression()
                _ = try consume(.rightParen)
                return .function(name: name, argument: arg)
            case .constant(let name):
                return .constant(name: name)
            default:
                throw CalculatorError.unexpectedToken(tok, expected: "数字、'('、函数或常量")
            }
        }
    }

    // MARK: - Evaluator

    private func evaluate(_ node: CalcNode) throws -> Decimal {
        switch node {
        case .number(let v):
            return v

        case .unary(.negate, let operand):
            return -(try evaluate(operand))

        case .binary(let op, let left, let right):
            let l = try evaluate(left)
            let r = try evaluate(right)
            switch op {
            case .plus:     return l + r
            case .minus:    return l - r
            case .multiply: return l * r
            case .divide:
                if r == 0 { throw CalculatorError.divisionByZero }
                return l / r
            }

        case .function(let name, let arg):
            let v = try evaluate(arg)
            switch name {
            case "sin":
                return angleUnit == .degree ? v.sineDegrees : v.sine
            case "cos":
                return angleUnit == .degree ? v.cosineDegrees : v.cosine
            case "tan":
                return angleUnit == .degree ? v.tangentDegrees : v.tangent
            case "log":
                guard v > 0 else { throw CalculatorError.invalidFunctionArgument(function: "log") }
                return v.commonLog
            case "ln":
                guard v > 0 else { throw CalculatorError.invalidFunctionArgument(function: "ln") }
                return v.naturalLog
            case "sqrt":
                guard v >= 0 else { throw CalculatorError.invalidFunctionArgument(function: "sqrt") }
                return v.squareRoot
            default:
                throw CalculatorError.invalidFunctionArgument(function: name)
            }

        case .constant(let name):
            switch name {
            case "pi": return .piValue
            case "e":  return .eValue
            default:   throw CalculatorError.invalidFunctionArgument(function: name)
            }

        case .percent(let operand):
            let v = try evaluate(operand)
            return v / Decimal(100)
        }
    }
}