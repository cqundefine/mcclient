import Foundation
import NIOCore
import NIOPosix

class FramingHandler: ChannelInboundHandler
{
    typealias InboundIn = ByteBuffer
    typealias OutboundOut = ByteBuffer

    private let allocator = ByteBufferAllocator()

    private var buffer: ByteBuffer?
    private var expectedLength: UInt32?

    init()
    {

    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny)
    {
        if let _ = expectedLength {
            var newData = unwrapInboundIn(data)

            var newBuffer = allocator.buffer(capacity: buffer!.capacity + newData.readableBytes)
            newBuffer.writeBuffer(&buffer!)
            newBuffer.writeBuffer(&newData)
            buffer = newBuffer
        } else {
            buffer = unwrapInboundIn(data)
        }

        while buffer!.readableBytes > 0 {
            let index = buffer!.readerIndex
            let length: VarInt = buffer!.read()

            guard buffer!.readableBytes >= length.value else {
                buffer?.moveReaderIndex(to: index)
                expectedLength = length.value
                return
            }

            let packet = buffer!.readSlice(length: Int(length.value))!
            context.fireChannelRead(wrapOutboundOut(packet))
        }

        buffer = nil
        expectedLength = nil
    }
}

class DecodedPacketHandler: ChannelInboundHandler
{
    typealias InboundIn = ByteBuffer

    private let registry = PacketRegistry()

    private let client: TCPClient

    init(client: TCPClient)
    {
        self.client = client

        registry.register(S2CLoginSuccess.self, handler: processLoginSuccess)

        registry.register(S2CFinishConfiguration.self, handler: processFinishConfiguration)
        registry.register(S2CKeepAliveConfiguration.self, handler: processKeepAliveConfiguration)
        registry.register(S2CKnownPacks.self, handler: processKnownPacks)

        registry.register(S2CAddEntity.self, handler: processAddEntity)
        registry.register(S2CBlockUpdate.self, handler: processBlockUpdate)
        registry.register(S2CKeepAlivePlay.self, handler: processKeepAlivePlay)
        registry.register(S2CChunkDataLight.self, handler: processChunkData)
        registry.register(S2CLogin.self, handler: processLogin)
        registry.register(S2CMoveEntityPosition.self, handler: processMoveEntity)
        registry.register(S2CPlayerPosition.self, handler: processPlayerPosition)
    }

    func channelRead(context: ChannelHandlerContext, data: NIOAny)
    {
        var buffer = unwrapInboundIn(data)

        let packetID: VarInt = buffer.read()
        try! registry.handlePacket(packetID: packetID.value, buffer: &buffer, client: client)
    }
}

enum ConnectionState
{
    case Login
    case Configuration
    case Play
}

enum TCPClientError : Error
{
    case NoActiveConnection
    case InvalidState(current: ConnectionState, expected: ConnectionState)
}

class TCPClient
{
    private let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
    private let allocator = ByteBufferAllocator()

    private var channel: Channel?

    private let host: String
    private let port: UInt16

    var state: ConnectionState = ConnectionState.Login

    init(host: String, port: UInt16)
    {
        self.host = host
        self.port = port
    }

    func connect()
    {
        let bootstrap = ClientBootstrap(group: group)
            .channelOption(.socketOption(.so_reuseaddr), value: 1)
            .channelInitializer { channel in
                channel.eventLoop.makeCompletedFuture {
                    try channel.pipeline.syncOperations.addHandlers([FramingHandler(), DecodedPacketHandler(client: self)])
                }
            }

        let connection = bootstrap.connect(host: host, port: Int(port))

        connection.whenSuccess { channel in
            self.channel = channel
            print("Connected")

            try! self.send(packet: C2SHandshakePacket(serverAddress: self.host, serverPort: self.port)).assertSuccess().whenComplete { result in
                let _ = try! self.send(packet: C2SLoginStartPacket(name: "Player", uuid: UUID())).assertSuccess()
            }
        }

        connection.whenFailure { channel in
            fatalError("Failed to connect")
        }
    }

    func send<T: C2SPacket>(packet: T) throws -> EventLoopFuture<Void>
    {
        guard let _ = channel else {
            throw TCPClientError.NoActiveConnection
        }

        guard state == T.packetKey.connectionState else {
            print("Tried to send a packet from \(T.packetKey.connectionState) state while in \(state) state")
            throw TCPClientError.InvalidState(current: state, expected: T.packetKey.connectionState)
        }

        var buffer = allocator.buffer(capacity: 2048)
        packet.write(to: &buffer)
        
        let packetID = VarInt(T.packetKey.packetID)

        var finalBuffer = allocator.buffer(capacity: buffer.readableBytes + 10)
        finalBuffer.write(varInt: VarInt(UInt32(buffer.readableBytes) + packetID.size))
        finalBuffer.write(varInt: packetID)
        finalBuffer.writeBuffer(&buffer)

        return channel!.writeAndFlush(finalBuffer)
    }
}
