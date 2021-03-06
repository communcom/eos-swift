import Foundation
import XCTest

@testable import eosswift

class DelegateBandwidthChainTests: XCTestCase {

    func testDelegateBandwidth() throws {
        let chainApi = ChainApiFactory.create(rootUrl: Config.CHAIN_API_BASE_URL, useLogger: true)
        let setupTransactions = SetupTransactions(chainApi: chainApi)

        let accountName = TestUtils.generateUniqueAccountName()
        let accountPrivateKey = try EOSPrivateKey()

        /* New account */
        let newAccountResponse = try setupTransactions.createAccount(accountName: accountName, privateKey: accountPrivateKey).asObservable().toBlocking().first()

        /* Transfer funds to new account */
        let transferResponse = try setupTransactions.transfer(to: accountName).asObservable().toBlocking().first()

        /* Delegate bandwidth */
        let delegateBandwidthResponse = try DelegateBandwidthChain(chainApi: chainApi).delegateBandwidth(
            args: DelegateBandwidthChain.Args(
                from: accountName,
                receiver: accountName,
                netQuantity: "0.0001 EOS",
                cpuQuantity: "0.0001 EOS",
                transfer: false
            ),
            transactionContext: TransactionContext(
                authorizingAccountName: accountName,
                authorizingPrivateKey: accountPrivateKey,
                expirationDate: Date.defaultTransactionExpiry()
            )
        ).asObservable().toBlocking().first()

        XCTAssertTrue(newAccountResponse!.success)
        XCTAssertNotNil(newAccountResponse!.body)
        XCTAssertTrue(transferResponse!.success)
        XCTAssertNotNil(transferResponse!.body)
        XCTAssertTrue(delegateBandwidthResponse!.success)
        XCTAssertNotNil(delegateBandwidthResponse!.body)

        /* Verify bandwidth has increased */
        let afterAccount = try chainApi.getAccount(body: AccountName(account_name: accountName)).asObservable().toBlocking().first()
        XCTAssertEqual("1.0001 EOS", afterAccount!.body!.total_resources!.cpu_weight)
        XCTAssertEqual("0.1001 EOS", afterAccount!.body!.total_resources!.net_weight)
    }
}
