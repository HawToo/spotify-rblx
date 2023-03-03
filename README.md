# spotify-rblx

This script enables Roblox players to control their Spotify account through chat commands.

# Usage

You'll need to make sure your executor has the designated functions needed to run this script.


Follow the instructions below to obtain your Spotify API key. After that, Paste it into the script where it's designated.

# Api
To start, Click [https://developer.spotify.com/console/get-users-currently-playing-track/](here) and click "Get Token".

Tick the boxes shown below, and press "Request Token"

user-read-currently-playing
user-read-playback-position
user-modify-playback-state



# Script 

```lua
getgenv().APIKey = "Your API Key"

loadstring(game:HttpGet("https://raw.githubusercontent.com/HawToo/spotify-rblx/main/spotxrblx.txt"))()
```
