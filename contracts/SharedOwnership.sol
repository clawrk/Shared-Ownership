// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "./ReEntrancyGuard.sol";

/**
When will this contract be used ? 
-> When a group of people want joint ownership over an entitiy.
-> The current owner of the Asset should be able to do the following : 
    1) Transfer ownership to the SharedOwnership smart contract initiated by the group customers
    2) Recieve funds from smart contract
 */
contract SharedOwnership is Ownable, Pausable, IERC721Receiver, ReEntrancyGuard {

    enum DECISION_POLICY { MAJORITY_APPROVAL, COMBINED_APPROVAL }

    event DebugEvent(address indexed _from);

    struct Member {
        address memberAddress;  // address of the member
        uint256 joinedAt;       // timestamp
    }

    //total number of members
    uint8 public memberCount;

    //token id of the asset
    string public sharedTokenId;

    //contract address of the asset
    address public sharedAssetAddress;

    //checks whether the asset has been selected
    //must be set to true before purchasing the asset
    bool public assetSelectedFlag;

    //list of members
    mapping(uint32 => Member) public memberMap;

    //sign up attendance of applicants
    mapping(address => bool) public memberSignUp;

    //balance of each member
    mapping(address => uint256) public memberBalance;
    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external override pure returns (bytes4) {
        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    /*
    This operation selects the asset that will be shared 
    Method can only be executed by owner once the members have finalised the asset
    */
    function selectAsset(address _contractAddress, string memory _tokenId) public onlyOwner {
        sharedAssetAddress = _contractAddress;
        sharedTokenId = _tokenId;
        assetSelectedFlag = true;
    }

    /**
    Before paying, the member must sign up for Joint Ownership
    This will be a free operation
    Only the signed up members will be able to pay & join the Joint Ownership Contract
     */
    function signUpMember(address _from) public whenNotPaused{
        memberSignUp[_from]=true;
    }

    /*
    Add new members to this contract
    Only the signed up members will be able to pay & join the Joint Ownership Contract
    The member needs to pay his share to buy the asset.
    */
    function addMember(address _applicant, uint256 _amount) public whenNotPaused payable {
        // require(assetSelectedFlag == true, "Please confim the asset before proceeding");
        // require(msg.value == _amount, "User did not transfer the required amount");
        // require(memberSignUp[_applicant] == true, "Applicant didn't sign up. Please sign up before this step.");
        Member memory newJoinee = Member(_applicant, block.timestamp);
        memberMap[memberCount] = newJoinee;
        memberCount = memberCount + 1;
    }

    /*
    The asset is purchased in this step
    Perform this operation once all members have been added & there are funds in wallet
    */
    // function purchaseAsset() public onlyOwner whenNotPaused payable {
    //     // require(assetSelectedFlag == true, "Make sure you have selected the asset");
    //     // make sure that the selected address is valid & secure
    //     ERC721 nft_contract = ERC721(sharedAssetAddress);
    //     address owner = nft_contract.ownerOf(sharedTokenId);
    // }

    function distribute() public noReentrant payable {
        for(uint8 i = 0; i < memberCount; i++) {
            address memberAddress = memberMap[i].memberAddress;
            //TODO -> CALCULATE CORRECT VALUE OF DISTRIBUTEDFUND
            uint256 distributedFund = msg.value / memberCount; 
            emit DebugEvent(memberAddress); 
            (bool sent, ) = memberAddress.call{value: distributedFund}("");
            memberBalance[memberAddress] += distributedFund;
            require(sent, "Failed to send Ether");
        }
    }

    receive() external payable {
        //distribute the amount equally
        distribute();
    }

    fallback() external payable {
        //distribute the amount equally
        distribute();
    }
}
