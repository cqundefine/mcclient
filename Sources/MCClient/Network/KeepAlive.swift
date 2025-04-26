func processKeepAliveConfiguration(packet: S2CKeepAliveConfiguration, client: TCPClient) throws
{
    let _ = try client.send(packet: C2SKeepAliveConfiguration(keepAliveID: packet.keepAliveID)).assertSuccess()
}

func processKeepAlivePlay(packet: S2CKeepAlivePlay, client: TCPClient) throws
{
    let _ = try client.send(packet: C2SKeepAlivePlay(keepAliveID: packet.keepAliveID)).assertSuccess()
}
