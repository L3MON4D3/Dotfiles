import qbittorrentapi
from enum import Enum
from functools import reduce
import time

client = qbittorrentapi.Client(host="qbittorrent.internal:80")


class QBTTorrent:
    def __init__(self, hash=None):
        assert hash
        self.hash = hash

    @classmethod
    def from_hash(cls, hash):
        return cls(hash=hash)

    def stop(self):
        client.torrents_stop(self.hash)

    def info(self):
        return client.torrents_info(torrent_hashes=self.hash)[0]

    def limit_download(self):
        client.torrents_set_download_limit(torrent_hashes=self.hash, limit=1)

    def unlimit_download(self):
        client.torrents_set_download_limit(torrent_hashes=self.hash, limit=-1)


class APITorrentState(Enum):
    ERROR = "error"
    MISSING_FILES = "missingFiles"
    UPLOADING = "uploading"
    STOPPED_UPLOAD = "stoppedUP"
    QUEUED_UPLOAD = "queuedUP"
    STALLED_UPLOAD = "stalledUP"
    CHECKING_UPLOAD = "checkingUP"
    FORCED_UPLOAD = "forcedUP"
    ALLOCATING = "allocating"
    DOWNLOADING = "downloading"
    METADATA_DOWNLOAD = "metaDL"
    FORCED_METADATA_DOWNLOAD = "forcedMetaDL"
    STOPPED_DOWNLOAD = "stoppedDL"
    QUEUED_DOWNLOAD = "queuedDL"
    FORCED_DOWNLOAD = "forcedDL"
    STALLED_DOWNLOAD = "stalledDL"
    CHECKING_DOWNLOAD = "checkingDL"
    CHECKING_RESUME_DATA = "checkingResumeData"
    MOVING = "moving"
    UNKNOWN = "unknown"


# not sure about the statuses here..
def get_torrents(state, category):
    return reduce(
        lambda list, info:
            list + ([QBTTorrent.from_hash(info.hash)]
                    if info.state in state else []),
        client.torrents_info(category=category), [])


# only stop if movie is actually downloading!
movie_downloading_states = frozenset({
    APITorrentState.FORCED_DOWNLOAD.value,
    APITorrentState.DOWNLOADING.value
})

# collect states to stop.
aa_downloading_states = frozenset({
    APITorrentState.FORCED_DOWNLOAD.value,
    APITorrentState.STALLED_DOWNLOAD.value,
    APITorrentState.DOWNLOADING.value
})


max_tries = 5
tries = 0
retry_timeout_s = 10
while True:
    tries += 1
    print(f"Try {tries}")
    try:
        priority_dl_torrents = get_torrents(movie_downloading_states, "radarr") + get_torrents(movie_downloading_states, "tv-sonarr")  # noqa: E501.
        if len(priority_dl_torrents) > 0:
            for t in get_torrents(aa_downloading_states, "aa"):
                t.limit_download()
        else:
            for t in get_torrents(aa_downloading_states, "aa"):
                t.unlimit_download()
        break
    except qbittorrentapi.exceptions.InternalServerError500Error as ex:
        if tries >= max_tries:
            ex.add_note(f"The exception occured {max_tries} times!")
            raise

        print("Got 500-Error, trying again...")
        time.sleep(retry_timeout_s)
