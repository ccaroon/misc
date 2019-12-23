import pyfiglet
from abc import ABC, abstractmethod

import lib.word_crawler.helpers.screen as screen

class CutScene:

    def __init__(self, name, on_going=False):
        self.__name = name
        self.__events = []

        # Number of times allowed to run
        self.__run_count = 1
        if on_going:
            self.__run_count = 9999999

    def add_action(self, action, pause=True):
        self.__events.append(CutScene.Action(action, pause))

    def add_dialogue(self, statement, enlarge=False, color=None, pause=True):
        text = statement
        if enlarge:
            text = pyfiglet.figlet_format(statement)

        if color:
            text = screen.foreground(text, color)

        self.__events.append(CutScene.Dialogue(text, pause))

    def play(self):
        if self.__run_count > 0:
            self.__run_count -= 1
            for i, event in enumerate(self.__events):
                event.run()
                # prompt = F"{i+1}/{count}".center(80, "-")
                # input(prompt)
                if event.pause:
                    input()

    # Sub Classes
    class Event(ABC):
        def __init__(self, pause):
            self.pause = pause

        @abstractmethod
        def run(self):
            pass

    class Action(Event):
        def __init__(self, action, pause=True):
            self.__action = action
            super().__init__(pause)

        def run(self):
            self.__action()

    class Dialogue(Event):
        def __init__(self, statement, pause=True):
            self.__stmt = statement
            super().__init__(pause)

        def run(self):
            print(self.__stmt)
