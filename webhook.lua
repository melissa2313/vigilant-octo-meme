_G.Webhook = "PUT WEBHOOK HERE"
_G.TrackList = {
   ['Basic'] = false;
   ['Rare'] = false;
   ['Epic'] = false;
   ['Legendary'] = false;
   ['Mythical'] = true;
   ['Exclusive'] = true;
}

loadstring(game:HttpGet('https://raw.githubusercontent.com/vigilkat/vigilkat/main/webhookapi.lua'))()
