//
//  Verb.swift
//  Latin
//
//  Created by Matthew Burke on 9/15/22.
//

import Foundation

let macron = "\u{0304}"

//enum Voice: String {
//    case active
//    case passive
//}

public enum Person: String, CaseIterable {
    case first
    case second
    case third
}

public enum Number: String, CaseIterable {
    case singular
    case plural
}

public enum Tense: String, CaseIterable {
    case present
    case imperfect
    case future
    // case perfect
    // case pluperfect
    // case imperative // isn't there more than one?
}

public struct Conjugation: Hashable {
    public let person: Person
    public let number: Number
    public let tense: Tense
}

public enum ConjugationClass: String, CaseIterable, Decodable {
    case first
    case second
    case third
    case third_i // or call this "mixed" (golden book) or ???
    case fourth
}

public struct Verb: Decodable {
    public let firstPrinciplePart: String
    public let secondPrinciplePart: String
    public let thirdPrinciplePart: String
    public let fourthPrinciplePart: String // TODO: some verbs don't have one
    public let translation: String

    // TODO: can't we determine this from the second principle part?
    public let conjugationClass: ConjugationClass

    enum CodingKeys: String, CodingKey {
        case firstPrinciplePart = "1"
        case secondPrinciplePart = "2"
        case thirdPrinciplePart = "3"
        case fourthPrinciplePart = "4"
        case conjugationClass = "c"
        case translation = "t"
    }

    public init(_ fp: String, _ sp: String, _ tp: String, _ fop: String, _ t: String, _ cc: ConjugationClass) {
        firstPrinciplePart = fp
        secondPrinciplePart = sp
        thirdPrinciplePart = tp
        fourthPrinciplePart = fop
        translation = t
        conjugationClass = cc
    }

    public var root: String {
        switch conjugationClass {
        case .first, .third:
            return String(firstPrinciplePart.dropLast(1))
        case .second, .third_i, .fourth:
            return String(firstPrinciplePart.dropLast(2))
        }
    }

    public static let endings: [ConjugationClass: [Tense: [Person: [Number: String]]]] = [
        .first: [
            .present: [
                .first: [.singular: "??", .plural: "??mus"],
                .second: [.singular: "??s", .plural: "??tis"],
                .third: [.singular: "at", .plural: "ant"]
            ],
            .imperfect: [
                .first: [.singular: "??bam", .plural: "??b??mus"],
                .second: [.singular: "??b??s", .plural: "??b??tis"],
                .third: [.singular: "??bat", .plural: "??bant"]
            ],
            .future: [
                .first: [.singular: "??b??", .plural: "??bimus"],
                .second: [.singular: "??bis", .plural: "??bitis"],
                .third: [.singular: "??bit", .plural: "??bunt"]
            ],
        ],
        .second: [
            .present: [
                .first: [.singular: "e??", .plural: "??mus"],
                .second: [.singular: "??s", .plural: "??tis"],
                .third: [.singular: "et", .plural: "ent"]
            ],
            .imperfect: [
                .first: [.singular: "??bam", .plural: "??b??mus"],
                .second: [.singular: "??b??s", .plural: "??b??tis"],
                .third: [.singular: "??bat", .plural: "??bant"]
            ],
            .future: [
                .first: [.singular: "??b??", .plural: "??bimus"],
                .second: [.singular: "??bis", .plural: "??bitis"],
                .third: [.singular: "??bit", .plural: "??bunt"]
            ],
        ],
        .third: [
            .present: [
                .first: [.singular: "??", .plural: "imus"],
                .second: [.singular: "is", .plural: "itis"],
                .third: [.singular: "it", .plural: "unt"]
            ],
            .imperfect: [
                .first: [.singular: "??bam", .plural: "??b??mus"],
                .second: [.singular: "??b??s", .plural: "??b??tis"],
                .third: [.singular: "??bat", .plural: "??bant"]
            ],
            .future: [
                .first: [.singular: "am", .plural: "??mus"],
                .second: [.singular: "??s", .plural: "??tis"],
                .third: [.singular: "et", .plural: "ent"]
            ],
        ],
        .third_i: [
            .present: [
                .first: [.singular: "i??", .plural: "imus"],
                .second: [.singular: "is", .plural: "itis"],
                .third: [.singular: "it", .plural: "iunt"]
            ],
            .imperfect: [
                .first: [.singular: "i??bam", .plural: "i??b??mus"],
                .second: [.singular: "i??b??s", .plural: "i??b??tis"],
                .third: [.singular: "i??bat", .plural: "i??bant"]
            ],
            .future: [
                .first: [.singular: "iam", .plural: "i??mus"],
                .second: [.singular: "i??s", .plural: "i??tis"],
                .third: [.singular: "iet", .plural: "ient"]
            ],
        ],
        .fourth: [
            .present: [
                .first: [.singular: "i??", .plural: "??mus"],
                .second: [.singular: "??s", .plural: "??tis"],
                .third: [.singular: "it", .plural: "iunt"]
            ],
            .imperfect: [
                .first: [.singular: "i??bam", .plural: "i??b??mus"],
                .second: [.singular: "i??b??s", .plural: "i??b??tis"],
                .third: [.singular: "i??bat", .plural: "i??bant"]
            ],
            .future: [
                .first: [.singular: "iam", .plural: "i??mus"],
                .second: [.singular: "i??s", .plural: "i??tis"],
                .third: [.singular: "iet", .plural: "ient"]
            ],
        ]
    ]

    // TODO: maybe return optional since some verbs may not have a particular conjugation
    public func conjugate(person: Person, number: Number, tense: Tense/*, voice: Voice = .active*/) -> String {
        guard let ending = Verb.endings[conjugationClass]?[tense]?[person]?[number] else {
            print("Oops! \(secondPrinciplePart): \(person)-\(number)-\(tense) -- can't find ending :(")
            return "Oops"
        }

        return root + ending
    }
}

extension Verb {
    public static let allConjugations: [Conjugation] = {
        var result: [Conjugation] = []

        Person.allCases.forEach { person in
            Number.allCases.forEach { number in
                Tense.allCases.forEach { tense in
                    result.append(Conjugation(person: person, number: number, tense: tense))
                }
            }
        }

        return result
    }()
}
