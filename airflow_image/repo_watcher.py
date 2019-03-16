#!/usr/local/bin/python
import logging
import subprocess
from datetime import datetime
from time import sleep

import feedparser


MIN_INTERVAL = 5
REPO = "https://gitlab.com/gitlab-data/analytics.git"


def clone_repo(interval: int, repo: str) -> None:
    """
    Clone a git repo every x minutes.

    interval: determines how often the repo gets cloned
    repo: https address of the git repo
    """

    ## TODO: Make this smarter and use merge event web hooks at some point.
    while True:
        sleep(interval * 60)
        subprocess.run("cd analytics/ && git pull", shell=True, check=True)
        print(f"Repo successfully pulled at: {datetime.now()}")

    return


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    clone_repo(MIN_INTERVAL, REPO)
