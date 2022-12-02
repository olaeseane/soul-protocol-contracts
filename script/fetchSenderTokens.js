const { ethers } = require('ethers');
require('dotenv').config();

const provider = new ethers.providers.JsonRpcProvider(
  process.env.ALCHEMY_MUMBAY_URL
);

const ABI = [
  'function totalSupply() view returns(uint)',
  'function balanceOf(address) view returns(uint)',
  'function fetchSenderTokens(address _sender) view returns (uint256[])',
];

// const contractAddr = '0x8F4a7f404d09Fea7A9A6c1c9E99a9F341D3DD9A6';
const contractAddr = '0xe57de939325abcd5c1a935d944e142ecf846b84a';
const contract = new ethers.Contract(contractAddr, ABI, provider);

const senderAddr = '0x34C064b128237DB2B917962c45083Ef140564bD8';

const main = async () => {
  const totalSupply = await contract.totalSupply();
  const tokens = await contract.fetchSenderTokens(senderAddr);
  console.log('totalSupply ->', totalSupply);
  console.log('tokens ->', tokens);
};

main();
