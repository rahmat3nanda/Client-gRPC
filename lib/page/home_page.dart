import 'package:client_grpc/model/helloworld.pbgrpc.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _name;
  ClientChannel c = ClientChannel(
    "192.168.1.9",
    port: 50051,
    options: ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      codecRegistry:
          CodecRegistry(codecs: const [GzipCodec(), IdentityCodec()]),
    ),
  );

  Stream<HelloReply> _stream() {
    return GreeterClient(c)
        .sayHello(
          HelloRequest()..name = _name ?? "",
          options: CallOptions(compression: GzipCodec()),
        )
        .asStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GRPC")),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        TextField(
          onChanged: (s) {
            setState(() {
              _name = s;
            });
          },
        ),
        Expanded(
          child: Center(
            child: StreamBuilder(
              stream: _stream().asBroadcastStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text("${snapshot.data}");
                } else if (snapshot.hasError) {
                  return Text("error : ${snapshot.error}");
                }
                return Text("Loading");
              },
            ),
          ),
        ),
      ],
    );
  }
}
