# Backup My GitHub Profile

_Clones all your GitHub public repositories to your machine_


![1](https://i.imgur.com/H3Yg4VP.jpg)

## Prerequisites

- curl
- jq

## Using

Before starting the script, you need to generate personal access token on GitHub (**with full repo access**).
Follow this guide - [link](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line)

Afterwards, navigate to the folder, where you want to store repos:

```bash
mkdir -p /some/path/to/folder/with/backups
cd /some/path/to/folder/with/backups
```

Run the script:

```bash
bash <(curl -s https://raw.githubusercontent.com/ghaiklor/backup-my-github/master/backup.sh)
```

## License

[DWTFYWT](./LICENSE)
