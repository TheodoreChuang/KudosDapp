const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname, 'build');
const contractFileName = 'Kudos.sol';

// Delete the current build folder.
fs.removeSync(buildPath);

const kudosPath = path.resolve(__dirname, 'contracts', contractFileName);
const source = fs.readFileSync(kudosPath, 'utf8');

const input = {
  language: 'Solidity',
  sources: {
    [contractFileName]: {
      content: source,
    },
  },
  settings: {
    outputSelection: {
      '*': {
        '*': ['*'],
      },
    },
  },
};

const output = JSON.parse(solc.compile(JSON.stringify(input)));
const contracts = output.contracts[contractFileName];

// Create the build folder.
fs.ensureDirSync(buildPath);

// Extract and write the JSON representations of the contracts to the build folder.
for (let contract in contracts) {
  if (Object.prototype.hasOwnProperty.call(contracts, contract)) {
    fs.outputJsonSync(path.resolve(buildPath, `${contract}.json`), contracts[contract]);
  }
}
