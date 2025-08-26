import json
import urllib.request
import urllib.error
from urllib.parse import quote
from unittest.mock import MagicMock, patch

import pytest

API_URL = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl={target}&dt=t&q={text}"

def translate(text: str, target: str) -> str:
    if not text:
        raise ValueError("Text to translate must not be empty")
    url = API_URL.format(target=target, text=quote(text))
    try:
        with urllib.request.urlopen(url) as response:
            data = json.loads(response.read().decode("utf-8"))
    except urllib.error.URLError as exc:
        raise exc
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


def test_translate_empty_text_raises_error():
    with pytest.raises(ValueError):
        translate("", "ar")


def test_translate_url_error_propagates():
    with patch("urllib.request.urlopen", side_effect=urllib.error.URLError("boom")):
        with pytest.raises(urllib.error.URLError):
            translate("hello", "ar")
