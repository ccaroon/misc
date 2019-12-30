import yaml

from lib.diagram import Diagram

class Puzzle:

    def __init__(self, name):
        data = {}
        with open(F"./puzzles/{name}.yml") as file:
            data = yaml.full_load(file)

        self.title = data.get('title', "No Title")
        self.author = data.get('author', "Anonymous")
        self.difficulty = data.get('difficulty', "Unknown")

        self.__word_list = data.get('words', [])
        self.__diagram = Diagram(data['diagram'])

    def letter_at(self, row, col):
        return self.__diagram.get(row,col)

    def size(self):
        return self.__diagram.size()

    def word_count(self):
        return len(self.__word_list)

    def auto_search(self):
        found_words = {}
        for word in self.__word_list:
            location = self.__diagram.find_word(word)
            if location:
                found_words[word] = location
            else:
                found_words[word] = None

        return (found_words)

    def diagram(self):
        return self.__diagram

    def __str__(self):
        size = self.__diagram.size()

        output = F"""
{self.title} [{size[0]},{size[1]}] ({self.difficulty})
by {self.author}

{self.__diagram}
"""

        for word in self.__word_list:
            output += F"* {word}\n"

        return output
