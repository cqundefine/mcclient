func processLoginSuccess(packet: S2CLoginSuccess, client: TCPClient) throws
{
    print("Logged in as \(packet.username) with UUID \(packet.uuid)")
    let _ = try client.send(packet: C2SLoginAcknowledged()).assertSuccess()
    client.state = .Configuration
}

func processKnownPacks(packet: S2CKnownPacks, client: TCPClient) throws
{
    let _ = try client.send(packet: C2SKnownPacks()).assertSuccess()
}

func processFinishConfiguration(packet: S2CFinishConfiguration, client: TCPClient) throws
{
    let _ = try client.send(packet: C2SFinishConfigurationAcknowledge()).assertSuccess()
    client.state = .Play
}
