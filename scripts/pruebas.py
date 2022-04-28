from brownie import accounts, shipments, convert, network, config

certificate = (
        0,                  
        'BBVA',             
        'Banco BBVA',       
        'BA54',             
        'Elm street',       
        0,                
        (
            'shipment056',
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
        (-5,10,5,15,-7,15,3,20,-10,20,2,25),
        (0,0,0),
        (0,0)                
    )

def main():
    dev = accounts[0] if network.show_active() == 'development' else accounts.add(config['wallets']['from_key'])
    deployed = shipments.deploy({'from':dev}, publish_source=network.show_active() != 'development')
    tx = deployed.addCertificate(certificate, {'from':dev})
    certifiId = tx.events['NewCertificate']['CertificateId']
    print(tx.events['NewCertificate'])
    deployed.logValuesReefer(certifiId, 12, 5, 1650844800)
    deployed.logValuesReefer(certifiId, 12, 5, 1650844800)
    print(tx.events)
    tx = deployed.logValuesReefer(certifiId, 12, 5, 1650844800)
    print(tx.events)
    