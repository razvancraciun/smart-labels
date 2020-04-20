import 'package:http/http.dart' as http;
import 'package:smart_labels2/model/AppState.dart';
import 'dart:convert';
import 'dart:io';
import 'package:smart_labels2/model/Language.dart';


class ApiClient {
    final AppState _appState = AppState();
    String _apiKey;
    String _user = 'apikey';
    String _url = 'https://api.eu-gb.language-translator.watson.cloud.ibm.com/instances/2c3253c0-4abd-4273-9497-e927cea6aba0/v3/translate?version=2018-05-01';

    static final ApiClient _instance = ApiClient._internal();

    ApiClient._internal();

    factory ApiClient() {
        return _instance;
    }

    void init(String apiKey) {
        _apiKey = apiKey;
    }

    Future<String> translate(String text) async {
        final response = await http.post(
            _url,
            headers: {
                HttpHeaders.authorizationHeader: 'Basic ${base64Encode(utf8.encode('$_user:$_apiKey'))}',
                HttpHeaders.contentTypeHeader: 'application/json'
            },
            body: jsonEncode( {
                'text': [text],
                'model_id': 'en-${_appState.selectedLanguage.code}',
            }),
        );
        var json = jsonDecode(response.body);
        return json['translations'][0]['translation'];
    }
}