//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.11;

import "./certificateStorage.sol";
import "@Openzeppelin/contracts/access/Ownable.sol";


contract shipments is Ownable {

    event NewCertificate(uint indexed CertificateId, string ShipmentId, insuranceType Type);
    //event ChangeStorage(address indexed OldAddress, address indexed NewAddress);
    event LogShock(uint indexed CertificateId, uint Timestamp, uint16 Shock);
    event ThresholdBreak(uint indexed CertificateId, uint Type);
    event LogTheft(uint indexed CertificateId, uint Timestamp, uint16 Lumens);
    event ThresholdTheft(uint indexed CertificateId);

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
        int16 minTemp;
        int16 maxTemp;
        uint16 minHumidity;
        uint16 maxHumidity;
        int16 threshold1MinTemp;
        int16 threshold1MaxTemp;
        uint16 threshold1MinHumi;
        uint16 threshold1MaxHumi;
        int16 threshold2MinTemp;
        int16 threshold2MaxTemp;
        uint16 threshold2MinHumi;
        uint16 threshold2MaxHumi;
    }
    
    struct breaks {
        uint16 maxShock;
        uint16 threshold1;
        uint16 threshold2;
    }

    struct theft {
        uint32 maxLumens;
        uint32 threshold;
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
    //certificateStorage certificatesVault;
    mapping(uint=>certificate) certificates;
    mapping(uint=>mapping(uint=>uint16)) public shockRegistry;
    mapping(uint=>uint8) public shockAlarmCount;
    mapping(uint=>mapping(uint=>uint16)) public theftRegistry;


    // constructor(address _certificateStorage) {
    //     numCertificates = 0;
    //     certificatesVault = new certificateStorage(_certificateStorage);
    // }

    /* Para cuando se implemente eternal storage
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
    }*/

    function addCertificate(certificate memory _certificate) external returns(uint) {
        numCertificates++;
        require(_certificate.policyNumber == 0, "Error: Only new certificates can be added");
        _certificate.policyNumber = numCertificates;
        certificates[_certificate.policyNumber] = _certificate;
        emit NewCertificate(_certificate.policyNumber, _certificate.shipment.bookingId, _certificate.insurance);
        return _certificate.policyNumber;
    }

    // function logValuesReefer(uint _certificateId, uint _temperature, uint _humidity) external {
        
    // }

    function logValuesBreak(uint _certificateId, uint16 _shock, uint _timestamp) external {
        certificate storage certf = certificates[_certificateId];
        require(certf.policyNumber != 0, "Error: certificate id doesn't exit");
        require(certf.insurance == insuranceType.BREAK, "Error: certificate is not break type");

        shockRegistry[_certificateId][_timestamp] = _shock;
        emit LogShock(_certificateId, _timestamp, _shock);

        if (_shock >= certf.breaks.threshold2) {
            emit ThresholdBreak(_certificateId, 2);
        } else if (_shock >= certf.breaks.threshold1) {
            emit ThresholdBreak(_certificateId, 1);
        } else if (_shock >= certf.breaks.maxShock) {
            shockAlarmCount[_certificateId]++;
            if(shockAlarmCount[_certificateId] >= 10){
                emit ThresholdBreak(_certificateId, 2);
            } else if (shockAlarmCount[_certificateId] >= 3){
                emit ThresholdBreak(_certificateId, 1);
            }
        }
    }

    function logValuesTheft(uint _certificateId, uint16 _lumens, uint _timestamp) external {
        certificate storage certf = certificates[_certificateId];
        require(certf.policyNumber != 0, "Error: certificate id doesn't exit");
        require(certf.insurance == insuranceType.THEFT, "Error: certificate is not theft type");

        theftRegistry[_certificateId][_timestamp] = _lumens;
        emit LogTheft(_certificateId, _timestamp, _lumens);

        if (_lumens >= certf.theft.threshold) 
            emit ThresholdTheft(_certificateId);
    }
}