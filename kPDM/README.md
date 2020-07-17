## kPDM

### Background

It's painful to download log file repeatedly every day, and we hope a tool help us download log file in the background and unzip it.

It is kPDM.

### Install

kPDM has two parts:
- chrome extension: help to generator file link and copy. 
- background: py file, download logs and unzip.

#### chrome extension

![image.png](https://i.loli.net/2020/07/18/x9oHDTU4nOj1QrK.png)

#### background

```bash
# 1. download kPDM from git
wget XXX

# 2. Set PDM username and password to env
export username="kbrx93"
export password="kbrx93"

# 3. run py file in the background
nohup python3 kPDM.py &

```

### Usage

Copy link in PDM system and open it by win Explorer

