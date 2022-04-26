from brownie import accounts, shipments, convert, network, config

certificate = (
        0,                  
        'BBVA',             
        'Banco BBVA',       
        'BA54',             
        'Elm street',       
        1,                
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
        (0,0,0,0,0,0,0,0,0,0,0,0),
        (
            5,
            7,
            10
        ),
        (0,0)                
    )

def main():
    dev = accounts[0] if network.show_active() == 'development' else accounts.add(config['wallets']['from_key'])
    deployed = shipments.deploy({'from':dev}, publish_source=network.show_active() != 'development')
    tx = deployed.addCertificate(certificate, {'from':dev})
    certifiId = tx.events['NewCertificate']['CertificateId']
    print(tx.events['NewCertificate'])
    tx = deployed.logValuesBreak(certifiId, 10, 1650844800)
    print(tx.events)