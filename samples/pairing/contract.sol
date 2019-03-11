
pragma solidity ^0.5.0;

interface Filesystem {

   function createFileFromBytes(string calldata name, uint nonce, bytes calldata arr) external returns (bytes32);
   function createFileWithContents(string calldata name, uint nonce, bytes32[] calldata arr, uint sz) external returns (bytes32);
   function getSize(bytes32 id) external view returns (uint);
   function getRoot(bytes32 id) external view returns (bytes32);
   function getData(bytes32 id) external view returns (bytes32[] memory);
   function forwardData(bytes32 id, address a) external;   
   
   function makeBundle(uint num) external view returns (bytes32);
   function addToBundle(bytes32 id, bytes32 file_id) external returns (bytes32);
   function finalizeBundle(bytes32 bundleID, bytes32 codeFileID) external;
   function getInitHash(bytes32 bid) external view returns (bytes32);   
   function addIPFSFile(string calldata name, uint size, string calldata hash, bytes32 root, uint nonce) external returns (bytes32);
   function hashName(string calldata name) external returns (bytes32);

   function debugFinalizeBundle(bytes32 bundleID, bytes32 codeFileID) external returns (bytes32, bytes32, bytes32, bytes32, bytes32);
   
}

interface TrueBit {
    function createTaskWithParams(bytes32 initTaskHash, uint8 codeType, bytes32 bundleID,  uint maxDifficulty, uint reward,
                                  uint8 stack, uint8 mem, uint8 globals, uint8 table, uint8 call, uint32 limit) external returns (bytes32);
   function requireFile(bytes32 id, bytes32 hash, /* Storage */ uint st) external;
   function commitRequiredFiles(bytes32 id) external;
   function makeDeposit(uint _deposit) external payable returns (uint);
}

interface TRU {
    function approve(address spender, uint tokens) external returns (bool success);
}

contract SampleContract {

   event NewTask(bytes data);
   event FinishedTask(bytes data, bytes32 result);

   uint nonce;
   TrueBit truebit;
   Filesystem filesystem;
   TRU tru;

   bytes32 codeFileID;
   bytes32 randomFile;

   mapping (bytes => bytes32) string_to_file; 
   mapping (bytes32 => bytes) task_to_string;
   mapping (bytes => bytes32) result;

   constructor(address tb, address tru_, address fs, bytes32 _codeFileID, bytes32 _randomFileId) public {
       truebit = TrueBit(tb);
       tru = TRU(tru_);
       filesystem = Filesystem(fs);
       codeFileID = _codeFileID;
       randomFile = _randomFileId;
   }

   function submitData(bytes memory data) public returns (bytes32) {
      uint num = nonce;
      nonce++;

      emit NewTask(data);

      bytes32 bundleID = filesystem.makeBundle(num);

      bytes32 inputFileID = filesystem.createFileFromBytes("input.data", num, data);
      string_to_file[data] = inputFileID;
      filesystem.addToBundle(bundleID, inputFileID);

      filesystem.addToBundle(bundleID, randomFile);

      bytes32[] memory empty = new bytes32[](0);
      filesystem.addToBundle(bundleID, filesystem.createFileWithContents("output.data", num+1000000000, empty, 0));
      
      filesystem.finalizeBundle(bundleID, codeFileID);
 
      tru.approve(address(truebit), 6 ether);
      truebit.makeDeposit(6 ether);

      bytes32 task = truebit.createTaskWithParams(filesystem.getInitHash(bundleID), 1, bundleID, 1, 1 ether, 20, 25, 8, 20, 10, 0);
      truebit.requireFile(task, filesystem.hashName("output.data"), 0);
      truebit.commitRequiredFiles(task);
      task_to_string[task] = data;
      return filesystem.getInitHash(bundleID);
   }

/*
    function calc_depth(uint x) internal pure returns (uint) {
        if (x <= 1) return 0;
        else return 1 + calc_depth(x / 2);
   }

   function debugData(bytes memory data) public returns (bytes32, uint, bytes32, bytes32[] memory) {
      uint num = nonce;
      nonce++;

      bytes32[] memory input = formatData(data);

      bytes32 inputFileID = filesystem.createFileWithContents("input.data", num, input, data.length);
      return (filesystem.getRoot(inputFileID), calc_depth(input.length*2-1), fileMerkle(input, 0, 3), input);
   }

    function fileMerkle(bytes32[] memory arr, uint idx, uint level) internal returns (bytes32) {
	if (level == 0) return idx < arr.length ? keccak256(abi.encodePacked(arr[idx])) : keccak256(abi.encodePacked(bytes16(0), bytes16(0)));
	else return keccak256(abi.encodePacked(fileMerkle(arr, idx, level-1), fileMerkle(arr, idx+(2**(level-1)), level-1)));
    }

   function debugData2(bytes memory data) public returns (bytes32, bytes32, bytes32, bytes32, bytes32) {
      uint num = nonce;
      nonce++;

      bytes32[] memory input = formatData(data);

      bytes32 bundleID = filesystem.makeBundle(num);

      bytes32 inputFileID = filesystem.createFileWithContents("input.data", num, input, data.length);
      string_to_file[data] = inputFileID;
      filesystem.addToBundle(bundleID, inputFileID);

      filesystem.addToBundle(bundleID, randomFile);

      bytes32[] memory empty = new bytes32[](0);
      filesystem.addToBundle(bundleID, filesystem.createFileWithContents("output.data", num+1000000000, empty, 0));
      
      return filesystem.debugFinalizeBundle(bundleID, codeFileID);
 
   }*/

   bytes32 remember_task;

   // this is the callback name
   function solved(bytes32 id, bytes32[] memory files) public {
      // could check the task id
      require(TrueBit(msg.sender) == truebit);
      remember_task = id;
      bytes32[] memory arr = filesystem.getData(files[0]);
      result[task_to_string[remember_task]] = arr[0];
      emit FinishedTask(task_to_string[remember_task], arr[0]);
   }

   // need some way to get next state, perhaps shoud give all files as args
   function getResult(bytes memory data) public view returns (bytes32) {
      return result[data];
   }

}
