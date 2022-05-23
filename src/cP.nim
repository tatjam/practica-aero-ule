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
        let nameextra = fmt"resultados/cP/cP_{reInt}_{aInt}_extra.tex"

        var sup: array[30, float]
        var inf: array[30, float]

        # +- 1 desviacion tipica
        for i in 0..29:
            sup[i] = datosA.Datos[i] + math.sqrt(datosA.Varianzas[i])
            inf[i] = datosA.Datos[i] - math.sqrt(datosA.Varianzas[i])

        let dfextra = seqsToDf({"$x_c$": xc[0..14], "$c_p$": datosA.Datos[0..14],
        "$c_p^X$": datosA.XFOIL_Datos[0..14], "vars": sup[0..14], "vari": inf[0..14]})
    
        var titulo = fmt"Extradós - Reynolds: {reInt}, $\alpha$: {aInt}º"

        ggplot(dfextra) + 
            geom_line(aes("$x_c$", "$c_p$")) + 
            geom_line(aes("$x_c$", "vars"), color=color(0.5, 0.5, 0.5), lineType=ltDotted) + 
            geom_line(aes("$x_c$", "vari"), color=color(0.5, 0.5, 0.5), lineType=ltDotted) + 
            geom_line(aes("$x_c$", "$c_p^X$"), color=color(0, 0, 255), lineType=ltDashed) + 
            ggtitle(titulo) +
            ggsave(nameextra, onlyTikZ=true)
        
        let nameintra = fmt"resultados/cP/cP_{reInt}_{aInt}_intra.tex"

        titulo = fmt"Intradós - Reynolds: {reInt}, $\alpha$: {aInt}º"

        let dfintra = seqsToDf({"$x_c$": xc[15..29], "$c_p$": datosA.Datos[15..29],
        "$c_p^X$": datosA.XFOIL_Datos[15..29], "vars": sup[15..29], "vari": inf[15..29]})
        
        ggplot(dfintra) + 
            geom_line(aes("$x_c$", "vars"), color=color(0.5, 0.5, 0.5), lineType=ltDotted) + 
            geom_line(aes("$x_c$", "vari"), color=color(0.5, 0.5, 0.5), lineType=ltDotted) + 
            geom_line(aes("$x_c$", "$c_p$")) + 
            geom_line(aes("$x_c$", "$c_p^X$"), color=color(0, 0, 255), lineType=ltDashed) + 
            ggtitle(titulo) +
            ggsave(nameintra, onlyTikZ=true)

        
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
        ggsave(fmt"resultados/cP/cPridge_{reInt}_intra.tex", onlyTikZ=true)

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
        ggsave(fmt"resultados/cP/cPridge_{reInt}_extra.tex", onlyTikZ=true)