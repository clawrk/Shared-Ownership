// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.1;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/security/Pausable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

contract SharedOwnership is Ownable, Pausable, IERC721Receiver {

    enum DECISION_POLICY { MAJORITY_APPROVAL, COMBINED_APPROVAL }

    struct Member {
        address memberAddress;  // address of the member
        uint256 joinedAt;       // timestamp
    }

    uint8 public memberCount;
    mapping(uint32 => Member) public memberMap;
    mapping(address => bool) public memberSignUp;

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
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
    function addMember(address _applicant) public whenNotPaused payable {
        // require(memberSignUp[_applicant] == true, "Applicant didn't sign up. Please sign up before this step.");
        Member memory newJoinee = Member(_applicant, block.timestamp);
        memberMap[memberCount] = newJoinee;
        memberCount = memberCount + 1;
    }

    function purchaseAsset() public onlyOwner whenNotPaused payable {

    }

    receive() external payable {
        //distribute the amount equally
    }
}