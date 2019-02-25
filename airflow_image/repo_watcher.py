#!/usr/local/bin/python
import logging
import subprocess
import time
from datetime import datetime

import feedparser


MIN_INTERVAL = 5
FEED = "https://gitlab.com/gitlab-data/analytics.atom?feed_token=5Zszsskp8pZmr9yy6sGv"


def watch_repo(interval: int, feed: str) -> None:
    """
    Check an RSS feed for updates.
    Frequency of checks determined by interval var.
    """

    # Always clone the repo initially
    subprocess.run(
            "git clone https://gitlab.com/gitlab-data/analytics.git analytics",
            shell=True,
            check=True,
    )

    # Loop and sleep to check for updates
    last_git_pull = datetime.now()
    while True:
        # Find the most recent merge
        for item in feedparser.parse(feed).entries:
            if "accepted merge request" in  item.title:
                entry_id = item.id
                updated_at = item.updated
                break

        logging.info("Checking RSS feed...most recent ID is {}".format(entry_id))

        date_format = "%Y-%m-%dT%H:%M:%SZ"
        last_rss_update = datetime.strptime(updated_at, date_format)

        if last_git_pull < last_rss_update:
            logging.info("New update found, pulling from master...")
            subprocess.run(
                    "git pull",
                    shell=True,
                    check=True,
            )
            last_git_pull = last_rss_update

        time.sleep(interval * 60)

    return


if __name__ == '__main__':
    logging.basicConfig(level=logging.INFO)
    watch_repo(MIN_INTERVAL, FEED)
