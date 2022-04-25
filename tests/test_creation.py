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

@pytest.mark.parametrize('certificateId,lumens,timestamp,isBroken', [
    (2, 5, 1650844800, False),
    (2, 7, 1650845800, False),
    (2, 7.5, 1650846800, True),
    (2, 8, 1650847800, True),
    (1, 8, 1650847800, False)
])
def test_theft_log(shipment, certificateId, lumens, timestamp, isBroken):
    if certificateId != 2:
        with reverts():
            tx = shipment.logValuesTheft(certificateId, lumens, timestamp)
            assert tx.status != 1
    else:
        tx = shipment.logValuesTheft(certificateId, lumens, timestamp)
        assert tx.events['LogTheft']['Timestamp'] == timestamp
        assert tx.events['LogTheft']['Lumens'] == lumens
        if isBroken:
            assert tx.events['ThresholdTheft']['CertificateId'] == certificateId