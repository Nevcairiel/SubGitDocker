#!/bin/bash
cd /subgit/sync.git
git fetch github
git push origin --all --follow-tags
git push origin --tags
