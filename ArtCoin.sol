// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20FlashMint.sol";


/// @custom:security-contact yjckimdyd@gmail.com
contract ArtCoin is ERC20, ERC20Burnable, ERC20Snapshot, Ownable, Pausable, ERC20Permit, ERC20Votes, ERC20FlashMint {
    uint256 public artCoinPrice;
    event LogDebug(string message, uint256 value);
    event Purchased(address indexed buyer, uint256 amount);
    event Sold(address indexed seller, uint256 amount);

    constructor(uint256 _artCoinPrice) ERC20("ArtCoin", "ART") ERC20Permit("ArtCoin") {
        artCoinPrice = _artCoinPrice;
        _mint(msg.sender, 10000000000 * 10 ** decimals());

        // Mint some tokens for the contract itself to sell
        uint256 contractInitialBalance = 100000000 * 10 ** decimals();
        _mint(address(this), contractInitialBalance);
    }

    function snapshot() public onlyOwner {
        _snapshot();
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount)
        internal
        whenNotPaused
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    // The following functions are overrides required by Solidity.

    function _afterTokenTransfer(address from, address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(address to, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._mint(to, amount);
    }

    function _burn(address account, uint256 amount)
        internal
        override(ERC20, ERC20Votes)
    {
        super._burn(account, amount);
    }

    function buyArtCoin() public payable {
        emit LogDebug("The amount is", msg.value);
        require(msg.value > 0, "Must send ether to purchase ArtCoin");
        uint256 artCoinAmount = msg.value * artCoinPrice;
        require(balanceOf(address(this)) >= artCoinAmount, "Not enough ART tokens in the contract");
        
        // Transfer the ART tokens to the buyer
        _transfer(address(this), msg.sender, artCoinAmount);

        // Transfer the ether to the owner of the contract
        // payable(owner()).transfer(msg.value);
        emit Purchased(msg.sender, artCoinAmount);
    }

    function sellArtCoin(uint256 _artCoinAmount) public {
        require(balanceOf(msg.sender) >= _artCoinAmount, "Not enough ART tokens to sell");

        uint256 etherAmount = _artCoinAmount / artCoinPrice;
        require(address(this).balance >= etherAmount, "Not enough Ether in the contract");

        // Transfer the ART tokens from the seller to the contract
        _transfer(msg.sender, address(this), _artCoinAmount);

        // Transfer Ether to the seller
        payable(msg.sender).transfer(etherAmount);

        emit Sold(msg.sender, _artCoinAmount);
    }

    function setArtCoinPrice(uint256 _newPrice) public onlyOwner {
        artCoinPrice = _newPrice;
    }

    function withdrawEther() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function addArtCoinLiquidity(uint256 _artCoinAmount) public onlyOwner {
        _transfer(msg.sender, address(this), _artCoinAmount);
    }
}
