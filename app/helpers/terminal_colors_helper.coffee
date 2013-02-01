TERMINAL_COLORS = {
  30: 'black'
  31: 'red'
  32: 'green'
  33: 'yellow'
  34: 'blue'
  35: 'magenta'
  36: 'cyan'
  37: 'white'
  
  39: 'black'
}

exports.terminal_to_html = (text) ->
  text = '<span class="black">' + text + '</span>'
  
  for k, v of TERMINAL_COLORS
    text = text.replace(new RegExp("\u001b\\[#{k}m", 'g'), '</span><span class="' + v + '">')
  
  text
