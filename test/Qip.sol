// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/QipController.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract CounterTest is Test {
    QipController public qip;

    function setUp() public {
        ERC20 mockERC20 = new ERC20("MockERC20", "MERC20");
        address mockERC721_A = new ERC721("MockERC721_A", "MERC721_A");
        address mockERC721_B = new ERC721("MockERC721_B", "MERC721_B");
        address mockERC721_C = new ERC721("MockERC721_C", "MERC721_C");

        uint price_A = 1;
        uint price_B = 10;
        uint price_C = 100;

        qip = new QipController(
            mockERC20,
            mockERC721_A,
            mockERC721_B,
            mockERC721_C,
            price_A,
            price_B,
            price_C
        );
    }

    // function testIncrement() public {
    //     counter.increment();
    //     assertEq(counter.number(), 1);
    // }

    // function testSetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
