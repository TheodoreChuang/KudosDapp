// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

contract KudosFactory {
  Kudos[] public deployedKudoss;

  function createKudos(
    string memory _name,
    string memory _unitOfAccount,
    uint256 _tipLimit,
    uint256 _cyclePeriod
  ) public {
    Kudos newKudos = new Kudos(msg.sender, _name, _unitOfAccount, _tipLimit, _cyclePeriod);
    deployedKudoss.push(newKudos);
  }

  function getDeployedKudos() public view returns (Kudos[] memory) {
    return deployedKudoss;
  }
}

contract Kudos {
  struct UserStruct {
    uint256 index;
    string username;
    uint256 kudos;
    // last <tipLimit> tipping times - ASC order
    uint256[5] latestTips;
  }

  // Name of the space
  string public name;
  // Name of Kudos (ex. tacos) ¿can handle emojis?
  string public unitOfAccount;
  // Maximum number of tacos an user can tip within a cyclePeriod
  uint256 public tipLimit;
  // Period of time before the tipLimit resets (in days)
  uint256 public cyclePeriod;
  address public admin;

  address[] private userIndex;
  mapping(address => UserStruct) private userStructs;

  event LogTip(address indexed _from, address _to, uint8 _amount, uint256 _timestamp);

  event LogNewUser(address indexed userAddress, uint256 index, string username);

  constructor(
    address _admin,
    string memory _name,
    string memory _unitOfAccount,
    uint256 _tipLimit,
    uint256 _cyclePeriod
  ) public {
    admin = _admin;

    // require(_name.length > 0);

    name = _name;
    unitOfAccount = _unitOfAccount;
    tipLimit = _tipLimit;
    cyclePeriod = _cyclePeriod;

    // if (_name.length == 0) {
    //     name = 'taco';
    // }
    if (_tipLimit == 0) {
      tipLimit = 5;
    }
    if (_cyclePeriod == 0) {
      cyclePeriod = 1;
    }
  }

  /**
   * Utility Functions
   */
  /// @notice Determine if an user can tip yet based on previous tips and the cycle period
  /// @param _lastTimestamp Timestamp of a previous tip
  function _passTipLimit(uint256 _lastTimestamp) private view returns (bool) {
    if (block.timestamp >= _lastTimestamp + cyclePeriod * 1 days) {
      return true;
    }
    return false;
  }

  /// @notice list of users. maybe also there stats?
  // function viewUsers() public {}

  /// @notice
  /// @param _amount Amount of kudos
  function tipUser(address _to, uint8 _amount) public {
    require(isUser(_to), 'Recipient user does not exist');
    require(_to != msg.sender, 'Cannot tip yourself');

    require(_amount <= tipLimit, 'Cannot tip more than the limit');
    require(_amount > 0, 'Cannot tip less than zero');

    for (uint8 a = 0; a < _amount; a++) {
      require(_passTipLimit(userStructs[msg.sender].latestTips[a]), 'Cannot tip yet');
    }

    // send tip
    userStructs[_to].kudos = userStructs[_to].kudos + _amount;

    // Update senders latest tips timestamps
    for (uint8 l = 0; l < tipLimit; l++) {
      if (l < (tipLimit - _amount)) {
        userStructs[msg.sender].latestTips[l] = userStructs[msg.sender].latestTips[_amount + l];
      } else {
        userStructs[msg.sender].latestTips[l] = block.timestamp;
      }
    }

    emit LogTip(msg.sender, _to, _amount, block.timestamp);
  }

  function getSpaceSummary()
    public
    view
    returns (
      string memory,
      string memory,
      uint256,
      uint256
    )
  {
    return (name, unitOfAccount, tipLimit, cyclePeriod);
  }

  /**
   * Users
   */
  function isUser(address _address) public view returns (bool isIndeed) {
    if (userIndex.length == 0) return false;
    return (userIndex[userStructs[_address].index] == _address);
  }

  function getUserCount() public view returns (uint256 count) {
    return userIndex.length;
  }

  function getUserAtIndex(uint256 index) public view returns (address userAddress) {
    return userIndex[index];
  }

  function getUser(address _address)
    public
    view
    returns (
      string memory username,
      uint256 kudos,
      uint256[5] memory latestTips
    )
  {
    return (userStructs[_address].username, userStructs[_address].kudos, userStructs[_address].latestTips);
  }

  function insertUser(address _address, string memory _username) public onlyAdmin returns (uint256 index) {
    require(!isUser(_address), 'User already exists');

    userIndex.push(_address);

    userStructs[_address].index = userIndex.length - 1;
    userStructs[_address].username = _username;
    userStructs[_address].kudos = 0;

    // initialize latestTips array with (block.timestamp - cyclePeriod) * limit
    uint256 beforeCyclePeriod = (block.timestamp - cyclePeriod * 1 weeks);
    for (uint8 i = 0; i < tipLimit; i++) {
      userStructs[_address].latestTips[i] = beforeCyclePeriod;
    }

    emit LogNewUser(_address, userStructs[_address].index, _username);

    return userStructs[_address].index;
  }

  /**
   * Admin
   */
  modifier onlyAdmin() {
    require(msg.sender == admin, 'Only the admin can initial this action');
    _;
  }

  // function changeAdmin(address) public {}

  // function terminate() public onlyAdmin {
  //     selfdestruct(msg.sender);
  // }
}
