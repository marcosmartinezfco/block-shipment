//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

import "./certificateStorage.sol";
import "@Openzeppelin/contracts/access/Ownable.sol";


contract shipments is Ownable {

    event NewCertificate(uint indexed CertificateId, string indexed ShipmentId);
    event ChangeStorage(address indexed OldAddress, address indexed NewAddress);

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

    uint public numCertificates;
    certificateStorage certificatesVault;

    constructor(address _certificateStorage) {
        numCertificates = 0;
        certificatesVault = new certificateStorage(_certificateStorage);
    }

    function setStorageAddress(address _newAddress) public onlyOwner {
        address _oldAddress = address(certificatesVault);
        require(_newAddress != _oldAddress);
        certificatesVault = new certificateStorage(_newAddress);
        emit ChangeStorage(_oldAddress, _newAddress);
    }

    function addCertificate(certificate memory _certificate) public returns (uint) {
        numCertificates++;
        _certificate.policyNumber = numCertificates;
        certificatesVault.addCertificate( _certificate.policyNumber, _certificate);
        emit NewCertificate(_certificate.policyNumber, _certificate.shipment.bookingId);
        return _certificate.policyNumber;
    }
}