#!/usr/bin/env python3
import curses
import subprocess
import sys

def get_clipboard_history():
    try:
        res = subprocess.run(['/usr/local/bin/greenclip', 'print'], capture_output=True, text=True, check=True)
        items = [line.strip() for line in res.stdout.split('\n') if line.strip()]
        return items[:10]
    except Exception:
        return []

def send_to_clipboard(text):
    for selection in ['clipboard', 'primary']:
        p = subprocess.Popen(['/usr/bin/xclip', '-selection', selection], stdin=subprocess.PIPE)
        p.communicate(input=text.encode('utf-8'))

def paste_payload():
    import time
    time.sleep(0.1)
    subprocess.run(['/usr/bin/xdotool', 'keyup', 'Super_L', 'Super_R', 'v', 'V'])
    res = subprocess.run(['/usr/bin/xdotool', 'key', '--clearmodifiers', 'ctrl+shift+v'])
    if res.returncode != 0:
        subprocess.run(['/usr/bin/xdotool', 'key', '--clearmodifiers', 'ctrl+v'])

def draw_ui(stdscr):
    curses.curs_set(0)
    stdscr.timeout(-1)
    stdscr.keypad(True)
    
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_BLUE, -1)   # Header
    curses.init_pair(2, curses.COLOR_GREEN, -1)  # Index Labels
    curses.init_pair(3, 8, -1)                   # Borders
    curses.init_pair(4, curses.COLOR_CYAN, -1)   # Page indicators

    history = get_clipboard_history()
    if not history:
        return None

    current_page = 0
    total_pages = 3

    while True:
        stdscr.clear()
        max_y, max_x = stdscr.getmaxyx()
        
        header = "=== SYSTEM CLIPBOARD HISTORY ==="
        stdscr.attron(curses.color_pair(1) | curses.A_BOLD)
        stdscr.addstr(1, max(2, (max_x - len(header)) // 2), header)
        stdscr.attroff(curses.color_pair(1) | curses.A_BOLD)

        start_idx = current_page * 4
        end_idx = min(start_idx + 4, len(history))
        page_items = history[start_idx:end_idx]

        col_width = max_x // 4
        box_height = 6
        start_y = 3

        for i, item in enumerate(page_items):
            start_x = i * col_width
            clean_item = " ".join(item.split())
            
            stdscr.attron(curses.color_pair(3))
            for y in range(start_y, start_y + box_height):
                stdscr.addch(y, start_x, '|')
                stdscr.addch(y, min(max_x - 1, start_x + col_width - 2), '|')
            stdscr.addstr(start_y, start_x, '-' * (col_width - 1))
            stdscr.addstr(start_y + box_height - 1, start_x, '-' * (col_width - 1))
            stdscr.attroff(curses.color_pair(3))

            label = f" [{i+1}] "
            stdscr.attron(curses.color_pair(2) | curses.A_BOLD)
            stdscr.addstr(start_y, start_x + 2, label)
            stdscr.attroff(curses.color_pair(2) | curses.A_BOLD)

            inner_width = col_width - 5
            lines_avail = box_height - 2
            for line_idx in range(lines_avail):
                char_idx = line_idx * inner_width
                slice_str = clean_item[char_idx:char_idx + inner_width]
                if not slice_str: break
                stdscr.addstr(start_y + 1 + line_idx, start_x + 2, slice_str)

        footer = f"Page {current_page + 1}/{total_pages} | Navigation: [h/l] or [◀/▶] | Exit: [q]"
        stdscr.attron(curses.color_pair(4))
        stdscr.addstr(max_y - 2, max(2, (max_x - len(footer)) // 2), footer)
        stdscr.attroff(curses.color_pair(4))

        stdscr.refresh()

        ch = stdscr.getch()
        
        if 49 <= ch <= 52:
            selection_idx = start_idx + (ch - 49)
            if selection_idx < len(history):
                return history[selection_idx]
                
        elif ch in [ord('l'), curses.KEY_RIGHT]:
            if current_page < total_pages - 1:
                current_page += 1
        elif ch in [ord('h'), curses.KEY_LEFT]:
            if current_page > 0:
                current_page -= 1
                
        elif ch == 27 or ch == ord('q'):
            return None

def main():
    selected = curses.wrapper(draw_ui)
    if selected:
        send_to_clipboard(selected)
        paste_payload()

if __name__ == '__main__':
    main()
