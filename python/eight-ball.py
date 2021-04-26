#!/usr/bin/env python
import random
import sys

RESPONSES = [
    "As I see it, yes.",
    "Ask again later.",
    "Better not tell you now.",
    "Cannot predict now.",
    "Concentrate and ask again.",
    "Don’t count on it.",
    "It is certain.",
    "It is decidedly so.",
    "Most likely.",
    "My reply is no.",
    "My sources say no.",
    "Outlook not so good.",
    "Outlook good.",
    "Reply hazy, try again.",
    "Signs point to yes.",
    "Very doubtful.",
    "Without a doubt.",
    "Yes.",
    "Yes – definitely.",
    "You may rely on it."
]

def ask(question):
    return random.choice(RESPONSES)

def reply(question, answer):
    print(F'❔ - "{question}"?')
    print("-----")
    print(F"🎱 - {answer}")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("🎱 You must ask the Magic Eight Ball a question!")
    else:
        question = sys.argv[1]
        answer = ask(question)
        reply(question, answer)
