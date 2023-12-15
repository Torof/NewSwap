// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import "./interfaces/IUV2Factory.sol";
import {IUV2Pair} from "./interfaces/IUV2Pair.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {FixedPointMathLib} from "solmate/utils/FixedPointMathLib.sol";
import {ERC20} from "solady/tokens/ERC20.sol";

// Heavily inspired by Uniswap v2, retailored to be updated to :
//  - Solidity 0.8.0
//  - flashloan standards {EIP-3156: FlashLoan}
//  - ERC20 standards using safeTransfer {EIP-20: ERC-20 Token Standard}
//  - No more SafeMath
//  - External fixed point math library {FixedPointMathLib}
//  - actualized reentrancy guard {ReentrancyGuard} from OpenZeppelin

contract MockSwapPair is IUV2Pair, ReentrancyGuard, ERC20 {
    using SafeERC20 for IERC20;
    using FixedPointMathLib for uint256;

    uint public constant MINIMUM_LIQUIDITY = 10**3;
    address public immutable factory;
    address public token0;
    address public token1;
    uint112 public reserve0;
    uint112 public reserve1;
    uint32 public blockTimestampLast;
    uint public price0CumulativeLast;
    uint public price1CumulativeLast;
    uint public kLast;

    // write some 

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Mint(address indexed sender, uint amount0, uint amount1);
    
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    event Sync(uint112 reserve0, uint112 reserve1);

    constructor() {
        factory = msg.sender;
    }

    function name() public override pure returns (string memory) {
        return "MockSwapPair";
    }

    function symbol() public override pure returns (string memory) {
        return "MSP";
    }

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external nonReentrant() {
        
    }

    function swapWithApproval(uint amount0Out, uint amount1Out, address to, bytes calldata data) external nonReentrant() {
        // check if msg.sender has enough balance and enough aproved amounts of token0 and token1
        // check xy=k
        // transfer tokens from msg.sender to this contract
        // update reserves
        // calculate liquidity
        // mint liquidity pool token to msg.sender
        // return liquidity
    }

    function skim(address to) external nonReentrant() {}

    function sync() external {}

    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "MS: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

   /**
    create 2 version of a mint function that can be called as is, not through a router: 
       - Provide liquidity to give - get shares,
       - Provide amount of shares to mint - transfer liquidity
    msg.sender should have enough balance and enough approved amounts of token0 and token1
    */

    
    function depositLiquidityForShare(uint amount0Desired, uint amount1Desired, uint amount0Min, uint amount1Min) external nonReentrant() returns (uint liquidity) {
        // check if msg.sender has enough balance and enough aproved amounts of token0 and token1
        // check xy=k
        // transfer tokens from msg.sender to this contract
        // update reserves
        // calculate liquidity
        // mint liquidity pool token to msg.sender
        // return liquidity
    }

    function mintShareforLiquidity(uint amount) external nonReentrant() returns (uint liquidity) {
        // check if msg.sender has enough balance and enough aproved amounts of token0 and token1
        // check xy=k
        // transfer tokens from msg.sender to this contract
        // update reserves
        // calculate liquidity
        // mint liquidity pool token to msg.sender
        // return liquidity
    }
    


    function mint(address to) external nonReentrant() returns (uint liquidity) {

    }

    function withdrawLiquidityForShare() external nonReentrant() returns (uint amount0, uint amount1) {
        // check if msg.sender has enough balance and enough aproved amounts of token0 and token1
        // check xy=k
        // transfer tokens from this contract to msg.sender
        // update reserves
        // calculate liquidity
        // burn lp token
        // return liquidity
    }
    function burnShareForLiquidity() external nonReentrant() returns (uint amount0, uint amount1) {
        // check if msg.sender has enough balance and enough aproved amounts of token0 and token1
        // check xy=k
        // transfer tokens from this contract to msg.sender
        // update reserves
        // calculate liquidity
        // burn lp token
        // return liquidity
    }


    function burn(address to) external nonReentrant() returns (uint amount0, uint amount1) {
        (uint112 _reserve0, uint112 _reserve1,) = getReserves(); // gas savings
        address _token0 = token0;                                // gas savings
        address _token1 = token1;                                // gas savings
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));
        uint liquidity = balanceOf(address(this));

        bool feeOn = _mintFee(_reserve0, _reserve1);
        uint _totalSupply = totalSupply(); // gas savings, must be defined here since totalSupply can update in _mintFee
        amount0 = liquidity * (balance0) / _totalSupply; // using balances ensures pro-rata distribution
        amount1 = liquidity * (balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(amount0 > 0 && amount1 > 0, 'UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED');
        _burn(address(this), liquidity);
        (bool success1) = ERC20(token0).transfer(to, amount0);
        (bool success2) = ERC20(token1).transfer(to, amount1);
        require(success1 && success2, "MS: TRANSFER_FAILED");
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);
        if (feeOn) kLast = uint(reserve0) *(reserve1); // reserve0 and reserve1 are up-to-date
        emit Burn(msg.sender, amount0, amount1, to);
    }

        // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(uint112 _reserve0, uint112 _reserve1) private returns (bool feeOn) {
        address feeTo = IUV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                uint rootK = (uint(_reserve0) * (_reserve1)).sqrt();
                uint rootKLast = (_kLast).sqrt();
                if (rootK > rootKLast) {
                    uint numerator = totalSupply() * (rootK - (rootKLast));
                    uint denominator = rootK * (5) + (rootKLast);
                    uint liquidity = numerator / denominator;
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    function getReserves() public view returns (uint112 reserve0_, uint112 reserve1_, uint32 blockTimestampLast_) {
        reserve0_ = reserve0;
        reserve1_ = reserve1;
        blockTimestampLast_ = blockTimestampLast;
    }

    //NatSpec for _update function
    /**
     * @notice Updates the reserves and, on the first call per block, price accumulators
     * @dev Throws if block timestamp equals `blockTimestampLast`
     * @param balance0 The reserve0 of the pair
     * @param balance1 The reserve1 of the pair
     * @param _reserve0 The reserve0 of the pair
     * @param _reserve1 The reserve1 of the pair
     */

    function _update(uint balance0, uint balance1, uint112 _reserve0, uint112 _reserve1) private {
        require(balance0 <= type(uint112).max && balance1 <= type(uint112).max, "MS: OVERFLOW");
        uint32 blockTimestamp = uint32(block.timestamp % 2**32);
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            price0CumulativeLast += uint(_reserve1).divWadDown(uint(_reserve0)) * timeElapsed;
            price1CumulativeLast += uint(_reserve0).divWadDown(uint( _reserve1)) * timeElapsed;
        }

        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

}