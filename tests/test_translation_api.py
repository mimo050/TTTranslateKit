import json
import urllib.request
from urllib.parse import quote

API_URL = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={target}&dt=t&q={text}"

def translate(text: str, target: str) -> str:
    url = API_URL.format(target=target, text=quote(text))
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode("utf-8"))
    # data format: [ [ [ translatedText, originalText, ... ], ... ], ... ]
    return data[0][0][0]

def test_translate_hello_to_arabic():
    translated = translate("hello", "ar")
    assert "مرح" in translated
