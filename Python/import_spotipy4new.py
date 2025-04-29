#Riccardo Cattani
#29/04/2024
# Per utilizzare questo script, è necessario installare la libreria Spotipy e configurare le credenziali di accesso a Spotify
# Assicurati di avere le autorizzazioni corrette per accedere alle playlist e alla cronologia di riproduzione
# Per installare Spotipy, esegui: pip install spotipy       
# Per configurare le credenziali di accesso a Spotify, segui le istruzioni qui: https://spotipy.readthedocs.io/en/2.22.1/#authorization-code-flow
# Assicurati di avere un'applicazione Spotify registrata e di avere le credenziali CLIENT_ID, CLIENT_SECRET e REDIRECT_URI  
# Utilizza la libreria Spotipy per interagire con l'API di Spotify  
# Script per Spotify che salva i brani in una playlist quando vengono riprodotti, evitando duplicati
# La playlist viene creata se non esiste già e arrivata a 999 brani, viene creata una nuova playlist con un numero progressivo
# Quando viene riprodotto un bravo già presenta in qualsiasi plalist viene skippato 


import spotipy
from spotipy.oauth2 import SpotifyOAuth
import time

# === CONFIGURAZIONE ===
CLIENT_ID = "40b24bfe376749bAA09b68c9a8eba1510bENV"
CLIENT_SECRET = "40afb06a9e2040bAAAAAA10d37a967ENV"
REDIRECT_URI = "http://127.0.0.1:8000/callback"  # la tua porta
SCOPE = "user-read-playback-state user-modify-playback-state user-library-read playlist-modify-public playlist-modify-private playlist-read-private"

TIMER = 6  # intervallo di controllo in secondi
BASE_PLAYLIST_NAME = "Nuove Scoperte"

# === AUTENTICAZIONE ===
sp = spotipy.Spotify(auth_manager=SpotifyOAuth(
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET,
    redirect_uri=REDIRECT_URI,
    scope=SCOPE,
    cache_path=".cache",
    open_browser=False
))

# === LISTE PER CONTROLLI ===
brani_salvati = set()
contatore_brani_salvati = 0

# === FUNZIONI ===
def carica_tutti_i_brani_dalle_playlists():
    user_id = sp.current_user()['id']
    playlists = sp.current_user_playlists(limit=50)
    all_track_ids = set()

    for playlist in playlists['items']:
        playlist_id = playlist['id']
        offset = 0
        while True:
            tracks = sp.playlist_tracks(playlist_id, limit=100, offset=offset)
            if not tracks['items']:
                break
            for item in tracks['items']:
                if item['track'] and item['track']['id']:
                    all_track_ids.add(item['track']['id'])
            offset += 100

    print(f"✅ Caricati {len(all_track_ids)} brani da tutte le playlist.")
    return all_track_ids


def get_or_create_playlist(base_name):
    user_id = sp.current_user()['id']
    playlists = sp.current_user_playlists(limit=50)
    existing_playlists = {p['name']: p['id'] for p in playlists['items']}

    i = 0
    playlist_name = base_name
    while True:
        if playlist_name in existing_playlists:
            print(f"📂 Playlist trovata: '{playlist_name}' (la riutilizzo)")
            return existing_playlists[playlist_name], playlist_name
        else:
            if i == 0:
                print(f"🆕 Nessuna playlist trovata con nome '{playlist_name}'. Creo nuova playlist...")
                playlist = sp.user_playlist_create(user_id, playlist_name, public=False, description="Brani nuovi scoperti")
                return playlist['id'], playlist_name
            else:
                playlist_name = f"{base_name} {i}"
        i += 1


def check_playlist_size(playlist_id):
    playlist = sp.playlist(playlist_id, fields="tracks.total")
    return playlist['tracks']['total']


# === INIZIALIZZAZIONE ===
playlist_id, playlist_name = get_or_create_playlist(BASE_PLAYLIST_NAME)
brani_in_playlist = carica_tutti_i_brani_dalle_playlists()

ultima_traccia_gestita = None

print(f"🔵 Script avviato: controllo Spotify ogni {TIMER} secondi...")

# === LOOP CONTINUO ===
while True:
    try:
        playback = sp.current_playback()

        if playback is None:
            print("🟡 Nessun playback attivo. Avvia la musica su Spotify...")

        elif playback['is_playing']:
            track = playback['item']
            if track:
                track_id = track['id']
                track_name = track['name']
                artists = ", ".join([artist['name'] for artist in track['artists']])

                if track_id == ultima_traccia_gestita:
                    time.sleep(TIMER)
                    continue

                if track_id in brani_in_playlist:
                    print(f"🎵 '{track_name}' di {artists} --> Già in una tua playlist --> SKIP")
                    sp.next_track()
                    time.sleep(2)
                    ultima_traccia_gestita = track_id
                else:
                    if track_id not in brani_salvati:
                        print(f"✅ '{track_name}' di {artists} --> Nuovo brano --> SALVO nella playlist '{playlist_name}'")

                        total_tracks = check_playlist_size(playlist_id)
                        if total_tracks >= 9999:
                            print("⚡ Playlist piena! Creo una nuova playlist...")
                            playlist_id, playlist_name = get_or_create_playlist(BASE_PLAYLIST_NAME)

                        sp.user_playlist_add_tracks(sp.current_user()['id'], playlist_id, [track_id])
                        brani_salvati.add(track_id)
                        brani_in_playlist.add(track_id)
                        ultima_traccia_gestita = track_id

                        contatore_brani_salvati += 1
                        print(f"📥 Nuovo brano aggiunto correttamente in memoria ✅ | Brani salvati oggi: {contatore_brani_salvati}")
                    else:
                        print(f"⏭️ '{track_name}' di {artists} già salvato, non salvo di nuovo.")

            else:
                print("🟠 Nessuna traccia trovata.")

        else:
            print("🟡 Playback in pausa.")

        time.sleep(TIMER)

    except Exception as e:
        print("🔴 Errore:", e)
        time.sleep(TIMER)
