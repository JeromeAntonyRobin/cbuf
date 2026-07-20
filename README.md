<div align="center">

<div align="center">

<pre>

________________/\\\________________/\\\_____________________________/\\\\\_        
 ______________/\\\/________________\/\\\___________________________/\\\///__       
  ____________/\\\/__________________\/\\\__________________________/\\\______      
   __________/\\\/__________/\\\\\\\\_\/\\\_________/\\\____/\\\__/\\\\\\\\\___     
    ________/\\\/__________/\\\//////__\/\\\\\\\\\__\/\\\___\/\\\_\////\\\//____    
     ______/\\\/___________/\\\_________\/\\\////\\\_\/\\\___\/\\\____\/\\\______   
      ____/\\\/____________\//\\\________\/\\\__\/\\\_\/\\\___\/\\\____\/\\\______  
       __/\\\/_______________\///\\\\\\\\_\/\\\\\\\\\__\//\\\\\\\\\_____\/\\\______ 
        _\///___________________\////////__\/////////____\/////////______\///_______
        
</pre>

</div>

# cbuf

### A fast, keyboard-first clipboard buffer for Linux/X11.

<h4>
  <a href="#-installation">Install</a>
  ·
  <a href="#-features">Features</a>
  ·
  <a href="#-requirements">Requirements</a>
</h4>

<p>
  <img alt="Release" src="https://img.shields.io/github/v/release/jeromeantonyrobin/cbuf?style=for-the-badge&logo=starship&color=C9CBFF&logoColor=D9E0EE&labelColor=302D41">
  <img alt="Last Commit" src="https://img.shields.io/github/last-commit/jeromeantonyrobin/cbuf?style=for-the-badge&logo=starship&color=8bd5ca&logoColor=D9E0EE&labelColor=302D41">
  <img alt="License" src="https://img.shields.io/github/license/jeromeantonyrobin/cbuf?style=for-the-badge&logo=starship&color=ee999f&logoColor=D9E0EE&labelColor=302D41">
  <img alt="Stars" src="https://img.shields.io/github/stars/jeromeantonyrobin/cbuf?style=for-the-badge&logo=starship&color=c69ff5&logoColor=D9E0EE&labelColor=302D41">
  <img alt="Issues" src="https://img.shields.io/github/issues/jeromeantonyrobin/cbuf?style=for-the-badge&logo=bilibili&color=F5E0DC&logoColor=D9E0EE&labelColor=302D41">
  <img alt="Repo Size" src="https://img.shields.io/github/repo-size/jeromeantonyrobin/cbuf?style=for-the-badge&logo=codesandbox&color=DDB6F2&logoColor=D9E0EE&labelColor=302D41">
</p>

</div>

---

`cbuf` is a keyboard-driven clipboard buffer designed for fast terminal workflows.

Instead of opening a vertical history menu or fuzzy finder, `cbuf` presents clipboard history as a paginated 2×2 card grid at the top of your screen. Every visible item is directly selectable using the number keys, minimizing context switching and keeping your hands on the keyboard.

<p align="center">
<img src="assets/preview.png" width="900">
</p>

## ✨ Features

- ⚡ Keyboard-first interaction
- 🗂️ 2×2 paginated clipboard grid
- 🔢 Direct selection using `1-4`
- ⌨️ Vim navigation (`h` / `l`)
- 📋 Automatic clipboard injection
- 🚀 Lightweight Python + curses implementation
- 🪟 Designed for floating terminal workflows

---

## ⚡ Requirements

- Linux (X11)
- Python 3
- `greenclip`
- `xclip`
- `xdotool`
- A floating terminal launcher (Alacritty recommended)

---

## 📦 Installation

```bash
git clone https://github.com/jeromeantonyrobin/cbuf.git
cd cbuf

chmod +x install.sh
./install.sh
```

---

## ⌨️ Controls

| Key | Action |
|-----|--------|
| `1` `2` `3` `4` | Copy corresponding clipboard entry |
| `h` / `←` | Previous page |
| `l` / `→` | Next page |
| `q` | Quit |

---

## 🖼️ Preview

<p align="center">
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/2f06ae8b-0959-4c49-95b0-2c0b091c2f72" />
</p>

---

## 📄 License

MIT
