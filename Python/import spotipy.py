import spotipy
from spotipy.oauth2 import SpotifyOAuth
import time

# === CONFIGURAZIONE ===
CLIENT_ID = "INSERISCI_IL_TUO_CLIENT_ID"
CLIENT_SECRET = "INSERISCI_IL_TUO_CLIENT_SECRET"
REDIRECT_URI = "http://127.0.0.1:8000/callback"  # la tua porta
SCOPE = "user-read-playback-state user-modify-playback-state user-library-read"

# === AUTENTICAZIONE ===
sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET,
    redirect_uri=REDIRECT_URI,
    scope=SCOPE
))

# === LOOP CONTINUO ===
while True:
    try:
        playback = sp.current_playback()
        if playback and playback['is_playing']:
            track_id = playback['item']['id']
            track_name = playback['item']['name']
            artists = ", ".join([artist['name'] for artist in playback['item']['artists']])
            
            # Verifica se il brano è nella tua libreria salvata
            saved = sp.current_user_saved_tracks_contains([track_id])[0]

            if saved:
                print(f"🎵 '{track_name}' di {artists} --> Già ascoltato --> SKIP")
                sp.next_track()
                time.sleep(2)  # Attendi 2 secondi prima del prossimo
            else:
                print(f"✅ '{track_name}' di {artists} --> Nuovo --> OK")
        
        time.sleep(5)  # Controlla ogni 5 secondi
    except Exception as e:
        print("Errore:", e)
        time.sleep(10)
