# artscii
Extremely simple ASCII art generator (from images) written in Julia.


### Dependencies
This script uses **Images.jl** and the **ImageIO.jl** package which you can
install through Julia's REPL by typing `]add Images ImageIO`.


### How to use

```bash
julia asciigenerator.jl "path_to_img"
```

which will generate a HTML file in the directory where the template image is
located. The resulting ASCII art file will have as many characters as amount of
pixels the original image has.

If rescaling is needed (highly recommended), use the optional argument `--width`
to indicate the desired width in terms of characters of the resulting HTML
file.

e.g.
```bash
julia asciigenerator.jl "/Users/alfre/Pictures/Tardigrados.jpg" -w 100
```
