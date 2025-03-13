# Terminal color codes
def colors: {
  "red": "[31m",
  "green": "[32m",
  "yellow": "[33m",
  "blue": "[34m",
  "darkgray": "[90m",
  "disabled": "[30;100m",
  "reset": "[0m",
  "bold": "[1m"
};
def escape: "\u001b";
def colored_text(text; color):
  escape + colors[color] + text + escape + colors.reset;
def flagText(flag;lab;color):
  if flag then colored_text(lab;color) else "" end;
def pad(text;n):
  text + (" "*(text | n - length));
