import sublime, sublime_plugin

class MarkdownPreviewCommand(sublime_plugin.TextCommand):
    def run(self, edit):
        sublime.message_dialog(self.view.file_name())
 
    def description(args):
        return "MD - Craig N. Caroon"
