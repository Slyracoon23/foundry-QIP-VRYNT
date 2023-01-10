// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "./VerificationNFT.sol";

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract QipController {
    using SafeERC20 for IERC20Metadata;

    address private owner;
    address private approved_contract;

    // VRYNT TOKENS

    IERC20Metadata private token;
    VerificationNFT private status_badge_rank_1;
    VerificationNFT private status_badge_rank_2;
    VerificationNFT private status_badge_rank_3;

    uint public status_badge_price_rank_1;
    uint public status_badge_price_rank_2;
    uint public status_badge_price_rank_3;

    // REWARD AMOUNTS

    uint rank_1_benefits;
    uint rank_2_benefits;
    uint rank_3_benefits;

    uint private nft_purchase_amount;
    uint private cardpack_purchase_amount;
    uint private nft_rank_amount;

    struct Participant {
        uint rank;
        uint tokenID_rank_1;
        uint tokenID_rank_2;
        uint tokenID_rank_3;
        uint entryPrice;
        uint pool;
    }

    mapping(address => Participant) participants;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the Owner can Call this function");
        _;
    }

    modifier approvedContractOnly() {
        require(
            msg.sender == owner || msg.sender == approved_contract,
            "Only the aproved smart contract can call this function"
        );
        _;
    }

    event RewardedNftPurchase(address rewarded_user);
    event RewardedCardpackPurchase(address rewarded_user);
    event RewardedNftRank(address rewarded_user);

    event NewApprovedContract(address new_contract);
    event NewPrice(uint price);

    constructor(
        address _ERC20_token,
        address _ERC721_token_1,
        address _ERC721_token_2,
        address _ERC721_token_3,
        uint _price_1,
        uint _price_2,
        uint _price_3
    ) {
        // Define Owner of contract
        owner = msg.sender;
        // Define Tokens
        token = IERC20Metadata(_ERC20_token);
        status_badge_rank_1 = VerificationNFT(_ERC721_token_1);
        status_badge_rank_2 = VerificationNFT(_ERC721_token_2);
        status_badge_rank_3 = VerificationNFT(_ERC721_token_3);

        status_badge_price_rank_1 = _price_1 * token.decimals();
        status_badge_price_rank_2 = _price_2 * token.decimals();
        status_badge_price_rank_3 = _price_3 * token.decimals();
    }

    // ENTER QIP STAKING PROGRAM

    function enter_program(uint _rank) public {
        require(_rank > 0 && _rank <= 3, "Must be valid rank");

        if (_rank == 3) {
            uint256 allowance_ = token.allowance(msg.sender, address(this));
            require(
                allowance_ >= status_badge_price_rank_3,
                "Allowance is not enough for an NFT"
            );
            require(
                token.balanceOf(msg.sender) > status_badge_price_rank_3,
                "Balance is not enough"
            );

            token.transferFrom(
                msg.sender,
                address(this),
                status_badge_price_rank_3
            );
            uint _tokenID_3 = status_badge_rank_3.mint(msg.sender);
            uint _tokenID_2 = status_badge_rank_2.mint(msg.sender);
            uint _tokenID_1 = status_badge_rank_1.mint(msg.sender);

            participants[msg.sender] = Participant(
                1,
                _tokenID_1,
                _tokenID_2,
                _tokenID_3,
                status_badge_price_rank_3,
                0
            );
        }
        if (_rank == 2) {
            uint256 allowance_ = token.allowance(msg.sender, address(this));
            require(
                allowance_ >= status_badge_price_rank_2,
                "Allowance is not enough for an NFT"
            );
            require(
                token.balanceOf(msg.sender) > status_badge_price_rank_2,
                "Balance is not enough"
            );

            token.transferFrom(
                msg.sender,
                address(this),
                status_badge_price_rank_2
            );
            uint _tokenID_2 = status_badge_rank_2.mint(msg.sender);
            uint _tokenID_1 = status_badge_rank_1.mint(msg.sender);

            participants[msg.sender] = Participant(
                1,
                _tokenID_1,
                _tokenID_2,
                0,
                status_badge_price_rank_2,
                0
            );
        }
        if (_rank == 1) {
            uint256 allowance_ = token.allowance(msg.sender, address(this));
            require(
                allowance_ >= status_badge_price_rank_1,
                "Allowance is not enough for an NFT"
            );
            require(
                token.balanceOf(msg.sender) > status_badge_price_rank_1,
                "Balance is not enough"
            );

            token.transferFrom(
                msg.sender,
                address(this),
                status_badge_price_rank_1
            );
            uint _tokenID_1 = status_badge_rank_1.mint(msg.sender);

            participants[msg.sender] = Participant(
                1,
                _tokenID_1,
                0,
                0,
                status_badge_price_rank_1,
                0
            );
        }
    }

    // LEAVE QIP STAKING PROGRAM

    function leaveProgram() public {
        require(
            participants[msg.sender].rank != 0,
            "You are not in the program"
        );

        if (participants[msg.sender].rank == 3) {
            require(
                status_badge_rank_3.ownerOf(
                    participants[msg.sender].tokenID_rank_3
                ) == msg.sender,
                "You do not own this NFT 3"
            );
            require(
                status_badge_rank_2.ownerOf(
                    participants[msg.sender].tokenID_rank_2
                ) == msg.sender,
                "You do not own this NFT 2"
            );
            require(
                status_badge_rank_1.ownerOf(
                    participants[msg.sender].tokenID_rank_1
                ) == msg.sender,
                "You do not own this NFT 1"
            );
            status_badge_rank_3.burn(participants[msg.sender].tokenID_rank_3);
            status_badge_rank_2.burn(participants[msg.sender].tokenID_rank_2);
            status_badge_rank_1.burn(participants[msg.sender].tokenID_rank_1);

            token.transfer(msg.sender, participants[msg.sender].pool);
            token.transfer(msg.sender, participants[msg.sender].entryPrice);

            participants[msg.sender] = Participant(0, 0, 0, 0, 0, 0);
        }
        if (participants[msg.sender].rank == 2) {
            require(
                status_badge_rank_2.ownerOf(
                    participants[msg.sender].tokenID_rank_2
                ) == msg.sender,
                "You do not own this NFT 2"
            );
            require(
                status_badge_rank_1.ownerOf(
                    participants[msg.sender].tokenID_rank_1
                ) == msg.sender,
                "You do not own this NFT 1"
            );
            status_badge_rank_2.burn(participants[msg.sender].tokenID_rank_2);
            status_badge_rank_1.burn(participants[msg.sender].tokenID_rank_1);

            token.transfer(msg.sender, participants[msg.sender].pool);
            token.transfer(msg.sender, participants[msg.sender].entryPrice);

            participants[msg.sender] = Participant(0, 0, 0, 0, 0, 0);
        }
        if (participants[msg.sender].rank == 1) {
            require(
                status_badge_rank_1.ownerOf(
                    participants[msg.sender].tokenID_rank_1
                ) == msg.sender,
                "You do not own this NFT 1"
            );
            status_badge_rank_1.burn(participants[msg.sender].tokenID_rank_1);

            token.transfer(msg.sender, participants[msg.sender].pool);
            token.transfer(msg.sender, participants[msg.sender].entryPrice);

            participants[msg.sender] = Participant(0, 0, 0, 0, 0, 0);
        }
    }

    // REWARDING PARTICIPANTS
    // Must set an approved contract, or wallet address prior.

    function reward_nft_purchase(
        address _invite_creator
    ) public approvedContractOnly {
        participants[_invite_creator].pool =
            participants[_invite_creator].pool +
            nft_purchase_amount;
        emit RewardedNftPurchase(_invite_creator);
    }

    function reward_cardpack_purchase(
        address _invite_creator
    ) public approvedContractOnly {
        participants[_invite_creator].pool =
            participants[_invite_creator].pool +
            cardpack_purchase_amount;
        emit RewardedCardpackPurchase(_invite_creator);
    }

    function reward_nft_rank(
        address _invite_creator
    ) public approvedContractOnly {
        participants[_invite_creator].pool =
            participants[_invite_creator].pool +
            nft_rank_amount;
        emit RewardedNftRank(_invite_creator);
    }

    // Participant View Functions

    function currentRank() public view returns (uint) {
        return (participants[msg.sender].rank);
    }

    function currentRewards() public view returns (uint) {
        return (participants[msg.sender].pool);
    }

    // Participant Status Functions

    function claimRewards() public {
        require(participants[msg.sender].pool != 0, "No Rewards to claim");

        token.transfer(msg.sender, participants[msg.sender].pool);
        participants[msg.sender].pool = 0;
    }

    function upgrade(bool _UseRewards) public {
        require(participants[msg.sender].rank != 0, "Must enter the program");
        require(participants[msg.sender].rank != 3, "Can not Upgrade");

        if (participants[msg.sender].rank == 1 && _UseRewards == true) {
            uint _balance = participants[msg.sender].pool;
            uint _amountNeeded = status_badge_price_rank_2 -
                participants[msg.sender].entryPrice;
            if (_balance >= _amountNeeded) {
                participants[msg.sender].pool = _amountNeeded - _balance;
                participants[msg.sender].entryPrice = status_badge_price_rank_2;

                uint _tokenID_2 = status_badge_rank_2.mint(msg.sender);
                participants[msg.sender].tokenID_rank_2 = _tokenID_2;

                participants[msg.sender].rank =
                    participants[msg.sender].rank +
                    1;
            }
            if (_balance < _amountNeeded) {
                require(
                    token.allowance(msg.sender, address(this)) + _balance >=
                        _amountNeeded,
                    "Your allowance isn't enough"
                );
                require(
                    token.balanceOf(msg.sender) + _balance >= _amountNeeded,
                    "Your balance is too low"
                );

                participants[msg.sender].pool = 0;
                participants[msg.sender].entryPrice = status_badge_price_rank_2;

                token.transferFrom(
                    msg.sender,
                    address(this),
                    _amountNeeded - _balance
                );
                uint _tokenID_2 = status_badge_rank_2.mint(msg.sender);
                participants[msg.sender].tokenID_rank_2 = _tokenID_2;

                participants[msg.sender].rank =
                    participants[msg.sender].rank +
                    1;
            }
        }
        if (participants[msg.sender].rank == 2 && _UseRewards == true) {
            uint _balance = participants[msg.sender].pool;
            uint _amountNeeded = status_badge_price_rank_3 -
                participants[msg.sender].entryPrice;
            if (_balance >= _amountNeeded) {
                participants[msg.sender].pool = _amountNeeded - _balance;
                participants[msg.sender].entryPrice = status_badge_price_rank_3;

                uint _tokenID_3 = status_badge_rank_3.mint(msg.sender);
                participants[msg.sender].tokenID_rank_3 = _tokenID_3;

                participants[msg.sender].rank =
                    participants[msg.sender].rank +
                    1;
            }
            if (_balance < _amountNeeded) {
                require(
                    token.allowance(msg.sender, address(this)) + _balance >=
                        _amountNeeded,
                    "Your allowance isn't enough"
                );
                require(
                    token.balanceOf(msg.sender) + _balance >= _amountNeeded,
                    "Your balance is too low"
                );

                participants[msg.sender].pool = 0;
                participants[msg.sender].entryPrice = status_badge_price_rank_3;

                token.transferFrom(
                    msg.sender,
                    address(this),
                    _amountNeeded - _balance
                );
                uint _tokenID_3 = status_badge_rank_3.mint(msg.sender);
                participants[msg.sender].tokenID_rank_3 = _tokenID_3;

                participants[msg.sender].rank =
                    participants[msg.sender].rank +
                    1;
            }
        }
        if (participants[msg.sender].rank == 1 && _UseRewards == false) {
            uint _amountNeeded = status_badge_price_rank_2 -
                participants[msg.sender].entryPrice;
            require(
                token.allowance(msg.sender, address(this)) >= _amountNeeded,
                "Your allowance isn't enough"
            );
            require(
                token.balanceOf(msg.sender) >= _amountNeeded,
                "Your balance is too low"
            );

            participants[msg.sender].entryPrice = status_badge_price_rank_2;

            token.transferFrom(msg.sender, address(this), _amountNeeded);
            uint _tokenID_2 = status_badge_rank_2.mint(msg.sender);
            participants[msg.sender].tokenID_rank_2 = _tokenID_2;

            participants[msg.sender].rank = participants[msg.sender].rank + 1;
        }
        if (participants[msg.sender].rank == 2 && _UseRewards == false) {
            uint _amountNeeded = status_badge_price_rank_3 -
                participants[msg.sender].entryPrice;
            require(
                token.allowance(msg.sender, address(this)) >= _amountNeeded,
                "Your allowance isn't enough"
            );
            require(
                token.balanceOf(msg.sender) >= _amountNeeded,
                "Your balance is too low"
            );

            participants[msg.sender].entryPrice = status_badge_price_rank_3;

            token.transferFrom(msg.sender, address(this), _amountNeeded);
            uint _tokenID_3 = status_badge_rank_3.mint(msg.sender);
            participants[msg.sender].tokenID_rank_3 = _tokenID_3;

            participants[msg.sender].rank = participants[msg.sender].rank + 1;
        }
    }

    // Controller Adjustment Functions

    function approve_new_contract(address _newContract) public onlyOwner {
        approved_contract = _newContract;
        emit NewApprovedContract(approved_contract);
    }

    function adjust_entry_price_rank_1(
        uint256 _newPrice
    ) public approvedContractOnly {
        status_badge_price_rank_1 = _newPrice * token.decimals();
        emit NewPrice(status_badge_price_rank_1);
    }

    function adjust_entry_price_rank_2(
        uint256 _newPrice
    ) public approvedContractOnly {
        status_badge_price_rank_2 = _newPrice * token.decimals();
        emit NewPrice(status_badge_price_rank_2);
    }

    function adjust_entry_price_rank_3(
        uint256 _newPrice
    ) public approvedContractOnly {
        status_badge_price_rank_3 = _newPrice * token.decimals();
        emit NewPrice(status_badge_price_rank_3);
    }

    function adjust_reward_nft_purchase(
        uint _newRewardAmount
    ) public approvedContractOnly {
        nft_purchase_amount = _newRewardAmount;
    }

    function adjust_reward_cardpack_purchase(
        uint _newRewardAmount
    ) public approvedContractOnly {
        cardpack_purchase_amount = _newRewardAmount;
    }

    function adjust_reward_nft_rank(
        uint _newRewardAmount
    ) public approvedContractOnly {
        nft_rank_amount = _newRewardAmount;
    }

    function changeToken(
        address _newToken,
        uint _newPrice_1,
        uint _newPrice_2,
        uint _newPrice_3
    ) public approvedContractOnly {
        token = IERC20Metadata(_newToken);

        adjust_entry_price_rank_1(_newPrice_1);
        adjust_entry_price_rank_2(_newPrice_2);
        adjust_entry_price_rank_3(_newPrice_3);
    }
}
