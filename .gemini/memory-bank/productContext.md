# Product Context

## Problem Statement
The current setup relies on a specific "Google Drive" folder structure to sync sensitive or large configuration files (SSH keys, App settings, Automator workflows) between machines. This creates a dependency on Google Drive being installed and synced in a specific location, which limits portability and requires manual setup steps outside the repo.

## Solution
Refactor the setup scripts to rely solely on the files present in the git repository. This promotes a "clone and run" experience.

## User Experience
1.  User clones the repository.
2.  User runs the main setup script (e.g., `setup_mac.sh`).
3.  The system is configured using only the local files.
