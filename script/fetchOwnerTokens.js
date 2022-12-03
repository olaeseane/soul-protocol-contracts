const { ethers } = require('ethers');
require('dotenv').config();

const provider = new ethers.providers.JsonRpcProvider(
  process.env.ALCHEMY_MUMBAY_URL
);

const ABI = [
  'function totalSupply() view returns(uint)',
  'function balanceOf(address) view returns(uint)',
  'function fetchSenderTokens(address _sender) view returns (uint256[])',
  'function fetchOwnerTokens(address _owner) view returns (uint256[] memory)',
];

// const contractAddr = '0x8F4a7f404d09Fea7A9A6c1c9E99a9F341D3DD9A6';
const contractAddr = '0xd971A8147314118bc930cA88E729F1760e1a938b';
const contract = new ethers.Contract(contractAddr, ABI, provider);

const ownerAddr = '0x5f6939026c7944A8ca09752039AD30F34c2B7baA';

const main = async () => {
  const totalSupply = await contract.totalSupply();
  const tokens = await contract.fetchOwnerTokens(ownerAddr);
  console.log('totalSupply ->', totalSupply);
  console.log('tokens ->', tokens);
};

main();
