//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

import "@Openzeppelin/contracts/access/Ownable.sol";

contract certificateStorage is Ownable {

    enum insuranceType { REEFER, BREAK, THEFT }

    struct shipment {
        string bookingId;
        string origin;
        string destiny;
        uint amount;
        string businessCard;
        string currency;
        string nameVessel;
        string typeGoods;
        uint dateShipment;
        uint dateDelivery;
    }

    struct reefer {
        uint minTemp;
        uint maxTemp;
        uint minHumidity;
        uint maxHumidity;
        uint threshold1MinTemp;
        uint threshold1MaxTemp;
        uint threshold1MinHumi;
        uint threshold1MaxHumi;
        uint threshold2MinTemp;
        uint threshold2MaxTemp;
        uint threshold2MinHumi;
        uint threshold2MaxHumi;
    }
    
    struct breaks {
        uint maxShock;
        uint threshold1;
        uint threshold2;
    }

    struct theft {
        uint maxLumens;
        uint threshold1;
        uint threshold2;
    }

    struct certificate {
        uint policyNumber;
        string policyHolder;
        string holderName;
        string CIF;
        string direction;
        insuranceType insurance;
        shipment shipment;
        reefer reefer;
        breaks breaks;
        theft theft;
    }

    mapping(uint=>certificate) certificateVault;

    function addCertificate(uint _policyNumber, certificate memory _certificate) external {
        require(certificateVault[_policyNumber].policyNumber == 0, "Error: certificate already exits");
        certificateVault[_policyNumber] = _certificate;
    }
}