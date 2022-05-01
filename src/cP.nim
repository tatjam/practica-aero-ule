# Se genera una serie de gráficos del cP a lo largo del intrados 
# para cada combinacion de Reynolds y alfa. El directorio de salida es
# resultados/cP/cP_[REYNOLDS]_[ALFA].png (gráfico cP vs x)

include "cargadatos.nim"
include "NACA.nim"
import ggplotnim
import std/strformat
import std/tables

# Utilizamos la formula deducida en el desarrollo

for datosRe in datos:
    for datosA in datosRe.Datos:
        # Generamos el nombre de fichero
        let reInt = int(datosRe.Reynolds)
        let aInt = int(datosA.Angulo)
        let name = fmt"resultados/cP/cP_{reInt}_{aInt}.tex"

        let df = seqsToDf({"$x_c$": xc[0..14], "$cP$": datosA.Datos[0..14]})
        ggplot(df, aes("$x_c$", "$cP$")) + 
            geom_line() + 
            ggsave(name, standalone=true)

        
# Elaboramos tambien un "ridgemap" tanto de intra como extrados:
for datosRe in datos:
    var dI = 0
    var todosDatos: seq[float]
    var categoria: seq[int]
    var xtodos: seq[float]
    for datosA in datosRe.Datos:
        for i in 0..14:
            todosDatos.add(datosA.Datos[i])
            #categoria.add(fmt"{datosA.Angulo}")
            categoria.add(int(datosA.Angulo))
            xtodos.add(xc[i])
        dI += 1
    let df = seqsToDf({"x": xtodos, "y": todosDatos, "categoria": categoria})
    let reInt = int(datosRe.Reynolds)
    ggplot(df) +
        ggridges("categoria", overlap=2.0) + 
        geom_line(aes("x", "y")) +
        xlab("$x_c$") + 
        ylab("$c_p$") +
        ggsave(fmt"resultados/cP/cPridge_{reInt}_intra.tex", standalone=true)

# Elaboramos tambien un "ridgemap" tanto de intra como extrados:
for datosRe in datos:
    var dI = 0
    var todosDatos: seq[float]
    var categoria: seq[int]
    var xtodos: seq[float]
    for datosA in datosRe.Datos:
        for i in 0..14:
            todosDatos.add(datosA.Datos[i])
            #categoria.add(fmt"{datosA.Angulo}")
            categoria.add(int(datosA.Angulo))
            xtodos.add(xc[i])
        dI += 1
    let df = seqsToDf({"x": xtodos, "y": todosDatos, "categoria": categoria})
    let reInt = int(datosRe.Reynolds)
    ggplot(df) +
        ggridges("categoria", overlap=2.0) + 
        geom_line(aes("x", "y")) +
        xlab("$x_c$") + 
        ylab("$c_p$") +
        ggsave(fmt"resultados/cP/cPridge_{reInt}_extra.tex", standalone=true)