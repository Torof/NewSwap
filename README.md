# Uniswap V2 revised

An revised version of UniswapV2 to work with modern standards, libraries and good practices, while more secure and gas optimal.

### Design decisions

- Use of Solidity 0.8.20 (no higher to be able to use ***slither*** and ***woke***)
- Use of concepts from ERC4626 for tokenized vaults
- Use of ERC3156 for flashloans ( or what uniswap calls flashswaps)
- Use of ERC20 from openzeppelin instead of Uniswap ERC0 implementation
- No more safeMath library (no need after 0.8.0 but may need to implement unchecked blocks for gas saving)
- Use of external FixedPoint library from **solady**
- Use of Openzeppelin Reentrancy guards (gas saving)
- Use of Openzeppelin ***safeTransfer*** and ***safeTransFrom*** ( see __{SafeERC20}__ from OpenZeppelin)
- Use of custom error instead of require
- Styling decisions due to version differences
         - Rework of interfaces (to avoid inheritance collisions)
         - use of immutable variables (to save gas and prevent variable change)
         - reordering of variable, events, functions to follow styling conventions (better reading and accessibility)
         - use of different sytax (min - max / constructor / payable)
- Adding of a swap function for interacting directly with smart contract:
        - No integrated flashloan into swap but into separate function
        - added all security checks 
- Adding of liquidity functions (depositing and withdrawing):
        - depositLiquidityForShare: deposit liquidity and receive equivalent LP tokens
        - mintShareforLiquidity: mint a certain amount of shares and transfer equivalent amount of liquidity
        - withdrawLiquidityForShare: withdraw liquidity and burn equivalent amount of shares
        - burnShareForLiquidity: burn a certain amount of shares and receive equivalent amount of liquidity
