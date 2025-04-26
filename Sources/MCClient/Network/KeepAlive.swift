func processKeepAliveConfiguration(packet: S2CKeepAliveConfiguration, client: TCPClient)
{
    let _ = client.send(packet: C2SKeepAliveConfiguration(keepAliveID: packet.keepAliveID)).assertSuccess()
}

func processKeepAlivePlay(packet: S2CKeepAlivePlay, client: TCPClient)
{
    let _ = client.send(packet: C2SKeepAlivePlay(keepAliveID: packet.keepAliveID)).assertSuccess()
}
