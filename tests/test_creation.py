from brownie import accounts, shipments, network, reverts
import pytest

certificateBreak = (
        0,                  
        'BBVA',             
        'Banco BBVA',       
        'BA54',             
        'Elm street',       
        1,                
        (
            'shipment1',
            'Madrid',
            'Shangai',
            100,
            'Glass',
            'EUR',
            'vessel',
            'solar panels',
            1650615046,
            1682151046
        ),
        (0,0,0,0,0,0,0,0,0,0,0,0),
        (
            5,
            7,
            10
        ),
        (0,0)                
)

certificateTheft = (
        0,                  
        'BBVA',             
        'Banco BBVA',       
        'BA54',             
        'Elm street',       
        2,                
        (
            'shipment2',
            'Madrid',
            'Shangai',
            100,
            'Glass',
            'EUR',
            'vessel',
            'solar panels',
            1650615046,
            1682151046
        ),
        (0,0,0,0,0,0,0,0,0,0,0,0),
        (0,0,0),
        (
            5,
            7.5
        )                
)

@pytest.fixture(scope="module")
def shipment():
    return shipments.deploy({'from':accounts[0]})

@pytest.fixture(scope="module")
def deployedContracts(shipment):
    shipment.addCertificate(certificateBreak, {'from':accounts[0]})  # certificate 1
    shipment.addCertificate(certificateTheft, {'from': accounts[0]}) # certificate 2

def test_creation(shipment, deployedContracts):
    tx = shipment.addCertificate(certificateBreak, {'from':accounts[0]})
    assert shipment.numCertificates() == tx.events['NewCertificate']['CertificateId']

@pytest.mark.parametrize('certificateId,lumens,timestamp,isTheft', [
    (2, 4, 1650844800, False),
    (2, 5, 1650844800, False),
    (2, 7.5, 1650845800, True),
    (2, 8, 1650846800, True),
    (2, 10, 1650847800, True),
    (2, 11, 1650847800, True),
    (1, 8, 1650847800, False)
])
def test_theft_log(shipment, certificateId, lumens, timestamp, isTheft):
    if certificateId != 2:
        with reverts():
            tx = shipment.logValuesTheft(certificateId, lumens, timestamp)
            assert tx.status != 1
    else:
        tx = shipment.logValuesTheft(certificateId, lumens, timestamp)
        assert tx.events['LogTheft']['Timestamp'] == timestamp
        assert tx.events['LogTheft']['Lumens'] == lumens
        if isTheft:
            assert tx.events['ThresholdTheft']['CertificateId'] == certificateId

@pytest.mark.parametrize('certificateId,shock,timestamp,isBroken', [
    (1, 5, 1650844800, False),
    (1, 6, 1650845800, False),
    (1, 7, 1650846800, True),
    (1, 8, 1650847800, True),
    (2, 8, 1650847800, False)
])
def test_break_log(shipment, certificateId, shock, timestamp, isBroken):
    if certificateId != 1:
        with reverts():
            tx = shipment.logValuesBreak(certificateId, shock, timestamp)
            assert tx.status == 0
    else:
        alarmCount = shipment.shockAlarmCount(certificateId)
        tx = shipment.logValuesBreak(certificateId, shock, timestamp)
        assert tx.events['LogShock']['Timestamp'] == timestamp
        assert tx.events['LogShock']['Shock'] == shock
        if isBroken and shock >= 10:
            assert tx.events['ThresholdBreak']['Type'] == 2
        elif isBroken and shock >=7:
            assert tx.events['ThresholdBreak']['Type'] == 1
        elif isBroken and shock >= 5:
            assert alarmCount+1 == shipment.shockAlarmCount(certificateId)

