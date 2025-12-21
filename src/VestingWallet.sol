// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract VestingWallet is Ownable, ReentrancyGuard {
    struct VestingSchedule {
        address beneficiary;
        uint256 cliff;
        uint256 duration;
        uint256 totalAmount;
        uint256 releasedAmount;
    }

    IERC20 public immutable token;
    mapping(address => VestingSchedule) public vestingSchedules;

    // pour que le forge test fonctionne...
    event releaseTokens(address indexed beneficiary, uint256 amount);

    constructor(address tokenAddress) Ownable(msg.sender) {
        // ???
        require(tokenAddress != address(0), "ERROR: Token invalide !!!");
        token = IERC20(tokenAddress);
    }

    function createVestingSchedule(address _beneficiary, uint256 _totalAmount, uint256 _cliff, uint256 _duration)
        public
        onlyOwner
    {
        // Logique pour créer et stocker un nouveau calendrier de vesting.
        // N'oubliez pas de vérifier que les fonds sont bien transférés au contrat !
        require(_totalAmount > 0, "ERROR: Montant doit etre superieur a 0 !!!");
        require(_duration > 0, "ERROR: Duration doit etre superieure a 0 !!!");
        require(vestingSchedules[_beneficiary].totalAmount == 0, "ERROR: Vesting existe deja pour ce beneficiaire !!!");

        // transfert des tokens au contract pour que l'utilisateur peut le récuperer
        require(token.transferFrom(msg.sender, address(this), _totalAmount), "ERROR: transfert a echoue !!!");

        // creation d'un vestingSchedules pour le beneficiary à partir de la struct
        vestingSchedules[_beneficiary] = VestingSchedule({
            beneficiary: _beneficiary,
            cliff: _cliff,
            duration: _duration,
            totalAmount: _totalAmount,
            // car on viens de créer le contrat
            releasedAmount: 0
        });
    }

    function claimVestedTokens() public nonReentrant {
        // Logique pour permettre à un bénéficiaire de réclamer les jetons déjà libérés.
        // Calculez le montant disponible et transférez-le.
        VestingSchedule storage schedule = vestingSchedules[msg.sender];

        uint256 vestedAmount = getVestedAmount(msg.sender);
        uint256 claimableAmount = vestedAmount - schedule.releasedAmount;

        require(claimableAmount > 0, "ERROR: Aucun jeton disponible a reclamer !!!");

        // prepation de l'envoie du motant
        schedule.releasedAmount += claimableAmount;

        // transfert des tokens vers le beneficière en forme de condition
        require(token.transfer(msg.sender, claimableAmount), "ERROR: transfert a echoue !!!");

        // envoyer à la personne qui à appeller le contract la somme définie
        emit releaseTokens(msg.sender, claimableAmount);
        //token.transfer(msg.sender, claimableAmount);
    }

    function getVestedAmount(address _beneficiary) public view returns (uint256) {
        // Fonction pour calculer le montant total de jetons libérés à un instant T.
        // Attention : la libération est linéaire après le cliff.
        VestingSchedule storage schedule = vestingSchedules[_beneficiary];

        if (block.timestamp < schedule.cliff) {
            return 0;
        }

        if (block.timestamp >= schedule.cliff + schedule.duration) {
            return schedule.totalAmount;
        }

        uint256 timePassedSinceCliff = block.timestamp - schedule.cliff;
        uint256 vestedAmount = (schedule.totalAmount * timePassedSinceCliff) / schedule.duration;
        return vestedAmount;
    }
}
