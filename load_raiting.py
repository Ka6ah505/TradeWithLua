import asyncio
import re
from bs4 import BeautifulSoup
from httpx import AsyncClient


base_url = "https://smart-lab.ru/q/"
ofz = "ofz/"
sub = "subfed/"
bonds = "bonds/order_by_val_to_day/desc/page{num}?bonds_variable=-1"


class Bond:
    def __init__(self, isin, type_coupon, rating, offer):
        self.isin = isin
        self.type_coupon = type_coupon
        self.rating = rating
        self.offer = offer

    def __str__(self):
        return "{isin}={{type_coupon={type_coupon}, rating={rating}, offer={offer}}}".format(
            isin=self.isin,
            type_coupon=self.type_coupon,
            rating=self.rating,
            offer=self.offer,
        )


async def get_isin(text):
    result = re.findall(r"[RU|SU][0-9A-Z]*", text)
    return result[0] if len(result) > 0 else ""


async def get_type_coupon(text):
    if "плавающим" in text:
        return "float"
    if "фиксир" in text:
        return "fixed"
    if "амортиз" in text:
        return "amort"
    return "-"


async def parser(text: str, type_bond="офз"):
    soup = BeautifulSoup(text, "html.parser")
    table = soup.find("table", {"class": "_hidden"})
    rows = table.find_all("tr")
    table = []
    for row in rows:
        try:
            obj = row.find_all("td")

            if obj:
                isin = await get_isin(str(obj[1]))
                type_coupon = await get_type_coupon(str(obj[1]))
                rating = str(obj[7].text) if type_bond == "corp" else "XXX"
                offer = str(obj[17].text) if type_bond == "corp" else "-"
                table.append(Bond(isin, type_coupon, rating, offer))
        except:
            print("exception")
    return table


async def main():
    result = []
    async with AsyncClient() as client:
        print("Старт ОФЗ")
        try:
            response = await client.get(
                base_url + ofz,
            )
            if response.status_code:
                result.extend(await parser(response.text, "ofz"))
        except:
            print("Не будет ОФЗ")
        print("Старт Субфеды")
        try:
            response = await client.get(
                base_url + sub,
            )
            if response.status_code:
                result.extend(await parser(response.text, "ofz"))
        except:
            print("Не будет Субфедов")

        print("Старт Корпы")
        for num in range(1, 26):
            try:
                response = await client.get(
                    base_url + bonds.format(num=num),
                )
                if response.status_code:
                    result.extend(await parser(response.text, "corp"))
            except:
                print("Не будет корпов со страницы {num}")

    return result


if __name__ == "__main__":
    with open("rating_all.txt", "w") as f:
        for bond in asyncio.run(main()):
            try:
                f.writelines(f"{str(bond)}\n")
            except:
                print(bond.isin)

    print("Готово")
