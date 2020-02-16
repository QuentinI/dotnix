import i3ipc
import mpd
import numpy as np
import re
import requests
import scipy
import scipy.cluster
import scipy.misc
import struct
import threading
import time
import traceback
import sys
from PIL import Image, ImageOps, ImageDraw
from pathlib import Path
from urllib.parse import unquote

class AudioHandler(threading.Thread):
    def __init__(self, i3):
        threading.Thread.__init__(self)

        # Initialize MPD client
        self.client = mpd.MPDClient()
        self.client.connect("localhost", 6600)
        self.MBID = ""

        self.i3 = i3
        self.currentWS = 0
        self.wp_restored = True

        self.cachePath = Path('/home/quentin/.cache/albumart')
        self.pipePath = Path('/tmp/glava.color')
        if not self.cachePath.is_dir():
            self.cachePath.mkdir(parents=True)

        if not self.pipePath.is_file():
            self.pipePath.touch()
            self.pipePath.write_text('#2E3440')

    def handle_workspace(self, workspace):
        self.currentWS = workspace.num
        if workspace.num == 6:
            # If workspace is empty, start music shit
            if len(workspace.leaves()) == 0:
                self.i3.command("append_layout  ~/.config/i3/audio.json")
                self.i3.command("exec \"inotifywait -m /tmp/glava.color -e close_write 2>&1 | while read; do cat /tmp/glava.color; done | glava -i\"")
                self.i3.command("exec kitty --class=playlist      -o font_size=20 -e ncmpcpp")
                self.i3.command("exec kitty --class=music_library -o font_size=20 -e ncmpcpp -s media_library")

            # Set wallpaper with album art
            self.set_wallpaper()
        else:
            self.restore_wallpaper()

    def restore_wallpaper(self):
        self.i3.command(f"exec feh /home/quentin/Pictures/wallpaper.png --bg-fill")

    def set_wallpaper(self):
        self.i3.command(f"exec feh {self.cachePath.joinpath('wp.png')} --bg-fill")

    def get_albumart(self, MBID, _path):
        local_cover = Path(f"/home/quentin/Music/{_path}").parent.joinpath("cover.jpg")
        if local_cover.exists():
            self.cachePath.joinpath(MBID + '.jpg').write_bytes(local_cover.read_bytes())

        try:
            res = requests.get(f"https://coverartarchive.org/release/{MBID}")
        except requests.exceptions.ConnectionError:
            return False
        if not res.ok:
            return False
        json = res.json()
        img = None
        for cover in json['images']:
            if cover['front'] == True:
                img = cover['thumbnails']['large']

        try:
            with requests.get(img, stream=True) as stream:
                with open(self.cachePath.joinpath(MBID + '.jpg'), 'wb') as f:
                    for chunk in stream.iter_content(chunk_size=8192):
                          if chunk:
                            f.write(chunk)
            return True
        except:
            return False


    def set_albumart(self, MBID, path):
        artPath = self.cachePath.joinpath(MBID + '.jpg')
        if not artPath.exists():
            self.get_albumart(MBID, path)
        if not artPath.exists():
            artPath = Path("/home/quentin/Pictures/default_art.png")

        im = Image.open(artPath)
        # Resize to fit in the glava circle
        im = im.resize((256,256), Image.ANTIALIAS)

        # Crop to circular thumbnail
        bigsize = (im.size[0] * 3, im.size[1] * 3)
        mask = Image.new('L', bigsize, 0)
        draw = ImageDraw.Draw(mask)
        draw.ellipse((0, 0) + bigsize, fill=255)
        mask = mask.resize(im.size, Image.ANTIALIAS)
        im.putalpha(mask)

        # Overlay with wallpaper
        bg = Image.open("/home/quentin/Pictures/wallpaper.png")
        bg.paste(im, (354,135), im)
        bg.save(self.cachePath.joinpath("wp.png"), "PNG")

        # Get prevalent color and pipe it into glava
        prevalent_color = self.get_prevalent_color(im)
        self.pipePath.write_text(f"{prevalent_color}\n")

    def get_prevalent_color(self, image):
        # Courtesy of Peter Hansen: https://stackoverflow.com/a/3244061
        image = image.resize((150, 150))
        array = np.asarray(image)
        shape = array.shape
        array = array.reshape(scipy.product(shape[:2]), shape[2]).astype(float)
        codes, dist = scipy.cluster.vq.kmeans(array, 5)
        vecs, dist = scipy.cluster.vq.vq(array, codes)
        counts, bins = scipy.histogram(vecs, len(codes))
        index_max = scipy.argmax(counts)
        peak = codes[index_max]
        return "#" + "".join([hex(int(p))[2:].ljust(2, "0") for p in peak])

    def run(self):
        state = prevstate = 'stop'

        while True:
            time.sleep(0.4)

            status = self.client.status()
            prevstate = state
            state = status['state']

            # Playback stopped
            if state == 'stop':
                if prevstate != state:
                    self.restore_wallpaper()

            # Playing or on pause
            else:
                track = self.client.playlistid(status["songid"])[0]
                MBID = track['musicbrainz_albumid']
                path = unquote(track['file']).replace('local:track:', '')

                if self.MBID != MBID or prevstate != state:
                    self.MBID = MBID
                    self.set_albumart(MBID, path)
                    if self.currentWS == 6:
                        self.set_wallpaper()

class Main:
    def __init__(self, handlers, socket_path=""):
        self.i3 = i3ipc.Connection(socket_path=socket_path)
        self.handlers = []

        for handler in handlers:
            try:
                self.handlers.append(handler(self.i3))
            except:
                print("Error instantiating handler:", file=sys.stderr)
                print(traceback.format_exc())

        for handler in self.handlers:
            try:
                handler.start()
            except:
                print("Error starting handler:")
                print(traceback.format_exc())

        def on_workspace_focus(i3, e):
            for handler in self.handlers:
                print(f"[DEBUG]: switched to workspace ${e.current.num}", file=sys.stderr)
                try:
                    handler.handle_workspace(e.current)
                except:
                    print("Error executing workspace handler:")
                    print(traceback.format_exc())

        self.i3.on('workspace::focus', on_workspace_focus)
        self.i3.main()

Main([AudioHandler], socket_path=sys.argv[1])
