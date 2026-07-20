# cbuf — Clipboard Buffer

> A fast, keyboard-driven horizontal TUI clipboard paging curtain for Linux/X11.

`cbuf` is a minimal, keyboard-first clipboard deck engine built for modal terminal workflows. Instead of scrolling through vertical menus or searching fuzzy finders, `cbuf` drops a $4$-column paginated TUI buffer across the top of your screen, rendering clipboard items into structured visual cards.

![cbuf TUI Layout](https://raw.githubusercontent.com/jeromeantonyrobin/cbuf/main/assets/preview.png)

---

## ⚡ Features

* **Zero Context Switching:** Drops down dynamically like a quake terminal.
* **4-Column Paginated Grid:** Displays clipboard items in visual cards split across $3$ pages ($10$ items total).
* **Vim Navigation:** Use `h` / `l` or `←` / `→` to slide between pages seamlessly.
* **Instant Direct Injection:** Press `1`, `2`, `3`, or `4` to immediately write to system clipboards and paste into your focused window.
* **Automated Key Clearing:** Bypasses window manager input grabs and modifier key locks cleanly.

---

## 🛠️ System Requirements

* **OS:** Linux (X11)
* **Terminal:** Alacritty (or any floating terminal runner)
* **Dependencies:** `python3`, `xclip`, `xdotool`, `greenclip`

---

## 📦 Installation

Clone the repository and run the setup script:

```bash
git clone [https://github.com/jeromeantonyrobin/cbuf.git](https://github.com/jeromeantonyrobin/cbuf.git)
cd cbuf
chmod +x install.sh
./install.sh
