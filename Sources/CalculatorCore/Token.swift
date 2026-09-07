//
//  Token.swift
//  CalculatorCore
//
//  表达式 Token 定义：词法分析阶段的最小语义单元。
//

import Foundation

/// 表达式 Token 类型
public enum TokenType: Equatable, Sendable {
    case number(Decimal)
    case plus
    case minus
    case multiply
    case divide
    case power              // '^' 幂运算（右结合，优先级高于 * /）
    case percent
    case leftParen
    case rightParen
    case comma
    case unaryMinus       // 一元负号
    case function(String) // sin / cos / tan / log / ln / sqrt / square
    case constant(String) // pi / e
    case end              // 末尾哨兵（越界保护）
}

/// 表达式 Token
public struct Token: Equatable, Sendable {
    public let type: TokenType
    public let position: Int  // 在源字符串中的字符位置，便于错误定位

    public init(type: TokenType, position: Int) {
        self.type = type
        self.position = position
    }
}

/// Token 流，由 Tokenizer 产出。
public struct TokenStream {
    public let tokens: [Token]

    public init(tokens: [Token]) {
        self.tokens = tokens
    }

    public var isEmpty: Bool { tokens.isEmpty }
    public var count: Int { tokens.count }
}

// MARK: - TokenType 自描述

extension TokenType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .number:       return "数字"
        case .plus:         return "'+'"
        case .minus:        return "'-'"
        case .multiply:     return "'×'"
        case .divide:       return "'÷'"
        case .power:        return "'^'"
        case .percent:      return "'%'"
        case .leftParen:    return "'('"
        case .rightParen:   return "')'"
        case .comma:        return "','"
        case .unaryMinus:   return "一元负号"
        case .function(let n): return "函数(\(n))"
        case .constant(let n): return "常量(\(n))"
        case .end:        return "结束"
        }
    }
}