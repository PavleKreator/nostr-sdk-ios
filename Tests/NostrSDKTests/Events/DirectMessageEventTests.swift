//
//  DirectMessageEventTests.swift
//  
//
//  Created by Terry Yiu on 4/14/24.
//

@testable import NostrSDK
import XCTest

final class DirectMessageEventTests: XCTestCase, EventCreating, EventVerifying, FixtureLoading {

    func testCreateDirectMessageEvent() throws {
        let content = "Secret message."
        let recipientPubKey = Keypair.test.publicKey
        let recipientTag = Tag.pubkey(recipientPubKey.hex)

        let event = try directMessage(withContent: content, toRecipient: recipientPubKey, signedBy: Keypair.test)

        // Content should contain "?iv=" if encrypted
        XCTAssert(event.content.contains("?iv="))

        // Recipient should be tagged
        let tag = try XCTUnwrap(event.tags.first)
        XCTAssertEqual(tag, recipientTag)

        // Content should be decryptable
        XCTAssertEqual(try event.decryptedContent(using: Keypair.test.privateKey), content)

        try verifyEvent(event)
    }

    func testDecodeDirectMessage() throws {
        let event: DirectMessageEvent = try decodeFixture(filename: "dm")

        XCTAssertEqual(event.content, "+0V/p6oNtFXAlWVzDTx6wg==?iv=L6gDJ8ei4k1t3lUNgYAahw==")
        XCTAssertEqual(event.id, "a606649e4995a12226902bd38573c21b04732c0835e415d09be6fbe93879b666")
        XCTAssertEqual(event.pubkey, "9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        XCTAssertEqual(event.createdAt, 1691768179)
        XCTAssertEqual(event.kind, .directMessage)

        let expectedTags: [Tag] = [
            .pubkey("9947f9659dd80c3682402b612f5447e28249997fb3709500c32a585eb0977340")
        ]
        XCTAssertEqual(expectedTags, event.tags)

        XCTAssertEqual(try event.decryptedContent(using: Keypair.test.privateKey), "Secret message.")
    }

}
