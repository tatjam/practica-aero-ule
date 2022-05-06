include "NACA.nim"
import ggplotnim


var ids: seq[string]
var textx: seq[float]
var texty: seq[float]
for i in 0..29:
    if i <= 14:
        textx.add(xc[i] + 0.005)
        texty.add(yc[i] + 0.04)
    else:
        textx.add(xc[i] - 0.005)
        texty.add(yc[i] - 0.04)

    ids.add($(i + 1))

let df = seqsToDf({"$x_{uc}$": xc[0..14], 
    "$x_{lc}$": xc[15..29], "$y_{uc}$": yc[0..14], "$y_{lc}$": yc[15..29],
    "ucid": ids[0..14], "xuc": textx[0..14], "yuc": texty[0..14],
    "lcid": ids[15..29], "xlc": textx[15..29], "ylc": texty[15..29]})

# Se obvia la línea del intrados de 0 a 15

ggplot(df) + 
    geom_line(aes(x = "$x_{uc}$", y="$y_{uc}$")) + 
    geom_point(aes(x = "$x_{uc}$", y="$y_{uc}$")) +
    geom_line(aes(x="$x_{lc}$", y="$y_{lc}$")) +
    geom_point(aes(x="$x_{lc}$", y="$y_{lc}$")) +
    geom_text(aes(x="xuc", y="yuc", text="ucid"), size=3.0) + 
    geom_text(aes(x="xlc", y="ylc", text="lcid"), size=3.0) + 
    ylim(-0.2, 0.2) +
    ggsave("resultados/NACA.tex", height = 200, standalone=true)