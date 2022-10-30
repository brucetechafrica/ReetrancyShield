pragma solidity >=0.7.0 <0.9.0
contract Attackee is ReentrancyShield {
     
     mapping(address => uint) public attackeeBalances; 
     
     function depositIntoAttackee() external payable {
         attackeeBalances[msg.sender] += msg.value;
     }
     
     function withdrawFromAttackee() external nonReentrant {
         uint senderBalance = attackeeBalances[msg.sender];
         require(senderBalance > 0);
         
         attackeeBalances[msg.sender] = 0;
         (bool success, ) = address(msg.sender).call{ value: senderBalance }("");
         require(success, "withdrawFromAttackee failed to send");
     }
     
     function getBalanceFromAttackee() external view returns (uint) {
         return address(this).balance;
     }
 }
 
 contract Attacker {
     Attackee public contractToAttack;
     
     constructor(address _contractToAttackAddress) {
         contractToAttack = Attackee(_contractToAttackAddress);
     }
     
     //this is called when Attackee sends Ether to this contract (Attacker)
     receive() external payable {
         //comment this out to allow the withdrawal
         //if(address(contractToAttack).balance >= 1 ether) {
         //    contractToAttack.withdrawFromAttackee();
         //}
     }
     
     function depositIntoAttackee() external payable {
         require(msg.value >= 1 ether);
         contractToAttack.depositIntoAttackee{value: msg.value}();
     }
     
     function performAttack() external {
         contractToAttack.withdrawFromAttackee();
     }
     
     function getBalanceFromAttacker() external view returns (uint) {
         return address(this).balance;
     }
 }
 