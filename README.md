# 🎬🔍 PS Generate Thumbnails

...

## Usage

```powershell
cd folderWithVideos
GenerateThumbnails
```

## Installation

### 1. Install scoop

```powershell
set-executionpolicy remotesigned -s currentuser
iex (new-object net.webclient).downloadstring('https://get.scoop.sh')
```

### 2. Install the [powershell bucket](https://github.com/krokofant/scoop-powershell-bucket)

```powershell
scoop bucket add powershell-tools https://github.com/krokofant/scoop-powershell-bucket.git
```

### 3. Install PS-Install-If-Missing

```powershell
scoop install PS-Generate-Thumbnails
```
