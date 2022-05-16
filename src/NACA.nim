import std/math

# En el siguiente programa se generan las coordenadas de los puntos
# en un perfil NACA 0018 a partir de los datos ofrecidos en la hoja de la práctica
# sobre la colocación de los sensores
# Hay 15 en el extrados y 16 en el intrados, cuidado!
let cuerda: float = 250 

# X en mm de los puntos, coinciden con las tomas 
let x: array[30, int] = [
    # Extrados (el 0 es justo la punta)
    0, 5, 10, 15, 20, 40, 50, 60, 70, 80, 90, 110, 150, 190, 230,
    # Intrados (no incluye la punta, cuidado!)
    5, 10, 15, 20, 30, 40, 50, 60, 70, 80, 90, 130, 170, 210, 230
]

# Adimensionalizamos con la cuerda
var xc: array[30, float]
for i in 0..29:
    xc[i] = float(x[i]) / cuerda


# Ahora generamos las coordenadas y de cada punto, adimensionalizada también
var yc: array[30, float]
for i in 0..29:
    let x = xc[i]
    # Ecuacion del grosor del NACA 00xx, xx = 18, por lo que, adimensionalizando dividiendo entre cuerda
    let t = 0.18
    let thickness = 5 * t * (0.2969 * sqrt(x) - 0.1260 * x - 0.3516 * x^2 + 0.2843 * x^3 - 0.1015 * x^4)
    # Ahora, los puntos estan por encima y por debajo de este con la distancia thickness
    # dependiendo si estamos en el extrados (< 14) o intrados (> 14)
    if i <= 14:
        yc[i] = thickness
    else:
        yc[i] = -thickness 
    
echo xc, yc