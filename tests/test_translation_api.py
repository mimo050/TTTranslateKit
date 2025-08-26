import json
import urllib.request
from urllib.parse import quote
from unittest.mock import MagicMock, patch

API_URL = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={target}&dt=t&q={text}"

def translate(text: str, target: str) -> str:
    url = API_URL.format(target=target, text=quote(text))
    with urllib.request.urlopen(url) as response:
        data = json.loads(response.read().decode("utf-8"))
    # data format: [ [ [ translatedText, originalText, ... ], ... ], ... ]
    return data[0][0][0]

def test_translate_hello_to_arabic():
    fake_payload = [[["مرحبا", "hello"]]]
    mock_response = MagicMock()
    mock_response.read.return_value = json.dumps(fake_payload).encode("utf-8")
    mock_response.__enter__.return_value = mock_response
    with patch("urllib.request.urlopen", return_value=mock_response) as mock_urlopen:
        translated = translate("hello", "ar")
        assert translated == "مرحبا"
        mock_urlopen.assert_called_once()


def test_translate_text_with_special_chars():
    text = "a&b=c"
    fake_payload = [[["X", text]]]
    mock_response = MagicMock()
    mock_response.read.return_value = json.dumps(fake_payload).encode("utf-8")
    mock_response.__enter__.return_value = mock_response
    with patch("urllib.request.urlopen", return_value=mock_response) as mock_urlopen:
        translated = translate(text, "ar")
        assert translated == "X"
        called_url = mock_urlopen.call_args[0][0]
        assert "a%26b%3Dc" in called_url
