#!/usr/bin/lua

local demos = {
  "cellular_automaton",
  "quad-tree",
  "shadow-casting"
}

local menu_text = [[
=============== Demos USPGameDev! ===============

Demonstrações disponíveis:

%s
=================================================
Escolha uma pelo número ou 'q' para sair: ]]

local options = ""
for i,demo in ipairs(demos) do
  options = options .. string.format("%d) %s\n", i, demo)
end

menu_text = menu_text:format(options)

while true do
  os.execute("clear")
  io.write(menu_text)
  local which = io.read()
  if which == 'q' then break end
  local index = tonumber(which)
  if which then
    os.execute(string.format("love %s", demos[index]))
  else
    print "Use o número!"
  end
end

print "Encerrando execução!"
