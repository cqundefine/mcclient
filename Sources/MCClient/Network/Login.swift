func processLoginSuccess(packet: S2CLoginSuccess, client: TCPClient)
{
    print("Logged in as \(packet.username) with UUID \(packet.uuid)")
    let _ = client.send(packet: C2SLoginAcknowledged()).assertSuccess()
    client.state = .Configuration
}

func processKnownPacks(packet: S2CKnownPacks, client: TCPClient)
{
    let _ = client.send(packet: C2SKnownPacks()).assertSuccess()
}

func processFinishConfiguration(packet: S2CFinishConfiguration, client: TCPClient)
{
    let _ = client.send(packet: C2SFinishConfigurationAcknowledge()).assertSuccess()
    client.state = .Play
}
