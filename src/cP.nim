# Se genera una serie de gráficos del cP a lo largo del intrados 
# para cada combinacion de Reynolds y alfa. El directorio de salida es
# resultados/cP/cP_[REYNOLDS]_[ALFA].png (gráfico cP vs x)

include "cargadatos.nim"
include "NACA.nim"

# Utilizamos la formula deducida en el desarrollo

let df = seqsToDf({"X": xc[0..14], "cP": cP[0..14]})
ggplot(df, aes("X", "cP")) + 
    geom_line() + 
    margin(left = 6.0, bottom = 6.0) + 
    ggsave("resultados/cPIntrados.tex", standalone=true)