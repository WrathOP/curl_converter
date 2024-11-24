import 'dart:io';

import 'package:curl_converter/src/models/curl.dart';
import 'package:curl_converter/src/models/form_data_model.dart';
import 'package:test/test.dart';

const defaultTimeout = Timeout(Duration(seconds: 3));
final exampleDotComUri = Uri.parse('https://www.example.com/');

void main() {
  test('parse an easy cURL', () async {
    expect(
      Curl.parse('curl -X GET https://www.example.com/'),
      Curl(
        method: 'GET',
        uri: exampleDotComUri,
      ),
    );
  }, timeout: defaultTimeout);

  test('compose an easy cURL', () async {
    expect(
      Curl.parse('curl -X GET https://www.example.com/'),
      Curl(
        method: 'GET',
        uri: exampleDotComUri,
      ),
    );
  }, timeout: defaultTimeout);

  test('parse POST request with form-data', () {
    const curl = r'''curl -X POST https://example.com/upload \\
      -F "file=@/path/to/image.jpg" \\
      -F "username=john"
      ''';

    expect(
      Curl.parse(curl),
      Curl(
        method: 'POST',
        uri: Uri.parse('https://example.com/upload'),
        headers: {
          "Content-Type": "multipart/form-data",
        },
        form: true,
        formData: [
          FormDataModel(name: "file", value: "/path/to/image.jpg", type: FormDataType.file),
          FormDataModel(name: "username", value: "john", type: FormDataType.text)
        ],
      ),
    );
  });

  test('parse POST request with form-data including a file and arrays', () {
    const curl = r'''curl -X POST https://example.com/upload \\
        -F "file=@/path/to/image.jpg" \\
        -F "username=john" \\
        -F "tags=tag1" \\
        -F "tags=tag2"
      ''';

    expect(
      Curl.parse(curl),
      Curl(
        method: 'POST',
        uri: Uri.parse('https://example.com/upload'),
        headers: {
          "Content-Type": "multipart/form-data",
        },
        form: true,
        formData: [
          FormDataModel(name: "file", value: "/path/to/image.jpg", type: FormDataType.file),
          FormDataModel(name: "username", value: "john", type: FormDataType.text),
          FormDataModel(name: "tags", value: "tag1", type: FormDataType.text),
          FormDataModel(name: "tags", value: "tag2", type: FormDataType.text),
        ],
      ),
    );
  });

  test('should throw exception when form data is not in key=value format', () {
    const curl = r'''curl -X POST https://example.com/upload \\
  -F "invalid_format" \\
  -F "username=john"
  ''';
    expect(
      () => Curl.parse(curl),
      throwsException,
    );
  });

  test('should not throw when form data entries are valid key-value pairs', () {
    expect(
      () => Curl(
        uri: Uri.parse('https://example.com/upload'),
        method: 'POST',
        form: true,
        formData: [
          FormDataModel(name: "username", value: "john", type: FormDataType.text),
          FormDataModel(name: "password", value: "password", type: FormDataType.text),
        ],
      ),
      returnsNormally,
    );
  });

  test('should not throw when form data is null', () {
    expect(
      () => Curl(
        uri: Uri.parse('https://example.com/upload'),
        method: 'POST',
        form: false,
        formData: null,
      ),
      returnsNormally,
    );
  });

  test('Check quotes support for URL string', () async {
    expect(
      Curl.parse('curl -X GET "https://www.example.com/"'),
      Curl(
        method: 'GET',
        uri: exampleDotComUri,
      ),
    );
  }, timeout: defaultTimeout);

  test('parses two headers', () async {
    expect(
      Curl.parse(
        'curl -X GET https://www.example.com/ -H "${HttpHeaders.contentTypeHeader}: ${ContentType.text}" -H "${HttpHeaders.authorizationHeader}: Bearer %token%"',
      ),
      Curl(
        method: 'GET',
        uri: exampleDotComUri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.text.toString(),
          HttpHeaders.authorizationHeader: 'Bearer %token%',
        },
      ),
    );
  }, timeout: defaultTimeout);

  test('parses a lot of headers', () async {
    expect(
      Curl.parse(
        r'curl -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36" -H "Upgrade-Insecure-Requests: 1" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7" -H "Accept-Encoding: gzip, deflate, br" -H "Accept-Language: en,en-GB;q=0.9,en-US;q=0.8,ru;q=0.7" -H "Cache-Control: max-age=0" -H "Dnt: 1" -H "Sec-Ch-Ua: \"Google Chrome\";v=\"117\", \"Not;A=Brand\";v=\"8\", \"Chromium\";v=\"117\"" -H "Sec-Ch-Ua-Mobile: ?0" -H "Sec-Ch-Ua-Platform: \"macOS\"" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" https://animego.org/anime/eta-farforovaya-kukla-vlyubilas-1937',
      ),
      Curl(
        method: 'GET',
        uri: Uri.parse('https://animego.org/anime/eta-farforovaya-kukla-vlyubilas-1937'),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36',
          'Upgrade-Insecure-Requests': '1',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
          'Accept-Encoding': 'gzip, deflate, br',
          'Accept-Language': 'en,en-GB;q=0.9,en-US;q=0.8,ru;q=0.7',
          'Cache-Control': 'max-age=0',
          'Dnt': '1',
          'Sec-Ch-Ua': '"Google Chrome";v="117", "Not;A=Brand";v="8", "Chromium";v="117"',
          'Sec-Ch-Ua-Mobile': '?0',
          'Sec-Ch-Ua-Platform': '"macOS"',
          'Sec-Fetch-Dest': 'document',
          'Sec-Fetch-Mode': 'navigate',
          'Sec-Fetch-Site': 'same-origin',
          'Sec-Fetch-User': '?1'
        },
      ),
    );
  }, timeout: defaultTimeout);

  test('throw exception when parses wrong input', () async {
    expect(
      () => Curl.parse('1f'),
      throwsException,
    );
  }, timeout: defaultTimeout);

  test('tryParse return null when parses wrong input', () async {
    expect(
      Curl.tryParse('1f'),
      null,
    );
  }, timeout: defaultTimeout);

  test('tryParse success', () async {
    expect(
      Curl.tryParse(
        'curl -X GET https://www.example.com/ -H "${HttpHeaders.contentTypeHeader}: ${ContentType.text}" -H "${HttpHeaders.authorizationHeader}: Bearer %token%"',
      ),
      Curl(
        method: 'GET',
        uri: exampleDotComUri,
        headers: {
          HttpHeaders.contentTypeHeader: ContentType.text.toString(),
          HttpHeaders.authorizationHeader: 'Bearer %token%',
        },
      ),
    );
  }, timeout: defaultTimeout);

  test('GET 1', () async {
    expect(
      Curl.parse(
        r"""curl --url 'https://api.apidash.dev'""",
      ),
      Curl(
        method: 'GET',
        uri: Uri.parse('https://api.apidash.dev'),
      ),
    );
  }, timeout: defaultTimeout);

  test('GET 2', () async {
    expect(
      Curl.parse(
        r"""curl --url 'https://api.apidash.dev/country/data?code=US'""",
      ),
      Curl(
        method: 'GET',
        uri: Uri.parse('https://api.apidash.dev/country/data?code=US'),
      ),
    );
  }, timeout: defaultTimeout);

  test('GET 3', () async {
    expect(
      Curl.parse(
        r"""curl --url 'https://api.apidash.dev/country/data?code=IND'""",
      ),
      Curl(
        method: 'GET',
        uri: Uri.parse('https://api.apidash.dev/country/data?code=IND'),
      ),
    );
  }, timeout: defaultTimeout);

  test('GET 4', () async {
    expect(
      Curl.parse(
        r"""curl --url 'https://api.apidash.dev/humanize/social?num=8700000&digits=3&system=SS&add_space=true&trailing_zeros=true'""",
      ),
      Curl(
        method: 'GET',
        uri: Uri.parse(
            'https://api.apidash.dev/humanize/social?num=8700000&digits=3&system=SS&add_space=true&trailing_zeros=true'),
      ),
    );
  }, timeout: defaultTimeout);

  test('GET 5', () async {
    expect(
      Curl.parse(
        r"""curl --url 'https://api.github.com/repos/foss42/apidash' \
  --header 'User-Agent: Test Agent'""",
      ),
      Curl(
        method: 'GET',
        uri: Uri.parse('https://api.github.com/repos/foss42/apidash'),
        headers: {"User-Agent": "Test Agent"},
      ),
    );
  }, timeout: defaultTimeout);

  test('GET 6', () async {
    expect(
      Curl.parse(
        r"""curl --url 'https://api.github.com/repos/foss42/apidash?raw=true' \
  --header 'User-Agent: Test Agent'""",
      ),
      Curl(
        method: 'GET',
        uri: Uri.parse('https://api.github.com/repos/foss42/apidash?raw=true'),
        headers: {"User-Agent": "Test Agent"},
      ),
    );
  }, timeout: defaultTimeout);

  test('HEAD 2', () async {
    expect(
      Curl.parse(
        r"""curl --head --url 'http://api.apidash.dev'""",
      ),
      Curl(
        method: 'HEAD',
        uri: Uri.parse('http://api.apidash.dev'),
      ),
    );
  }, timeout: defaultTimeout);

  test('POST 1', () async {
    expect(
      Curl.parse(
        r"""curl --request POST \
  --url 'https://api.apidash.dev/case/lower' \
  --header 'Content-Type: text/plain' \
  --data '{
"text": "I LOVE Flutter"
}'""",
      ),
      Curl(
        method: 'POST',
        uri: Uri.parse('https://api.apidash.dev/case/lower'),
        headers: {"Content-Type": "text/plain"},
        data: r"""{
"text": "I LOVE Flutter"
}""",
      ),
    );
  }, timeout: defaultTimeout);

  test('POST 2', () async {
    expect(
      Curl.parse(
        r"""curl --request POST \
  --url 'https://api.apidash.dev/case/lower' \
  --header 'Content-Type: application/json' \
  --data '{
"text": "I LOVE Flutter",
"flag": null,
"male": true,
"female": false,
"no": 1.2,
"arr": ["null", "true", "false", null]
}'""",
      ),
      Curl(
        method: 'POST',
        uri: Uri.parse('https://api.apidash.dev/case/lower'),
        headers: {"Content-Type": "application/json"},
        data: r"""{
"text": "I LOVE Flutter",
"flag": null,
"male": true,
"female": false,
"no": 1.2,
"arr": ["null", "true", "false", null]
}""",
      ),
    );
  }, timeout: defaultTimeout);
}
