from adventurelib import set_context, get_context

class Context:
    ACTIVE = []

    # status: name of the Context - Required
    # icon: Icon to show in the prompt - Optional
    # data: Additional data that can be accessed while in the context
    def __init__(self, status, icon='', data=None):
        self.__status = status
        self.__icon = icon
        self.data = data

    @classmethod
    def clear(cls):
        cls.ACTIVE = []
        set_context(None)

    @classmethod
    def get(cls):
        status = ""
        for ctx in cls.ACTIVE:
            status += F"{ctx} / "
        return status

    @classmethod
    def add(cls, ctx):
        cls.ACTIVE.append(ctx)
        status = get_context()
        if status is not None:
            new_status = F"{status}.{ctx.status}"
        else:
            new_status = ctx.status
        set_context(new_status)

    @classmethod
    def remove(cls, ctx):
        cls.ACTIVE.remove(ctx)
        status = get_context()
        new_status = status.replace(F".{ctx.status}", '')
        set_context(new_status)

    @property
    def status(self):
        return self.__status

    def activate(self):
        Context.add(self)

    def deactivate(self):
        Context.remove(self)

    def is_active(self):
        return self in Context.ACTIVE

    def __str__(self):
        s = self.status
        if self.__icon:
            s += F"({self.__icon})"

        return s
