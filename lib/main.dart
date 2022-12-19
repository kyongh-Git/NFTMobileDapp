import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:nft_mobile_project/intro.dart';
import 'package:web3dart/web3dart.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web3_connect/web3_connect.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:carousel_slider/carousel_slider.dart';


List<String> myAddress = [];
int chainID = 0;
String privateKey ='';
const String rpcUrl = 'http://10.0.2.2:7545';
const String contractAddress = "0xDD855AC31d295F6C96C20eF85a09ef507BEbff69";
const String testURI = "https://ipfs.io/ipfs/Qmd9MCGtdVz2miNumBHDbvj8bigSgTwnr4SbyH6DNnpWdt?filename=0-PUG.json";
String currentURI = "https://ipfs.io/ipfs/Qmd9MCGtdVz2miNumBHDbvj8bigSgTwnr4SbyH6DNnpWdt?filename=0-PUG.json";
const String web3storageAPIToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweGFhRWNBRjUyQzhCNmMxOTM1QTdmMzFBOWY3RDJiMGFjYjRkNzVDNjEiLCJpc3MiOiJ3ZWIzLXN0b3JhZ2UiLCJpYXQiOjE2NjY4MzQxNzExMzQsIm5hbWUiOiJORlQgVG9rZW4ifQ.7SguefHFnmh4qQXtt2GsnkYjYRuOtW_vzUbbkoyCx38";
final ImagePicker _picker = ImagePicker();
List<String> NFT_images = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFT Mobile Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home: const MyHomePage(title: 'NFT Mobile App'),
      home: const IntroScreen()
    );
  }
}

// Column _buildButtonColumnForTransfer(Color color, IconData icon, String label, Function function) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         IconButton(icon: Icon(icon), color: color, onPressed: () => function()),
//         Container(
//           margin: const EdgeInsets.only(top: 8),
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w400,
//               color: color,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
Column _buildButtonColumnForWallet(Color color, IconData icon, String label, Function function) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: Icon(icon), color: color, onPressed: () => function()),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class NFTCID {
  final String cid;

  const NFTCID({
    required this.cid
  });

  factory NFTCID.fromJson(Map<String, dynamic> json) {
    return NFTCID(
      cid: json['cid']
    );
  }
}

class NFTURI {
  final String name;
  final String description;
  final String image;
  final String creativeScore;
  final String price;

  const NFTURI({
    required this.name,
    required this.description,
    required this.image,
    required this.creativeScore,
    required this.price
  });

  factory NFTURI.fromJson(Map<String, dynamic> json) {
    return NFTURI(
      name: json['name'],
      description: json['description'],
      image: json['image'],
      creativeScore: json['creativeScore'],
      price: json['price']
    );
  }

  Map<String, dynamic> toJson() => {
      'name': name,
      'description': description,
      'image': image,
      'creativeScore': creativeScore,
      'price': price
  };
}

class _MyHomePageState extends State<MyHomePage> {
  BigInt _myNFTCount = BigInt.from(0);
  int _selectedIndex = 0;
  bool _login = false;
  //String imageURL = "https://img.phonandroid.com/2021/12/marche-nft.jpg"; //
  late Web3Client ethClient;

  // late Directory dir;
  // String fileName = "temp.json";
  // bool fileExists = false;
  // late Map<String, String> fileContent; 

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final creativenessController = TextEditingController();
  final priceController = TextEditingController();
  final privatekeyController = TextEditingController();
  final receiverAddressController = TextEditingController();
  final ndfIDController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    nameController.clear();
    descriptionController.clear();
    creativenessController.clear();
    priceController.clear();
    privatekeyController.clear();
    
    // nameController.dispose();
    // descriptionController.dispose();
    // creativenessController.dispose();
    // priceController.dispose();
    // super.dispose();
  }

  postData() async {
    Uri web3storageURI = Uri.parse("https://api.web3.storage/upload");
    try {
      // var response = await post(Uri.parse("https://ptsv2.com/t/hgr3l-1666835374/post"),
      var image = await _picker.pickImage(source: ImageSource.gallery);
      // final mimeTypeData = lookupMimeType(image.path, headerBytes: );
      if (image != null)
      {
        var imageUploadRequest = http.MultipartRequest('POST', web3storageURI);
        // imageUploadRequest.headers["authorization"] = web3storageAPIToken;
        imageUploadRequest.headers.addAll({"Authorization": "Bearer $web3storageAPIToken", "X-NAME": image.name.replaceAll(RegExp(r'^a-zA-Z0-9'), '')});
        imageUploadRequest.files.add(await http.MultipartFile.fromPath('file', image.path));
        var response = await imageUploadRequest.send();
        if (response.statusCode == 200) print('Uploaded!');
        else print(response.statusCode);
        var responsed = await http.Response.fromStream(response);
        // final responseData = json.decode(responsed.body);
        final responseData = jsonDecode(responsed.body);
        print(responseData);
        // now upload json file URI
        print(NFTCID.fromJson(responseData).cid);

        var uriUploadRequest = http.MultipartRequest('POST', web3storageURI);
        uriUploadRequest.headers.addAll({"Authorization": "Bearer $web3storageAPIToken"});
        var creatURI = NFTURI(
          name: nameController.text,
          description: descriptionController.text,
          image: "https://ipfs.io/ipfs/" + NFTCID.fromJson(responseData).cid,
          creativeScore: creativenessController.text,
          price: priceController.text
        );
        String json = jsonEncode(creatURI);
        print(json);
        print("Creating file!");

        late File file;
        String fileName = "temp.json";

        await getTemporaryDirectory().then((Directory directory) {
          file = new File(directory.path + "/" + fileName);
          file.createSync();
          file.writeAsStringSync(json);
        });
        // final userMap = jsonDecode(json);
        // print(userMap);
        // var user = NFTURI.fromJson(userMap);
        // print(user);

        uriUploadRequest.files.add(await http.MultipartFile.fromPath('file', file.path));
        var jsonUploadResponse = await uriUploadRequest.send();
        if (jsonUploadResponse.statusCode == 200) print('URI Uploaded!');
        else print(jsonUploadResponse.statusCode);
        var uriResponsed = await http.Response.fromStream(jsonUploadResponse);
        final uriResponsedData = jsonDecode(uriResponsed.body);
        print(NFTCID.fromJson(uriResponsedData).cid);

        // generate uri and update the current uri variable 
        currentURI = "https://ipfs.io/ipfs/" + NFTCID.fromJson(uriResponsedData).cid;
        await createNFT();
      }
    }
    catch(e) {
      print(e);
    }

    dispose();
  }

  @override
  void initState() {
    super.initState();
    ethClient = Web3Client(rpcUrl, http.Client());
  }

  Future<DeployedContract> loadContract() async{
    String abi = await rootBundle.loadString("assets/abi.json");
    final contract = DeployedContract(ContractAbi.fromJson(abi, "ArtNFT"), EthereumAddress.fromHex(contractAddress));
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async{
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(contract: contract, function: ethFunction, params: args);
    print(await ethClient.call(contract: contract, function: ethFunction, params: args));
    return result;
  }

  Future<void> balanceOf() async{
    EthPrivateKey credentials;
    if (_login == false) {
      credentials = EthPrivateKey.fromHex(privatekeyController.text);
      var address = await credentials.extractAddress();
      List<dynamic> result = await query("balanceOf", [EthereumAddress.fromHex(address.hex)]);
      _myNFTCount = result[0];
      setState(() {
      
      });
      _login = true;
      privateKey = privatekeyController.text;
      getTokenURIofOwner();
    }
    else if(_login == true) {
      credentials = EthPrivateKey.fromHex(privateKey);
      var address = await credentials.extractAddress();
      List<dynamic> result = await query("balanceOf", [EthereumAddress.fromHex(address.hex)]);
      _myNFTCount = result[0];
      getTokenURIofOwner();
      setState(() {
        
      });
    }
  }

  Future<void> getTokenURI(int tokenId) async{
    // query "balance of" first to see how many token this user have
    // ex) 12 then for loop to rotate to pull out all the URI using tokenURI function 
    List<dynamic> result = await query("tokenURI", [BigInt.from(tokenId)]);
    http.Response response = await http.get(Uri.parse(result[0].toString()));
    Map<String, dynamic> initialURItoJSON = await jsonDecode(response.body); 
    NFT_images.add(initialURItoJSON['image']);
    print(NFT_images);
    setState(() {
      
    });
  }
  // for carousel
  Future<void> getTokenURIofOwner() async{
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    var address = await credentials.extractAddress();
    List<dynamic> result = await query("tokenURIofOwner", [EthereumAddress.fromHex(address.hex)]);
    print(result[0]);
    NFT_images.clear();
    for(var i in result[0])
    {
      await getTokenURI(i.toInt());
    }
    setState(() {
      
    });
  }

  Future<String> submit(String functionName, List<dynamic> args) async{
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.sendTransaction(credentials, Transaction.callContract(
      contract: contract, 
      function: ethFunction, 
      parameters: args
      )
    );
    return result;
  }
  // Way 1: getting address (public key) from private key 
  Future<String> createNFT() async{
    // await postData();
    var response = await submit("createNFT", [currentURI]);
    print("NFT created " + response);
    // EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    // var address = await credentials.extractAddress();
    // print(address.hex);
    await balanceOf();
    
    return response;
  }

  Future<void> transferNFT() async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(privateKey);
    var address = await credentials.extractAddress();
    List<dynamic> result = await query("balanceOf", [EthereumAddress.fromHex(address.hex)]);
    _myNFTCount = result[0];
    print(_myNFTCount);
    if(_myNFTCount <= BigInt.zero){
      print("Own nothing.");
      _dialogBuilder(context);
    }
    else {
      var response = await submit("transferFrom", [
        EthereumAddress.fromHex(address.hex),
        EthereumAddress.fromHex(receiverAddressController.text),
        BigInt.tryParse(ndfIDController.text)]);
      print("NFT successfully transfered " + response);
      setState(() {
        
      });
      receiverAddressController.clear();
      ndfIDController.clear();
      await balanceOf();
    }
  }

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Your Wallet is empty'),
          content: const Text('You can mint a new NFT before sending the NFTs to your friends!'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> connectWallet() async {
    
    // Create a connector
    final connector = WalletConnect(
        bridge: 'https://bridge.walletconnect.org',
        clientMeta: const PeerMeta(
          name: 'WalletConnect',
          description: 'WalletConnect Developer App',
          url: 'https://walletconnect.org',
          icons: [
            'https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
          ],
        ),
    );
    // way 2: getting address (public key) through wallet connecter by entering the password
    // Subscribe to events
    
    connector.on('connect', (session) => {
      // testSession
      chainID = connector.session.chainId,
      print(chainID),
      print(myAddress[0]),
      
    });
    connector.on('session_update', (payload) => print(payload));
    connector.on('disconnect', (session) => print(session));

    if (!connector.connected) {
    final session = await connector.createSession(
        chainId: 5777,
        onDisplayUri: (uri) async => //print(uri)
        {
          await launchUrl(Uri.parse(uri))
        },
      );
      
    }
    setState(() {
        myAddress = connector.session.accounts;
    });

    if (myAddress != null) {
      // final client = Web3Client(rpcUrl, Client());
      // final provider = EthereumWalletConnectProvider(connector);
      // print(await signTransaction(SessionStatus(chainId: chainID, accounts: myAddress), connector));
      // yourContract = YourContract(address: contractAddr, client: client);
    }
    print(connector.session.connected);
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'My account',
      style: optionStyle,
    ),
    Text(
      'Upload your NFT',
      style: optionStyle,
    ),
    Text(
      'Transfer your NFT',
      style: optionStyle,
    ),
    Text(
      'My Wallet',
      style: optionStyle,
    ),
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: const Text(
                    'Number of NFTs you own',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  _myNFTCount.toString(),
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          /*3*/
          // Icon(
          //   Icons.star,
          //   color: Colors.red[500],
          // ),
          // const Text('41'),
        ],
      ),
    );

    Widget buttonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumnForWallet(Colors.blue, Icons.refresh, 'Reload Images', getTokenURIofOwner),
        // _buildButtonColumnForWallet(Colors.green, Icons.north, 'createCollectible', createCollectible),
        _buildButtonColumnForWallet(Colors.red, Icons.south, 'Query balance', balanceOf),
        // _buildButtonColumnForWallet(Colors.red, Icons.south, 'Withdraw', withdrawCoin),
      ],
    );

    List<Widget> imageSliders = NFT_images
    .map((item) => Container(
          child: Container(
            margin: EdgeInsets.all(5.0),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                child: Stack(
                  children: <Widget>[
                    Image.network(item, fit: BoxFit.cover, width: 1000.0),
                    Positioned(
                      bottom: 0.0,
                      left: 0.0,
                      right: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.fromARGB(200, 0, 0, 0),
                              Color.fromARGB(0, 0, 0, 0)
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Text(
                          'No. ${NFT_images.indexOf(item)} image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ))
    .toList();

    Widget carouselSection = Container(
        child: CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            // onPageChanged: changeActiveImage(),
          ),
          items: imageSliders,
        ),
      );

    // Widget imageSection = Container(
      
    //   width: MediaQuery.of(context).size.width,
    //   height: 200,
    //   decoration: BoxDecoration(
    //     image: DecorationImage(
    //       fit: BoxFit.contain,
    //       image: NetworkImage(NFT_images[0]),
    //     ),
    //   ),
    // );
    Widget mintButtonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumnForWallet(Colors.green, Icons.image, 'Select Image', postData),
      ],
    );

    Widget transferButtonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumnForWallet(Colors.orange, Icons.move_up, 'Transfer NFT', transferNFT),
      ],
    );

    Widget loginButtonSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumnForWallet(Colors.red, Icons.login, 'Login', balanceOf),
      ],
    );

    Widget transferSection = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
        minWidth: 70,
        minHeight: 70,
        maxWidth: 300,
        maxHeight: 350,
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the address of the receiver',
              ),
            controller: receiverAddressController,
          ),
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the id of the NFT',
              ),
            controller: ndfIDController,
          ),
          transferButtonSection
        ],
      ),
      ),
    );

    Widget mintFormSection = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
        minWidth: 70,
        minHeight: 70,
        maxWidth: 300,
        maxHeight: 375,
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the name of NFT',
              ),
            controller: nameController,
          ),
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the description of NFT',
              ),
            controller: descriptionController,
          ),
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the creativeness score of NFT',
              ),
            controller: creativenessController,
          ),
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the price of NFT',
              ),
            controller: priceController,
          ),
          mintButtonSection
        ],
      ),
      ),
    );

    Widget walletSection = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildButtonColumnForWallet(Colors.red, Icons.south, 'Connect Wallet', connectWallet),
      ],
    );

    Widget loginSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: const Text(
                    'Login with your Private key',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    Widget pkSection = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
        minWidth: 70,
        minHeight: 70,
        maxWidth: 300,
        // maxHeight: 500,
      ),

      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter your account private key',

              ),
            controller: privatekeyController,
          ),
          loginButtonSection
        ],
      ),
      ),
    );

    List<Widget> _sectionSelect = <Widget>[
      _login ?
      Column(
        children: [
          titleSection,
          carouselSection,
          buttonSection,
          // imageSection
          // Expanded(child: imageSection,),
        ]
      ) : Column(
        children: [
          loginSection,
          pkSection,
        ]
      ),
      mintFormSection,
      transferSection,
      walletSection
    ];

    Widget indexSection = Row(
      children: [
        Expanded(
          child: 
          Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _widgetOptions.elementAt(_selectedIndex),
              _sectionSelect.elementAt(_selectedIndex)
            ],
          )
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      // body: Center(
      //   child: _widgetOptions.elementAt(_selectedIndex), 
      // ),
      body: Column(
        children: [
          indexSection,
          // titleSection,
          // buttonSection,
          // Expanded(child: imageSection,),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'My Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Mint',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange),
            label: 'Transfer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        backgroundColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}
