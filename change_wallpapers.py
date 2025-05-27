import sys
from pathlib import Path
import os


def hyprpaper_change_wallpapers(path: Path, monitor: str = "") -> None:
    config = Path("~/.config/hypr/hyprpaper.conf").expanduser()

    if not config.exists or not config.is_file():
        raise TypeError(f"Файл {config} не сущетвует.")
    elif not os.access(config, os.W_OK):
        raise PermissionError(f"Файл {config} не доступен для записи")

    with config.open("w") as f:
        f.write(f"""preload = {path.absolute()}
        wallpaper = {monitor}, {path.absolute()} 
        """)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        raise ValueError("Missing argument")
    path = Path(sys.argv[1])

    hyprpaper_change_wallpapers(path)
