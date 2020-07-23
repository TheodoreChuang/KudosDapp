// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.7.0;

contract Kudos {
    struct UserStruct {
        uint256 index;
        string username;
        uint256 kudos;
        // last <tipLimit> tipping times - ASC order
        uint256[5] latestTips;
    }

    // Name of the space
    // string public name;
    // Name of Kudos (ex. tacos) ¿can handle emojis?
    // string public unitOfAccount;
    // Maximum number of tacos an user can tip within a cyclePeriod
    uint256 public tipLimit = 3;
    // Period of time before the tipLimit resets (in days)
    uint256 public cyclePeriod = 1;

    // testing - ASC order
    uint256[] public contractLatest;

    address public admin;

    address[] private userIndex;
    mapping(address => UserStruct) private userStructs;

    event Tip(
        // address indexed _from,
        // address _to, // indexed ?
        // uint8 _amount,
        uint256 indexed _timestamp // indexed ?
    );

    event LogNewUser(
        address indexed userAddress,
        uint256 index,
        string username
    );

    constructor() public {
        admin = msg.sender;
        // TODO add other parameters

        for (uint8 i = 0; i < tipLimit; i++) {
            contractLatest.push(block.timestamp - cyclePeriod * 1 weeks);
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
    /// @param
    function tipUser(uint8 _amount) public {
        // function tipUser(address _to, uint8 _amount) public {
        // require(_to != msg.sender, "Cannot tip yourself");

        require(_amount <= tipLimit, "Cannot tip more than the limit");

        for (uint8 a = 0; a < _amount; a++) {
            require(_passTipLimit(contractLatest[a]), "Cannot tip yet");
        }

        // send tip

        uint256[] memory updatedTimestamp = new uint256[](tipLimit);

        for (uint8 l = 0; l < tipLimit; l++) {
            if (l < (tipLimit - _amount)) {
                updatedTimestamp[l] = contractLatest[_amount + l];
            } else {
                updatedTimestamp[l] = block.timestamp;
            }
        }

        contractLatest = updatedTimestamp;
        // emit Tip(msg.sender, _to, _amount, block.timestamp);
    }

    function contractLenght() public view returns (uint256) {
        return contractLatest.length;
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

    function getUserAtIndex(uint256 index)
        public
        view
        returns (address userAddress)
    {
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
        return (
            userStructs[_address].username,
            userStructs[_address].kudos,
            userStructs[_address].latestTips
        );
    }

    function insertUser(address _address, string memory _username)
        public
        onlyAdmin
        returns (uint256 index)
    {
        require(!isUser(_address), "User already exists");

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
        require(msg.sender == admin, "Only the admin can initial this action");
        _;
    }

    // function changeAdmin(address) public {}

    // function terminate() public onlyAdmin {
    //     selfdestruct(msg.sender);
    // }
}
