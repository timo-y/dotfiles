#!/usr/bin/env python3
import json
import sys
import requests
from datetime import datetime

WEATHER_CODES = {
    "113": "☀️ ",
    "116": "⛅ ",
    "119": "☁️ ",
    "122": "☁️ ",
    "143": "☁️ ",
    "176": "🌧️",
    "179": "🌧️",
    "182": "🌧️",
    "185": "🌧️",
    "200": "⛈️ ",
    "227": "🌨️",
    "230": "🌨️",
    "248": "☁️ ",
    "260": "☁️ ",
    "263": "🌧️",
    "266": "🌧️",
    "281": "🌧️",
    "284": "🌧️",
    "293": "🌧️",
    "296": "🌧️",
    "299": "🌧️",
    "302": "🌧️",
    "305": "🌧️",
    "308": "🌧️",
    "311": "🌧️",
    "314": "🌧️",
    "317": "🌧️",
    "320": "🌨️",
    "323": "🌨️",
    "326": "🌨️",
    "329": "❄️ ",
    "332": "❄️ ",
    "335": "❄️ ",
    "338": "❄️ ",
    "350": "🌧️",
    "353": "🌧️",
    "356": "🌧️",
    "359": "🌧️",
    "362": "🌧️",
    "365": "🌧️",
    "368": "🌧️",
    "371": "❄️",
    "374": "🌨️",
    "377": "🌨️",
    "386": "🌨️",
    "389": "🌨️",
    "392": "🌧️",
    "395": "❄️ ",
}

data = {}
# Changed to Berlin and metric units (Celsius)
try:
    weather = requests.get(
        "https://wttr.in/Berlin?format=j1&lang=en&m", timeout=10
    ).json()
except Exception as err:
    # Valid JSON so waybar keeps the module; the message ends up in the log.
    print(json.dumps({}), file=sys.stdout)
    print(f"waybar-wttr: {err}", file=sys.stderr)
    raise SystemExit(0)


def icon(code):
    # wttr.in sometimes returns codes that are not in the WWO set.
    return WEATHER_CODES.get(code, "")


def format_time(time):
    return time.replace("00", "").zfill(2)


def format_temp(temp):
    return (temp + "°").ljust(3)


def format_chances(hour):
    chances = {
        "chanceoffog": "Fog",
        "chanceoffrost": "Frost",
        "chanceofovercast": "Overcast",
        "chanceofrain": "Rain",
        "chanceofsnow": "Snow",
        "chanceofsunshine": "Sunshine",
        "chanceofthunder": "Thunder",
        "chanceofwindy": "Wind",
    }
    conditions = []
    for event in chances.keys():
        if int(hour[event]) > 0:
            conditions.append(chances[event] + " " + hour[event] + "%")
    return ", ".join(conditions)


# Changed to FeelsLikeC
tempint = int(weather["current_condition"][0]["FeelsLikeC"])
extrachar = ""
if tempint > 0 and tempint < 10:
    extrachar = "+"

# Changed all temperature fields to Celsius versions
data["text"] = (
    " "
    + icon(weather["current_condition"][0]["weatherCode"])
    + " "
    + extrachar
    + weather["current_condition"][0]["FeelsLikeC"]
    + "°"
)

data["tooltip"] = (
    f"<b>{weather['current_condition'][0]['weatherDesc'][0]['value']} {weather['current_condition'][0]['temp_C']}°</b>\n"
)
data["tooltip"] += f"Feels like: {weather['current_condition'][0]['FeelsLikeC']}°\n"
data["tooltip"] += f"Wind: {weather['current_condition'][0]['windspeedKmph']}Km/h\n"
data["tooltip"] += f"Humidity: {weather['current_condition'][0]['humidity']}%\n"

for i, day in enumerate(weather["weather"]):
    data["tooltip"] += f"\n<b>"
    if i == 0:
        data["tooltip"] += "Today, "
    if i == 1:
        data["tooltip"] += "Tomorrow, "
    data["tooltip"] += f"{day['date']}</b>\n"
    data["tooltip"] += f"⬆️ {day['maxtempC']}° ⬇️ {day['mintempC']}° "
    data["tooltip"] += (
        f"🌅 {day['astronomy'][0]['sunrise']} 🌇 {day['astronomy'][0]['sunset']}\n"
    )
    for hour in day["hourly"]:
        if i == 0:
            if int(format_time(hour["time"])) < datetime.now().hour - 2:
                continue
        data["tooltip"] += (
            f"{format_time(hour['time'])} {icon(hour['weatherCode'])} {format_temp(hour['FeelsLikeC'])} {hour['weatherDesc'][0]['value']}, {format_chances(hour)}\n"
        )

print(json.dumps(data))
