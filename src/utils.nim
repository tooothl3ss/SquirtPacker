import parseopt

var help = false
let options = [
  ("-h", "--help", "Show help information", proc(s: string) = help = true)
]

# Устанавливаем cmdEnd = true, чтобы остановить разбор опций при встрече "--"
let args = parseopt(options, cmdEnd = true)
if help:
  echo "Usage: main.exe [options] [--] <other arguments>"
  quit(0)

echo "Остальные аргументы: ", args
