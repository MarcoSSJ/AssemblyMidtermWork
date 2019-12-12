# AssemblyMidtermWork
THUSS--Assembly language final work--painter.
# environment
```
language: masm32 + win32
you can use it in vs/radasm
```
# run
```
main.asm
```
# feature
1. paint in canvas on a win32 window
2. painting pattern: pencil, rect, circle, eraser, line
3. can save/load to/from a bmp
4. a color box, a toolbar
5. create a region and copy/fill/clear it
# implementation
1. color box and toolbar adn their buttons are other windows
2. multi asm by `#include`(note: you should only compile main.asm in vs)
3. maintain some state value to determine what to do. 
# coding style 
```
function: starts with _
global variable: camelCase
parameter variable: starts with _
local variable: starts with @
```
# to the lower class
wish you guys survive junior year in THUSS :)
