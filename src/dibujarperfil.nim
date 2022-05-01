include "NACA.nim"
import ggplotnim


let df = seqsToDf({"$x_{uc}$": xc[0..14], 
    "$x_{lc}$": xc[15..29], "$y_{uc}$": yc[0..14], "$y_{lc}$": yc[15..29]})

# Se obvia la línea del intrados de 0 a 15

ggplot(df) + 
    geom_line(aes(x = "$x_{uc}$", y="$y_{uc}$")) + 
    geom_point(aes(x = "$x_{uc}$", y="$y_{uc}$")) +
    geom_line(aes(x="$x_{lc}$", y="$y_{lc}$")) +
    geom_point(aes(x="$x_{lc}$", y="$y_{lc}$")) +
    ylim(-0.2, 0.2) +
    ggsave("resultados/NACA.tex", height = 200, standalone=true)