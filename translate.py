def text_to_hex_escape(text, encoding='windows-1251'):
    bytes_data = text.encode(encoding)
    return ''.join(f'\\x{byte:02x}' for byte in bytes_data)

# Использование
result = text_to_hex_escape("Топ лучших")
print(result)  # \xc8\xed\xf1\xf2\xf0\xf3\xec\xe5\xed\xf2
