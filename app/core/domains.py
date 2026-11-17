from flask import request, abort

DOMINIOS = {

    "siiat-sat-gob.com.mx": "sat",

    "gobierno-estatal.com.mx": "ant_estatal",

    "gobierno-federal.com.mx": "ant_federal",

    "certificacion-sep.com.mx": "certificados"

}


def identificar_dominio():

    dominio = request.host.split(":")[0].lower()

    sitio = DOMINIOS.get(dominio)

    if not sitio:
        abort(404)

    return sitio