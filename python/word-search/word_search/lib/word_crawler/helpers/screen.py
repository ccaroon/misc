from colorama import Fore, Back, Style

def background(text, color):
    back_clr = getattr(Back, color.upper(), Style.RESET_ALL)
    return F"{back_clr}{text}{Style.RESET_ALL}"

def foreground(text, color):
    fore_clr = getattr(Fore, color.upper(), Style.RESET_ALL)
    return F"{fore_clr}{text}{Style.RESET_ALL}"

def highlight(text, fore="white", back="black"):
    fore_clr = getattr(Fore, fore.upper(), Fore.WHITE)
    back_clr = getattr(Back, back.upper(), Back.BLACK)
    return F"{fore_clr}{back_clr}{text}{Style.RESET_ALL}"

def clear():
    print(chr(27)+'[2j')
    print('\033c')
    print('\x1bc')

def bold(text):
    return F"{Style.BRIGHT}{text}{Style.RESET_ALL}"
