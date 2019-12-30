from colorama import Fore

import lib.word_crawler.helpers.screen as screen
from .cut_scene import CutScene

scene = CutScene("Intro")
scene.add_action(screen.clear, pause=False)
scene.add_dialogue("Word Crawler", enlarge=True, color="red")
scene.add_dialogue("A word search puzzle, dungeon crawler style!")
