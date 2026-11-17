from flask import Flask, request, render_template, abort, g
from app.database import init_database
from config import Config

def create_app():

    app = Flask(__name__)
    
    app.config.from_object(Config)
    
    init_database(Config)

    # Importar y registrar blueprints PRIMERO
    from app.templates.sat.routes import sat
    from app.templates.ant_estatal.routes import ant_estatal
    from app.templates.ant_federal.routes import ant_federal
    from app.templates.certificados.routes import certificados
    
    app.register_blueprint(sat)
    app.register_blueprint(ant_estatal)
    app.register_blueprint(ant_federal)
    app.register_blueprint(certificados)

    SITIOS = {
        "siiat-sat-gob.com.mx": {
            "nombre": "sat",
            "plantilla": "sat/index.html"
        },

        "gobierno-estatal.com.mx": {
                    "nombre": "ant_estatal",
                    "plantilla": "ant_estatal/index.html"
                },

        "gobierno-federal.com.mx": {
            "nombre": "ant_federal",
            "plantilla": "ant_federal/index.html"
        },

        "certificacion-sep.com.mx": {
            "nombre": "certificados",
            "plantilla": "certificados/index.html"
        },
        
        "localhost": {
            "nombre": "sat",
            "plantilla": "sat/index.html"
        }
    }

    @app.before_request
    def detectar_dominio():
        """Detecta el dominio y lo almacena en g para usar en rutas y templates"""
        dominio = request.host.split(":")[0].lower()
        sitio = SITIOS.get(dominio)
        
        if sitio is None:
            # Dominio desconocido - por defecto SAT
            g.dominio = dominio
            g.sitio_nombre = "sat"
            g.sitio_plantilla = "sat/index.html"
        else:
            g.dominio = dominio
            g.sitio_nombre = sitio["nombre"]
            g.sitio_plantilla = sitio["plantilla"]

    @app.route("/")
    def inicio():
        """Ruta raíz que enruta según el dominio accedido"""
        dominio = request.host.split(":")[0].lower()
        sitio = SITIOS.get(dominio)

        if sitio is None:
            abort(404)

        return render_template(sitio["plantilla"])

    return app