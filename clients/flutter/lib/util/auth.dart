import "package:pointycastle/export.dart";
import 'dart:math';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:asn1lib/asn1lib.dart';

class Auth {
  RSAPrivateKey privateKey;
  RSAPublicKey publicKey;
  String _pem;
  static Auth _instance;
  Auth();

  static Future<Auth> instance() async {
    if (_instance != null) return _instance;
    _instance = Auth();
    await _instance.initKeys();
    return _instance;
  }

  // from https://github.com/bcgit/pc-dart/blob/master/tutorials/rsa.md
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      SecureRandom secureRandom,
      {int bitLength = 1024}) {
    // Create an RSA key generator and initialize it

    final keyGen = RSAKeyGenerator()
      ..init(ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
          secureRandom));

    // Use the generator

    final pair = keyGen.generateKeyPair();

    // Cast the generated key pair into the RSA key types

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  // from https://github.com/bcgit/pc-dart/blob/master/tutorials/rsa.md
  SecureRandom random() {
    final secureRandom = FortunaRandom();

    final seedSource = Random.secure();
    final seeds = <int>[];
    for (int i = 0; i < 32; i++) {
      seeds.add(seedSource.nextInt(255));
    }
    secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

    return secureRandom;
  }

  Future<void> initKeys() async {
    // if (await loadKeys()) return;

    createKeys();
  }

  Future<bool> loadKeys() async {
    var store = await SharedPreferences.getInstance();
    var data = store.getString('key_pair');
    if (data == null) return false;

    var decoded = jsonDecode(data);
    privateKey = RSAPrivateKey(
      decoded['private']['mod'],
      decoded['private']['exp'],
      decoded['private']['p'],
      decoded['private']['q'],
    );
    publicKey = RSAPublicKey(
      decoded['public']['mod'],
      decoded['public']['exp'],
    );
    return true;
  }

  void saveKeys() async {
    var store = await SharedPreferences.getInstance();
    store.setString(
      'key_pair',
      jsonEncode(
        {
          "public": {
            "mod": privateKey.modulus,
            "exp": privateKey.exponent,
          },
          "private": {
            "mod": publicKey.modulus,
            "exp": publicKey.exponent,
            "p": privateKey.p,
            "q": privateKey.q,
          },
        },
      ),
    );
  }

  void createKeys() {
    final pair = generateRSAkeyPair(random());
    privateKey = pair.privateKey;
    publicKey = pair.publicKey;
  }

  String get encoded {
    if (_pem != null) return _pem;

    var topLevel = new ASN1Sequence();

    topLevel.add(ASN1Integer(publicKey.modulus));
    topLevel.add(ASN1Integer(publicKey.exponent));
    _pem = base64.encode(topLevel.encodedBytes);
    return _pem;
  }

  String rsaSign64(String message) {
    var dataToSign = Uint8List.fromList(message.codeUnits);
    final signer = RSASigner(SHA256Digest(), '0609608648016503040201');

    signer.init(
        true, PrivateKeyParameter<RSAPrivateKey>(privateKey)); // true=sign

    final sig = signer.generateSignature(dataToSign);

    return base64Encode(sig.bytes);
  }
}
