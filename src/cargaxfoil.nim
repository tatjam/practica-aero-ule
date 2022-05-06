# Permite entender los ficheros de xfoil de cP que tienen el siguiente formato
# linea 0: Nombre del perfil (NACA 0018)
# linea 1: Alfa = valor Re = valor xflap,yflap = valor valor 
# linea 3: # x y Cp
# linea 4-final: valor valor valor 

import std/strutils
import std/strscans
import std/algorithm
import os

type DatosXFoil = tuple
    x: seq[float]
    y: seq[float]
    cp: seq[float]


proc cargarXFoil(path: string): DatosXFoil =
    var x: seq[float]
    var y: seq[float]
    var cp: seq[float]
    var numli = 0

    for line in lines(path):
        var vx, vy, vcp: float
        if numli >= 3:
            # La lectura es muy simple gracias a scanf
            scanf(line, "$s$f $s$f $s$f", vx, vy, vcp)
            echo vx, " ", vy, " ", vcp
            x.add(vx)
            y.add(vy)
            cp.add(vcp)
        numli += 1


    return (x: x, y: y, cp: cp)